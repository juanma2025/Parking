-- ==============================================================================
-- 06_direct_writes_denied.sql
-- Verify that direct client writes are denied for RPC/server managed tables:
-- - Direct INSERT into reservations denied.
-- - Direct INSERT into payments denied.
-- - Direct INSERT into security_events denied (only via log_security_event).
-- - Column-level grant on notifications: UPDATE is_read allowed, other columns denied.
-- ==============================================================================

BEGIN;

DO $$
DECLARE
  v_user uuid := 'a0000000-0000-4000-8000-00000000000a'::uuid;
  v_notif_id uuid;
  v_count integer;
BEGIN
  -- Setup profile & notification as admin
  INSERT INTO public.profiles (id, full_name, role) VALUES (v_user, 'Standard User', 'vehicle_owner')
  ON CONFLICT (id) DO NOTHING;

  INSERT INTO public.notifications (user_id, title, message, type)
  VALUES (v_user, 'Welcome', 'Welcome to parking app', 'info')
  RETURNING id INTO v_notif_id;

  -- Switch to authenticated user
  SET LOCAL ROLE authenticated;
  PERFORM set_config('request.jwt.claims', format('{"sub": "%s", "role": "authenticated"}', v_user), true);

  -- 1. Direct INSERT into reservations
  BEGIN
    INSERT INTO public.reservations (user_id, parking_lot_id, parking_space_id, vehicle_id, start_time, end_time, total_price)
    VALUES (v_user, gen_random_uuid(), gen_random_uuid(), gen_random_uuid(), now(), now(), 1000);
    RAISE EXCEPTION 'Direct INSERT into reservations should be DENIED';
  EXCEPTION WHEN insufficient_privilege THEN
    -- Expected: permission denied
  END;

  -- 2. Direct INSERT into payments
  BEGIN
    INSERT INTO public.payments (reservation_id, amount)
    VALUES (gen_random_uuid(), 5000);
    RAISE EXCEPTION 'Direct INSERT into payments should be DENIED';
  EXCEPTION WHEN insufficient_privilege THEN
    -- Expected: permission denied
  END;

  -- 3. Direct INSERT into security_events
  BEGIN
    INSERT INTO public.security_events (user_id, event_type)
    VALUES (v_user, 'tamper_attempt');
    RAISE EXCEPTION 'Direct INSERT into security_events should be DENIED';
  EXCEPTION WHEN insufficient_privilege THEN
    -- Expected: permission denied
  END;

  -- 4. INSERT via log_security_event RPC -> SUCCEEDS
  PERFORM public.log_security_event('login', 'Pixel 8');
  SELECT count(*) INTO v_count FROM public.security_events WHERE user_id = v_user AND event_type = 'login';
  IF v_count <> 1 THEN
    RAISE EXCEPTION 'log_security_event RPC should have inserted an audit event';
  END IF;

  -- 5. Notifications: UPDATE is_read is permitted
  UPDATE public.notifications SET is_read = true WHERE id = v_notif_id;

  -- Notifications: UPDATE title (tampering) is DENIED by column-level grant
  BEGIN
    UPDATE public.notifications SET title = 'Forged Notification' WHERE id = v_notif_id;
    RAISE EXCEPTION 'Column tampering on notifications should be DENIED';
  EXCEPTION WHEN insufficient_privilege THEN
    -- Expected: 42501 permission denied for column title
  END;

  RAISE NOTICE '06_direct_writes_denied: PASSED';
END;
$$;

ROLLBACK;
