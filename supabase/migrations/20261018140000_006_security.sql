-- ==============================================================================
-- 006_security.sql  (STEP 3 - SECURITY)
--
-- Least-privilege Row Level Security on every public table, safe profile
-- creation, role-escalation protection and the security audit RPC.
--
-- File name note: Supabase CLI orders migrations by their numeric prefix, so the
-- "006" label lives in the name part, after a timestamp that sorts AFTER the
-- initial schema (20261013000000). A bare "006_security.sql" would sort BEFORE
-- the initial schema and fail on `supabase db push`.
--
-- Auth model (no email step): email + password, "Confirm email" OFF, so
-- signUp() returns a session immediately. Nothing here depends on SMTP,
-- redirect URLs, deep links or email templates.
--
-- Documentation: docs/security.md   Tests: tests/security/*.sql
-- ==============================================================================


-- ==============================================================================
-- 1. HELPER FUNCTIONS
--    SECURITY DEFINER + empty search_path: every object is schema-qualified so a
--    caller cannot hijack name resolution.
-- ==============================================================================

-- true when the caller's profile has role = 'admin'
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = ''
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.profiles p
    WHERE p.id = (SELECT auth.uid())
      AND p.role = 'admin'
  );
$$;

-- true when the caller's profile has role = 'parking_owner'
CREATE OR REPLACE FUNCTION public.is_parking_owner()
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = ''
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.profiles p
    WHERE p.id = (SELECT auth.uid())
      AND p.role = 'parking_owner'
  );
$$;

-- true when the caller owns the given parking lot
CREATE OR REPLACE FUNCTION public.owns_parking_lot(p_parking_lot_id uuid)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = ''
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.parking_lots l
    WHERE l.id = p_parking_lot_id
      AND l.owner_id = (SELECT auth.uid())
  );
$$;

REVOKE ALL ON FUNCTION public.is_admin()                  FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.is_parking_owner()          FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.owns_parking_lot(uuid)      FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.is_admin()               TO authenticated;
GRANT EXECUTE ON FUNCTION public.is_parking_owner()       TO authenticated;
GRANT EXECUTE ON FUNCTION public.owns_parking_lot(uuid)   TO authenticated;


-- ==============================================================================
-- 2. SAFE PROFILE CREATION  (AFTER INSERT ON auth.users)
--    raw_user_meta_data is fully client-controlled, so it is treated as untrusted:
--      * role is accepted ONLY when it is vehicle_owner or parking_owner,
--        anything else (including 'admin') becomes vehicle_owner;
--      * full_name falls back to the part of the email before "@";
--      * lengths are capped.
-- ==============================================================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_meta      jsonb := COALESCE(NEW.raw_user_meta_data, '{}'::jsonb);
  v_full_name text;
  v_phone     text;
  v_role      text;
BEGIN
  v_full_name := NULLIF(btrim(v_meta ->> 'full_name'), '');
  IF v_full_name IS NULL THEN
    v_full_name := NULLIF(btrim(split_part(COALESCE(NEW.email, ''), '@', 1)), '');
  END IF;

  v_phone := NULLIF(btrim(v_meta ->> 'phone'), '');

  v_role := CASE
    WHEN v_meta ->> 'role' IN ('vehicle_owner', 'parking_owner') THEN v_meta ->> 'role'
    ELSE 'vehicle_owner'
  END;

  INSERT INTO public.profiles (id, full_name, phone, role)
  VALUES (NEW.id, left(v_full_name, 120), left(v_phone, 30), v_role)
  ON CONFLICT (id) DO NOTHING;

  RETURN NEW;
END;
$$;

REVOKE ALL ON FUNCTION public.handle_new_user() FROM PUBLIC, anon, authenticated;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Backfill: accounts created before this trigger existed (or while it was broken)
-- must still have a profile, otherwise they have no role and no data access.
INSERT INTO public.profiles (id, full_name, phone, role)
SELECT
  u.id,
  left(COALESCE(
         NULLIF(btrim(u.raw_user_meta_data ->> 'full_name'), ''),
         NULLIF(btrim(split_part(COALESCE(u.email, ''), '@', 1)), '')
       ), 120),
  left(NULLIF(btrim(u.raw_user_meta_data ->> 'phone'), ''), 30),
  CASE
    WHEN u.raw_user_meta_data ->> 'role' IN ('vehicle_owner', 'parking_owner')
      THEN u.raw_user_meta_data ->> 'role'
    ELSE 'vehicle_owner'
  END
FROM auth.users u
WHERE NOT EXISTS (SELECT 1 FROM public.profiles p WHERE p.id = u.id);


-- ==============================================================================
-- 3. ROLE-ESCALATION GUARD  (BEFORE UPDATE ON public.profiles)
--    A role change is blocked unless the caller is an admin, or there is no
--    end-user JWT at all (auth.uid() IS NULL: SQL editor, migrations, service_role).
--    SECURITY INVOKER on purpose: it needs no extra privilege.
-- ==============================================================================
CREATE OR REPLACE FUNCTION public.protect_profile_role()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = ''
AS $$
BEGIN
  IF NEW.role IS DISTINCT FROM OLD.role
     AND (SELECT auth.uid()) IS NOT NULL
     AND NOT public.is_admin() THEN
    RAISE EXCEPTION 'Changing the role of a profile is not allowed'
      USING ERRCODE = '42501';
  END IF;
  RETURN NEW;
END;
$$;

REVOKE ALL ON FUNCTION public.protect_profile_role() FROM PUBLIC, anon, authenticated;

DROP TRIGGER IF EXISTS protect_profile_role ON public.profiles;
CREATE TRIGGER protect_profile_role
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW
  WHEN (OLD.role IS DISTINCT FROM NEW.role)
  EXECUTE FUNCTION public.protect_profile_role();


-- ==============================================================================
-- 4. SECURITY AUDIT RPC
--    The ONLY way a client can write public.security_events (no INSERT grant, no
--    INSERT policy). It always records auth.uid(), never a client-supplied user.
-- ==============================================================================
CREATE OR REPLACE FUNCTION public.log_security_event(
  event_type  text,
  device_info text DEFAULT NULL
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_uid uuid := (SELECT auth.uid());
BEGIN
  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'Authentication required' USING ERRCODE = '28000';
  END IF;

  IF log_security_event.event_type IS NULL
     OR log_security_event.event_type !~ '^[a-z][a-z0-9_]{1,39}$' THEN
    RAISE EXCEPTION 'Invalid event_type' USING ERRCODE = '22023';
  END IF;

  INSERT INTO public.security_events (user_id, event_type, device_info)
  VALUES (v_uid, log_security_event.event_type, left(log_security_event.device_info, 255));
END;
$$;

REVOKE ALL ON FUNCTION public.log_security_event(text, text) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.log_security_event(text, text) TO authenticated;


-- ==============================================================================
-- 5. PRIVILEGES  (defence in depth: GRANTs are the first gate, RLS the second)
-- ==============================================================================

-- 5.1 anon (not logged in) must reach nothing.
REVOKE ALL ON ALL TABLES    IN SCHEMA public FROM anon;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM anon;
REVOKE ALL ON ALL FUNCTIONS IN SCHEMA public FROM anon;
ALTER DEFAULT PRIVILEGES IN SCHEMA public REVOKE ALL ON TABLES    FROM anon;
ALTER DEFAULT PRIVILEGES IN SCHEMA public REVOKE ALL ON SEQUENCES FROM anon;
ALTER DEFAULT PRIVILEGES IN SCHEMA public REVOKE ALL ON FUNCTIONS FROM anon;

-- 5.2 authenticated: start from zero, grant only what the app needs.
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM authenticated;

GRANT SELECT, UPDATE                   ON public.profiles              TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE   ON public.vehicles              TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE   ON public.parking_lots          TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE   ON public.parking_spaces        TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE   ON public.parking_schedules     TO authenticated;
GRANT SELECT                           ON public.reservations          TO authenticated;  -- writes: RPCs only
GRANT SELECT                           ON public.payments              TO authenticated;  -- writes: server only
GRANT SELECT, INSERT, UPDATE, DELETE   ON public.reviews               TO authenticated;  -- UPDATE/DELETE gated to admin by RLS
GRANT SELECT, INSERT, DELETE           ON public.favorites             TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE   ON public.ai_conversations      TO authenticated;
GRANT SELECT, INSERT, DELETE           ON public.ai_messages           TO authenticated;
GRANT SELECT                           ON public.notifications         TO authenticated;
GRANT UPDATE (is_read)                 ON public.notifications         TO authenticated;  -- column-level: only is_read
GRANT SELECT, INSERT                   ON public.recommendation_events TO authenticated;
GRANT SELECT                           ON public.security_events       TO authenticated;  -- writes: log_security_event() only


-- ==============================================================================
-- 6. ROW LEVEL SECURITY
-- ==============================================================================

-- 6.1 RLS on, everywhere.
ALTER TABLE public.profiles              ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.vehicles              ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.parking_lots          ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.parking_spaces        ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.parking_schedules     ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reservations          ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payments              ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reviews               ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.favorites             ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications         ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ai_conversations      ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ai_messages           ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.recommendation_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.security_events       ENABLE ROW LEVEL SECURITY;

-- 6.2 Drop EVERY existing policy on those tables. Policies are permissive and OR
--     together, so one leftover from the initial schema (e.g. "Users can create
--     reservations", "Public can view parking spaces") would silently defeat the
--     rules below.
DO $$
DECLARE
  r record;
BEGIN
  FOR r IN
    SELECT schemaname, tablename, policyname
    FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename IN (
        'profiles', 'vehicles', 'parking_lots', 'parking_spaces', 'parking_schedules',
        'reservations', 'payments', 'reviews', 'favorites', 'notifications',
        'ai_conversations', 'ai_messages', 'recommendation_events', 'security_events'
      )
  LOOP
    EXECUTE format('DROP POLICY %I ON %I.%I', r.policyname, r.schemaname, r.tablename);
  END LOOP;
END;
$$;

-- ------------------------------------------------------------------ profiles --
-- No INSERT policy: profiles are created only by handle_new_user().
CREATE POLICY profiles_select_own ON public.profiles
  FOR SELECT TO authenticated
  USING (id = (SELECT auth.uid()));

CREATE POLICY profiles_select_admin ON public.profiles
  FOR SELECT TO authenticated
  USING ((SELECT public.is_admin()));

CREATE POLICY profiles_update_own ON public.profiles
  FOR UPDATE TO authenticated
  USING (id = (SELECT auth.uid()))
  WITH CHECK (id = (SELECT auth.uid()));          -- role is guarded by protect_profile_role

CREATE POLICY profiles_update_admin ON public.profiles
  FOR UPDATE TO authenticated
  USING ((SELECT public.is_admin()))
  WITH CHECK ((SELECT public.is_admin()));

-- ------------------------------------------------------------------ vehicles --
CREATE POLICY vehicles_select_own ON public.vehicles
  FOR SELECT TO authenticated
  USING (user_id = (SELECT auth.uid()));

CREATE POLICY vehicles_insert_own ON public.vehicles
  FOR INSERT TO authenticated
  WITH CHECK (user_id = (SELECT auth.uid()));

CREATE POLICY vehicles_update_own ON public.vehicles
  FOR UPDATE TO authenticated
  USING (user_id = (SELECT auth.uid()))
  WITH CHECK (user_id = (SELECT auth.uid()));

CREATE POLICY vehicles_delete_own ON public.vehicles
  FOR DELETE TO authenticated
  USING (user_id = (SELECT auth.uid()));

CREATE POLICY vehicles_select_admin ON public.vehicles
  FOR SELECT TO authenticated
  USING ((SELECT public.is_admin()));

-- -------------------------------------------------------------- parking_lots --
CREATE POLICY parking_lots_select_active ON public.parking_lots
  FOR SELECT TO authenticated
  USING (status = 'active');

CREATE POLICY parking_lots_select_own ON public.parking_lots
  FOR SELECT TO authenticated
  USING (owner_id = (SELECT auth.uid()));

CREATE POLICY parking_lots_insert_owner ON public.parking_lots
  FOR INSERT TO authenticated
  WITH CHECK (owner_id = (SELECT auth.uid()) AND (SELECT public.is_parking_owner()));

CREATE POLICY parking_lots_update_owner ON public.parking_lots
  FOR UPDATE TO authenticated
  USING (owner_id = (SELECT auth.uid()) AND (SELECT public.is_parking_owner()))
  WITH CHECK (owner_id = (SELECT auth.uid()) AND (SELECT public.is_parking_owner()));

CREATE POLICY parking_lots_delete_owner ON public.parking_lots
  FOR DELETE TO authenticated
  USING (owner_id = (SELECT auth.uid()) AND (SELECT public.is_parking_owner()));

CREATE POLICY parking_lots_admin_all ON public.parking_lots
  FOR ALL TO authenticated
  USING ((SELECT public.is_admin()))
  WITH CHECK ((SELECT public.is_admin()));

-- ------------------------------------------------------------ parking_spaces --
-- "Visible" means: the parent lot is visible to the caller. The EXISTS subquery
-- runs under the caller's RLS on parking_lots, so visibility has one source of truth.
CREATE POLICY parking_spaces_select_visible ON public.parking_spaces
  FOR SELECT TO authenticated
  USING (EXISTS (
    SELECT 1 FROM public.parking_lots l WHERE l.id = parking_spaces.parking_lot_id
  ));

CREATE POLICY parking_spaces_insert_owner ON public.parking_spaces
  FOR INSERT TO authenticated
  WITH CHECK ((SELECT public.owns_parking_lot(parking_lot_id)));

CREATE POLICY parking_spaces_update_owner ON public.parking_spaces
  FOR UPDATE TO authenticated
  USING ((SELECT public.owns_parking_lot(parking_lot_id)))
  WITH CHECK ((SELECT public.owns_parking_lot(parking_lot_id)));

CREATE POLICY parking_spaces_delete_owner ON public.parking_spaces
  FOR DELETE TO authenticated
  USING ((SELECT public.owns_parking_lot(parking_lot_id)));

CREATE POLICY parking_spaces_admin_all ON public.parking_spaces
  FOR ALL TO authenticated
  USING ((SELECT public.is_admin()))
  WITH CHECK ((SELECT public.is_admin()));

-- --------------------------------------------------------- parking_schedules --
CREATE POLICY parking_schedules_select_visible ON public.parking_schedules
  FOR SELECT TO authenticated
  USING (EXISTS (
    SELECT 1 FROM public.parking_lots l WHERE l.id = parking_schedules.parking_lot_id
  ));

CREATE POLICY parking_schedules_insert_owner ON public.parking_schedules
  FOR INSERT TO authenticated
  WITH CHECK ((SELECT public.owns_parking_lot(parking_lot_id)));

CREATE POLICY parking_schedules_update_owner ON public.parking_schedules
  FOR UPDATE TO authenticated
  USING ((SELECT public.owns_parking_lot(parking_lot_id)))
  WITH CHECK ((SELECT public.owns_parking_lot(parking_lot_id)));

CREATE POLICY parking_schedules_delete_owner ON public.parking_schedules
  FOR DELETE TO authenticated
  USING ((SELECT public.owns_parking_lot(parking_lot_id)));

CREATE POLICY parking_schedules_admin_all ON public.parking_schedules
  FOR ALL TO authenticated
  USING ((SELECT public.is_admin()))
  WITH CHECK ((SELECT public.is_admin()));

-- -------------------------------------------------------------- reservations --
-- SELECT only. No INSERT/UPDATE/DELETE grant and no policy: writes go through RPCs.
CREATE POLICY reservations_select_own ON public.reservations
  FOR SELECT TO authenticated
  USING (user_id = (SELECT auth.uid()));

CREATE POLICY reservations_select_lot_owner ON public.reservations
  FOR SELECT TO authenticated
  USING ((SELECT public.owns_parking_lot(parking_lot_id)));

CREATE POLICY reservations_select_admin ON public.reservations
  FOR SELECT TO authenticated
  USING ((SELECT public.is_admin()));

-- ------------------------------------------------------------------ payments --
-- SELECT only. No client writes.
CREATE POLICY payments_select_own ON public.payments
  FOR SELECT TO authenticated
  USING (EXISTS (
    SELECT 1
    FROM public.reservations r
    WHERE r.id = payments.reservation_id
      AND r.user_id = (SELECT auth.uid())
  ));

CREATE POLICY payments_select_lot_owner ON public.payments
  FOR SELECT TO authenticated
  USING (EXISTS (
    SELECT 1
    FROM public.reservations r
    WHERE r.id = payments.reservation_id
      AND (SELECT public.owns_parking_lot(r.parking_lot_id))
  ));

CREATE POLICY payments_select_admin ON public.payments
  FOR SELECT TO authenticated
  USING ((SELECT public.is_admin()));

-- ------------------------------------------------------------------- reviews --
CREATE POLICY reviews_select_authenticated ON public.reviews
  FOR SELECT TO authenticated
  USING (true);

-- Only for the caller's OWN, COMPLETED reservation, and only for that reservation's lot.
CREATE POLICY reviews_insert_own_completed ON public.reviews
  FOR INSERT TO authenticated
  WITH CHECK (
    user_id = (SELECT auth.uid())
    AND EXISTS (
      SELECT 1
      FROM public.reservations r
      WHERE r.id = reviews.reservation_id
        AND r.user_id = (SELECT auth.uid())
        AND r.status = 'completed'
        AND r.parking_lot_id = reviews.parking_lot_id
    )
  );

CREATE POLICY reviews_update_admin ON public.reviews
  FOR UPDATE TO authenticated
  USING ((SELECT public.is_admin()))
  WITH CHECK ((SELECT public.is_admin()));

CREATE POLICY reviews_delete_admin ON public.reviews
  FOR DELETE TO authenticated
  USING ((SELECT public.is_admin()));

-- ----------------------------------------------------------------- favorites --
CREATE POLICY favorites_select_own ON public.favorites
  FOR SELECT TO authenticated
  USING (user_id = (SELECT auth.uid()));

CREATE POLICY favorites_insert_own ON public.favorites
  FOR INSERT TO authenticated
  WITH CHECK (user_id = (SELECT auth.uid()));

CREATE POLICY favorites_delete_own ON public.favorites
  FOR DELETE TO authenticated
  USING (user_id = (SELECT auth.uid()));

-- ---------------------------------------------------------- ai_conversations --
CREATE POLICY ai_conversations_select_own ON public.ai_conversations
  FOR SELECT TO authenticated
  USING (user_id = (SELECT auth.uid()));

CREATE POLICY ai_conversations_insert_own ON public.ai_conversations
  FOR INSERT TO authenticated
  WITH CHECK (user_id = (SELECT auth.uid()));

CREATE POLICY ai_conversations_update_own ON public.ai_conversations
  FOR UPDATE TO authenticated
  USING (user_id = (SELECT auth.uid()))
  WITH CHECK (user_id = (SELECT auth.uid()));

CREATE POLICY ai_conversations_delete_own ON public.ai_conversations
  FOR DELETE TO authenticated
  USING (user_id = (SELECT auth.uid()));

-- --------------------------------------------------------------- ai_messages --
CREATE POLICY ai_messages_select_own ON public.ai_messages
  FOR SELECT TO authenticated
  USING (EXISTS (
    SELECT 1 FROM public.ai_conversations c
    WHERE c.id = ai_messages.conversation_id
      AND c.user_id = (SELECT auth.uid())
  ));

CREATE POLICY ai_messages_insert_own ON public.ai_messages
  FOR INSERT TO authenticated
  WITH CHECK (EXISTS (
    SELECT 1 FROM public.ai_conversations c
    WHERE c.id = ai_messages.conversation_id
      AND c.user_id = (SELECT auth.uid())
  ));

CREATE POLICY ai_messages_delete_own ON public.ai_messages
  FOR DELETE TO authenticated
  USING (EXISTS (
    SELECT 1 FROM public.ai_conversations c
    WHERE c.id = ai_messages.conversation_id
      AND c.user_id = (SELECT auth.uid())
  ));

-- ------------------------------------------------------------- notifications --
-- Inserts are server-only (no INSERT grant/policy). The UPDATE grant is column-level
-- (is_read), so title/message/type/user_id can never be rewritten by the client.
CREATE POLICY notifications_select_own ON public.notifications
  FOR SELECT TO authenticated
  USING (user_id = (SELECT auth.uid()));

CREATE POLICY notifications_update_own ON public.notifications
  FOR UPDATE TO authenticated
  USING (user_id = (SELECT auth.uid()))
  WITH CHECK (user_id = (SELECT auth.uid()));

-- ----------------------------------------------------- recommendation_events --
CREATE POLICY recommendation_events_insert_own ON public.recommendation_events
  FOR INSERT TO authenticated
  WITH CHECK (user_id = (SELECT auth.uid()));

CREATE POLICY recommendation_events_select_admin ON public.recommendation_events
  FOR SELECT TO authenticated
  USING ((SELECT public.is_admin()));

-- ----------------------------------------------------------- security_events --
-- No INSERT grant/policy: rows are written only by log_security_event().
CREATE POLICY security_events_select_own ON public.security_events
  FOR SELECT TO authenticated
  USING (user_id = (SELECT auth.uid()));

CREATE POLICY security_events_select_admin ON public.security_events
  FOR SELECT TO authenticated
  USING ((SELECT public.is_admin()));


-- ==============================================================================
-- 7. STORAGE: "avatars" bucket
--    Private bucket. Any authenticated user can read; a user can only write or
--    delete objects inside the folder named after their own user id:
--      avatars/<auth.uid()>/<file>
-- ==============================================================================
INSERT INTO storage.buckets (id, name, public)
VALUES ('avatars', 'avatars', false)
ON CONFLICT (id) DO UPDATE SET public = false;

-- Remove any other policy that already targets this bucket (e.g. a dashboard
-- template such as "Public Access"), otherwise it would OR with the rules below.
DO $$
DECLARE
  r record;
BEGIN
  FOR r IN
    SELECT policyname
    FROM pg_policies
    WHERE schemaname = 'storage'
      AND tablename  = 'objects'
      AND (qual ILIKE '%avatars%' OR with_check ILIKE '%avatars%' OR policyname LIKE 'avatars_%')
  LOOP
    EXECUTE format('DROP POLICY %I ON storage.objects', r.policyname);
  END LOOP;
END;
$$;

CREATE POLICY avatars_select_authenticated ON storage.objects
  FOR SELECT TO authenticated
  USING (bucket_id = 'avatars');

CREATE POLICY avatars_insert_own_folder ON storage.objects
  FOR INSERT TO authenticated
  WITH CHECK (
    bucket_id = 'avatars'
    AND (storage.foldername(name))[1] = (SELECT auth.uid())::text
  );

CREATE POLICY avatars_update_own_folder ON storage.objects
  FOR UPDATE TO authenticated
  USING (
    bucket_id = 'avatars'
    AND (storage.foldername(name))[1] = (SELECT auth.uid())::text
  )
  WITH CHECK (
    bucket_id = 'avatars'
    AND (storage.foldername(name))[1] = (SELECT auth.uid())::text
  );

CREATE POLICY avatars_delete_own_folder ON storage.objects
  FOR DELETE TO authenticated
  USING (
    bucket_id = 'avatars'
    AND (storage.foldername(name))[1] = (SELECT auth.uid())::text
  );


-- ==============================================================================
-- 8. FUTURE 2FA STEP - restrictive AAL2 policies  (COMMENTED OUT ON PURPOSE)
--
--    Syntax verified against the current Supabase docs
--    (Auth > Multi-Factor Authentication > "Enforce rules for MFA logins").
--    A RESTRICTIVE policy is AND-ed with every permissive policy above, so it
--    narrows access regardless of the other rules. Do NOT enable these before the
--    app can enrol and verify a TOTP factor, or every user gets locked out
--    (a normal password session is aal1).
--
--    reservations / payments / vehicles: every command requires aal2.
--    parking_lots: only writes require aal2, so aal1 users can still browse.
-- ==============================================================================

-- CREATE POLICY reservations_require_aal2 ON public.reservations
--   AS RESTRICTIVE FOR ALL TO authenticated
--   USING ((SELECT auth.jwt() ->> 'aal') = 'aal2');
--
-- CREATE POLICY payments_require_aal2 ON public.payments
--   AS RESTRICTIVE FOR ALL TO authenticated
--   USING ((SELECT auth.jwt() ->> 'aal') = 'aal2');
--
-- CREATE POLICY vehicles_require_aal2 ON public.vehicles
--   AS RESTRICTIVE FOR ALL TO authenticated
--   USING ((SELECT auth.jwt() ->> 'aal') = 'aal2');
--
-- CREATE POLICY parking_lots_insert_require_aal2 ON public.parking_lots
--   AS RESTRICTIVE FOR INSERT TO authenticated
--   WITH CHECK ((SELECT auth.jwt() ->> 'aal') = 'aal2');
--
-- CREATE POLICY parking_lots_update_require_aal2 ON public.parking_lots
--   AS RESTRICTIVE FOR UPDATE TO authenticated
--   USING ((SELECT auth.jwt() ->> 'aal') = 'aal2')
--   WITH CHECK ((SELECT auth.jwt() ->> 'aal') = 'aal2');
--
-- CREATE POLICY parking_lots_delete_require_aal2 ON public.parking_lots
--   AS RESTRICTIVE FOR DELETE TO authenticated
--   USING ((SELECT auth.jwt() ->> 'aal') = 'aal2');


-- ==============================================================================
-- 9. POST-MIGRATION AUDIT NOTICE
--    The previous handle_new_user() copied raw_user_meta_data->>'role' verbatim
--    and the table CHECK allows 'admin', so before this migration ANY visitor
--    could sign up as an admin. Existing admins are NOT demoted automatically
--    (that could lock out a legitimate admin): review them.
-- ==============================================================================
DO $$
DECLARE
  v_admins integer;
BEGIN
  SELECT count(*) INTO v_admins FROM public.profiles WHERE role = 'admin';
  IF v_admins > 0 THEN
    RAISE NOTICE '006_security: % profile(s) currently have role=admin. Review them: SELECT id, full_name, created_at FROM public.profiles WHERE role = ''admin'';', v_admins;
  END IF;
END;
$$;
