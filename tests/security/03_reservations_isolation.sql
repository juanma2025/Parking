-- ==============================================================================
-- 03_reservations_isolation.sql
-- Verify reservation and payment isolation:
-- - User A cannot read User B's reservations or payments.
-- - Owner 1 cannot read Owner 2's reservations or payments.
-- ==============================================================================

BEGIN;

DO $$
DECLARE
  v_user_a uuid := 'a0000000-0000-4000-8000-00000000000a'::uuid;
  v_user_b uuid := 'b0000000-0000-4000-8000-00000000000b'::uuid;
  v_owner_1 uuid := 'c1000000-0000-4000-8000-0000000000c1'::uuid;
  v_owner_2 uuid := 'c2000000-0000-4000-8000-0000000000c2'::uuid;

  v_lot_1_id uuid;
  v_lot_2_id uuid;
  v_space_1_id uuid;
  v_space_2_id uuid;
  v_veh_b_id uuid;
  v_res_b_id uuid;
  v_pay_b_id uuid;
  v_count integer;
BEGIN
  -- Setup profiles
  INSERT INTO public.profiles (id, full_name, role) VALUES 
    (v_user_a, 'User A', 'vehicle_owner'),
    (v_user_b, 'User B', 'vehicle_owner'),
    (v_owner_1, 'Owner 1', 'parking_owner'),
    (v_owner_2, 'Owner 2', 'parking_owner')
  ON CONFLICT (id) DO NOTHING;

  -- Setup lots and spaces
  INSERT INTO public.parking_lots (owner_id, name, address, latitude, longitude, price_per_hour, status)
  VALUES (v_owner_1, 'Lot 1', 'Street 1', 4.60, -74.08, 5000, 'active')
  RETURNING id INTO v_lot_1_id;

  INSERT INTO public.parking_lots (owner_id, name, address, latitude, longitude, price_per_hour, status)
  VALUES (v_owner_2, 'Lot 2', 'Street 2', 4.61, -74.09, 6000, 'active')
  RETURNING id INTO v_lot_2_id;

  INSERT INTO public.parking_spaces (parking_lot_id, space_number, vehicle_type)
  VALUES (v_lot_1_id, '101', 'car') RETURNING id INTO v_space_1_id;

  INSERT INTO public.parking_spaces (parking_lot_id, space_number, vehicle_type)
  VALUES (v_lot_2_id, '201', 'car') RETURNING id INTO v_space_2_id;

  INSERT INTO public.vehicles (user_id, plate, vehicle_type)
  VALUES (v_user_b, 'RES-999', 'car') RETURNING id INTO v_veh_b_id;

  -- Insert reservation & payment for User B at Lot 2 (Owner 2's lot)
  INSERT INTO public.reservations (
    user_id, parking_lot_id, parking_space_id, vehicle_id, start_time, end_time, total_price, status
  ) VALUES (
    v_user_b, v_lot_2_id, v_space_2_id, v_veh_b_id, now(), now() + interval '2 hours', 12000, 'confirmed'
  ) RETURNING id INTO v_res_b_id;

  INSERT INTO public.payments (reservation_id, amount, status)
  VALUES (v_res_b_id, 12000, 'approved') RETURNING id INTO v_pay_b_id;

  -- 1. Switch to User A
  SET LOCAL ROLE authenticated;
  PERFORM set_config('request.jwt.claims', format('{"sub": "%s", "role": "authenticated"}', v_user_a), true);

  SELECT count(*) INTO v_count FROM public.reservations WHERE id = v_res_b_id;
  IF v_count <> 0 THEN
    RAISE EXCEPTION 'Isolation failure: User A can see User B reservation';
  END IF;

  SELECT count(*) INTO v_count FROM public.payments WHERE id = v_pay_b_id;
  IF v_count <> 0 THEN
    RAISE EXCEPTION 'Isolation failure: User A can see User B payment';
  END IF;

  -- 2. Switch to Owner 1 (who does NOT own Lot 2)
  PERFORM set_config('request.jwt.claims', format('{"sub": "%s", "role": "authenticated"}', v_owner_1), true);

  SELECT count(*) INTO v_count FROM public.reservations WHERE id = v_res_b_id;
  IF v_count <> 0 THEN
    RAISE EXCEPTION 'Isolation failure: Owner 1 can see reservation of Lot 2';
  END IF;

  SELECT count(*) INTO v_count FROM public.payments WHERE id = v_pay_b_id;
  IF v_count <> 0 THEN
    RAISE EXCEPTION 'Isolation failure: Owner 1 can see payment of Lot 2';
  END IF;

  -- 3. Switch to Owner 2 (who owns Lot 2) -> CAN see it
  PERFORM set_config('request.jwt.claims', format('{"sub": "%s", "role": "authenticated"}', v_owner_2), true);

  SELECT count(*) INTO v_count FROM public.reservations WHERE id = v_res_b_id;
  IF v_count <> 1 THEN
    RAISE EXCEPTION 'Lot Owner 2 should be able to see reservation for their lot';
  END IF;

  SELECT count(*) INTO v_count FROM public.payments WHERE id = v_pay_b_id;
  IF v_count <> 1 THEN
    RAISE EXCEPTION 'Lot Owner 2 should be able to see payment for their lot';
  END IF;

  RAISE NOTICE '03_reservations_isolation: PASSED';
END;
$$;

ROLLBACK;
