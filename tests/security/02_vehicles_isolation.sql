-- ==============================================================================
-- 02_vehicles_isolation.sql
-- Verify that User A cannot read, update or delete User B's vehicles.
-- ==============================================================================

BEGIN;

DO $$
DECLARE
  v_user_a uuid := 'a0000000-0000-4000-8000-00000000000a'::uuid;
  v_user_b uuid := 'b0000000-0000-4000-8000-00000000000b'::uuid;
  v_veh_b_id uuid;
  v_count integer;
  v_updated integer;
BEGIN
  -- Setup profiles & vehicle as admin/superuser
  INSERT INTO public.profiles (id, full_name, role) VALUES 
    (v_user_a, 'User A', 'vehicle_owner'),
    (v_user_b, 'User B', 'vehicle_owner')
  ON CONFLICT (id) DO NOTHING;

  INSERT INTO public.vehicles (user_id, plate, vehicle_type)
  VALUES (v_user_b, 'XYZ-999', 'car')
  RETURNING id INTO v_veh_b_id;

  -- 1. Switch to User A
  SET LOCAL ROLE authenticated;
  PERFORM set_config('request.jwt.claims', format('{"sub": "%s", "role": "authenticated"}', v_user_a), true);

  -- A cannot SELECT B's vehicle
  SELECT count(*) INTO v_count FROM public.vehicles WHERE id = v_veh_b_id;
  IF v_count <> 0 THEN
    RAISE EXCEPTION 'Isolation failure: User A was able to SELECT User B vehicle';
  END IF;

  -- A cannot UPDATE B's vehicle (RLS blocks row, updates 0 rows)
  UPDATE public.vehicles SET plate = 'HACKED' WHERE id = v_veh_b_id;
  GET DIAGNOSTICS v_updated = ROW_COUNT;
  IF v_updated <> 0 THEN
    RAISE EXCEPTION 'Isolation failure: User A was able to UPDATE User B vehicle';
  END IF;

  -- A cannot DELETE B's vehicle
  DELETE FROM public.vehicles WHERE id = v_veh_b_id;
  GET DIAGNOSTICS v_updated = ROW_COUNT;
  IF v_updated <> 0 THEN
    RAISE EXCEPTION 'Isolation failure: User A was able to DELETE User B vehicle';
  END IF;

  -- A CAN insert and read own vehicle
  INSERT INTO public.vehicles (user_id, plate, vehicle_type)
  VALUES (v_user_a, 'AAA-111', 'car');

  SELECT count(*) INTO v_count FROM public.vehicles WHERE user_id = v_user_a;
  IF v_count <> 1 THEN
    RAISE EXCEPTION 'User A was unable to insert/select own vehicle';
  END IF;

  RAISE NOTICE '02_vehicles_isolation: PASSED';
END;
$$;

ROLLBACK;
