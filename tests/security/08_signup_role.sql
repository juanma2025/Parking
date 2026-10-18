-- ==============================================================================
-- 08_signup_role.sql
-- Verify safe profile creation trigger (handle_new_user):
-- - A signup with role "admin" in metadata becomes vehicle_owner.
-- - A signup with role "parking_owner" becomes parking_owner.
-- - A signup with missing full_name falls back to email prefix before "@".
-- - An invalid role becomes vehicle_owner.
-- ==============================================================================

BEGIN;

DO $$
DECLARE
  v_fake_user_1 uuid := gen_random_uuid();
  v_fake_user_2 uuid := gen_random_uuid();
  v_fake_user_3 uuid := gen_random_uuid();
  v_profile_1 record;
  v_profile_2 record;
  v_profile_3 record;
BEGIN
  -- 1. Attacker signs up with role="admin" and missing full_name
  INSERT INTO auth.users (id, email, raw_user_meta_data)
  VALUES (
    v_fake_user_1,
    'attacker@darknet.org',
    '{"role": "admin", "phone": "12345"}'::jsonb
  );

  SELECT * INTO v_profile_1 FROM public.profiles WHERE id = v_fake_user_1;
  IF v_profile_1.role <> 'vehicle_owner' THEN
    RAISE EXCEPTION 'Vulnerability: Signup with role=admin should become vehicle_owner, but got %', v_profile_1.role;
  END IF;

  IF v_profile_1.full_name <> 'attacker' THEN
    RAISE EXCEPTION 'Fallback name should be attacker, but got %', v_profile_1.full_name;
  END IF;

  -- 2. Legitimate parking owner signs up
  INSERT INTO auth.users (id, email, raw_user_meta_data)
  VALUES (
    v_fake_user_2,
    'owner@garages.com',
    '{"role": "parking_owner", "full_name": "Garaje Central"}'::jsonb
  );

  SELECT * INTO v_profile_2 FROM public.profiles WHERE id = v_fake_user_2;
  IF v_profile_2.role <> 'parking_owner' THEN
    RAISE EXCEPTION 'Signup with role=parking_owner should be preserved, but got %', v_profile_2.role;
  END IF;

  IF v_profile_2.full_name <> 'Garaje Central' THEN
    RAISE EXCEPTION 'Full name should be preserved, but got %', v_profile_2.full_name;
  END IF;

  -- 3. Signup with bogus role
  INSERT INTO auth.users (id, email, raw_user_meta_data)
  VALUES (
    v_fake_user_3,
    'random@user.com',
    '{"role": "superhacker", "full_name": "Random User"}'::jsonb
  );

  SELECT * INTO v_profile_3 FROM public.profiles WHERE id = v_fake_user_3;
  IF v_profile_3.role <> 'vehicle_owner' THEN
    RAISE EXCEPTION 'Bogus role should default to vehicle_owner, but got %', v_profile_3.role;
  END IF;

  RAISE NOTICE '08_signup_role: PASSED';
END;
$$;

ROLLBACK;
