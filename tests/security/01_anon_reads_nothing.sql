-- ==============================================================================
-- 01_anon_reads_nothing.sql
-- Verify that anonymous / unauthenticated users cannot read any public tables.
-- ==============================================================================

BEGIN;

DO $$
DECLARE
  v_count integer;
  v_err boolean := false;
BEGIN
  -- Switch to anon role
  SET LOCAL ROLE anon;
  SET LOCAL "request.jwt.claims" = '{"role": "anon"}';

  -- 1. profiles
  BEGIN
    SELECT count(*) INTO v_count FROM public.profiles;
    RAISE EXCEPTION 'anon should not be able to SELECT profiles';
  EXCEPTION WHEN insufficient_privilege THEN
    -- Expected: permission denied
  END;

  -- 2. vehicles
  BEGIN
    SELECT count(*) INTO v_count FROM public.vehicles;
    RAISE EXCEPTION 'anon should not be able to SELECT vehicles';
  EXCEPTION WHEN insufficient_privilege THEN
    -- Expected: permission denied
  END;

  -- 3. parking_lots
  BEGIN
    SELECT count(*) INTO v_count FROM public.parking_lots;
    RAISE EXCEPTION 'anon should not be able to SELECT parking_lots';
  EXCEPTION WHEN insufficient_privilege THEN
    -- Expected: permission denied
  END;

  -- 4. reservations
  BEGIN
    SELECT count(*) INTO v_count FROM public.reservations;
    RAISE EXCEPTION 'anon should not be able to SELECT reservations';
  EXCEPTION WHEN insufficient_privilege THEN
    -- Expected: permission denied
  END;

  -- 5. payments
  BEGIN
    SELECT count(*) INTO v_count FROM public.payments;
    RAISE EXCEPTION 'anon should not be able to SELECT payments';
  EXCEPTION WHEN insufficient_privilege THEN
    -- Expected: permission denied
  END;

  -- 6. security_events
  BEGIN
    SELECT count(*) INTO v_count FROM public.security_events;
    RAISE EXCEPTION 'anon should not be able to SELECT security_events';
  EXCEPTION WHEN insufficient_privilege THEN
    -- Expected: permission denied
  END;

  RAISE NOTICE '01_anon_reads_nothing: PASSED (all SELECTs denied)';
END;
$$;

ROLLBACK;
