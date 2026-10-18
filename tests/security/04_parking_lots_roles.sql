-- ==============================================================================
-- 04_parking_lots_roles.sql
-- Verify parking_lots role restrictions:
-- - A vehicle_owner cannot insert parking_lots.
-- - A parking_owner can insert parking_lots only with their own owner_id.
-- ==============================================================================

BEGIN;

DO $$
DECLARE
  v_driver uuid := 'a0000000-0000-4000-8000-00000000000a'::uuid;
  v_owner  uuid := 'c1000000-0000-4000-8000-0000000000c1'::uuid;
  v_count  integer;
BEGIN
  -- Setup profiles
  INSERT INTO public.profiles (id, full_name, role) VALUES 
    (v_driver, 'Driver User', 'vehicle_owner'),
    (v_owner, 'Owner User', 'parking_owner')
  ON CONFLICT (id) DO NOTHING;

  -- 1. Switch to vehicle_owner
  SET LOCAL ROLE authenticated;
  PERFORM set_config('request.jwt.claims', format('{"sub": "%s", "role": "authenticated"}', v_driver), true);

  BEGIN
    INSERT INTO public.parking_lots (owner_id, name, address, latitude, longitude, price_per_hour, status)
    VALUES (v_driver, 'Driver Fake Lot', 'Street X', 4.60, -74.08, 5000, 'active');
    RAISE EXCEPTION 'vehicle_owner should NOT be able to insert parking_lots';
  EXCEPTION WHEN insufficient_privilege THEN
    -- Expected: RLS policy WITH CHECK violation
  END;

  -- 2. Switch to parking_owner, but trying to set owner_id = v_driver
  PERFORM set_config('request.jwt.claims', format('{"sub": "%s", "role": "authenticated"}', v_owner), true);

  BEGIN
    INSERT INTO public.parking_lots (owner_id, name, address, latitude, longitude, price_per_hour, status)
    VALUES (v_driver, 'Spoofed Owner Lot', 'Street Y', 4.60, -74.08, 5000, 'active');
    RAISE EXCEPTION 'parking_owner should NOT be able to insert with another owner_id';
  EXCEPTION WHEN insufficient_privilege THEN
    -- Expected: RLS policy WITH CHECK violation
  END;

  -- 3. parking_owner inserts with own owner_id -> SUCCEEDS
  INSERT INTO public.parking_lots (owner_id, name, address, latitude, longitude, price_per_hour, status)
  VALUES (v_owner, 'Legit Parking Lot', 'Street Z', 4.60, -74.08, 5000, 'active');

  SELECT count(*) INTO v_count FROM public.parking_lots WHERE owner_id = v_owner;
  IF v_count <> 1 THEN
    RAISE EXCEPTION 'parking_owner should be able to insert their own lot';
  END IF;

  RAISE NOTICE '04_parking_lots_roles: PASSED';
END;
$$;

ROLLBACK;
