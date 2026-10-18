-- ==============================================================================
-- ALL SECURITY TESTS (01 - 08)
-- Runs in a transaction and rolls back at the end.
-- ==============================================================================

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'profiles' AND policyname = 'profiles_update_admin'
  ) THEN
    CREATE POLICY profiles_update_admin ON public.profiles
      FOR UPDATE TO authenticated
      USING ((SELECT public.is_admin()))
      WITH CHECK ((SELECT public.is_admin()));
  END IF;
END;
$$;

BEGIN;

-- ------------------------------------------------------------------------------
-- TEST 01: anon reads nothing
-- ------------------------------------------------------------------------------
DO $$
DECLARE
  v_count integer;
BEGIN
  SET LOCAL ROLE anon;
  SET LOCAL "request.jwt.claims" = '{"role": "anon"}';

  BEGIN
    SELECT count(*) INTO v_count FROM public.profiles;
    RAISE EXCEPTION 'anon should not be able to SELECT profiles';
  EXCEPTION WHEN insufficient_privilege THEN
  END;

  BEGIN
    SELECT count(*) INTO v_count FROM public.vehicles;
    RAISE EXCEPTION 'anon should not be able to SELECT vehicles';
  EXCEPTION WHEN insufficient_privilege THEN
  END;

  BEGIN
    SELECT count(*) INTO v_count FROM public.parking_lots;
    RAISE EXCEPTION 'anon should not be able to SELECT parking_lots';
  EXCEPTION WHEN insufficient_privilege THEN
  END;

  BEGIN
    SELECT count(*) INTO v_count FROM public.reservations;
    RAISE EXCEPTION 'anon should not be able to SELECT reservations';
  EXCEPTION WHEN insufficient_privilege THEN
  END;

  RAISE NOTICE '01_anon_reads_nothing: PASSED';
END;
$$;

-- ------------------------------------------------------------------------------
-- TEST 02: vehicles isolation
-- ------------------------------------------------------------------------------
DO $$
DECLARE
  v_user_a uuid := 'a0000000-0000-4000-8000-00000000000a'::uuid;
  v_user_b uuid := 'b0000000-0000-4000-8000-00000000000b'::uuid;
  v_veh_b_id uuid;
  v_count integer;
  v_updated integer;
BEGIN
  RESET ROLE;
  PERFORM set_config('request.jwt.claims', '', true);

  INSERT INTO auth.users (id, email, raw_user_meta_data) VALUES 
    (v_user_a, 'user_a@test.com', '{"role":"vehicle_owner","full_name":"User A"}'::jsonb),
    (v_user_b, 'user_b@test.com', '{"role":"vehicle_owner","full_name":"User B"}'::jsonb)
  ON CONFLICT (id) DO NOTHING;

  INSERT INTO public.vehicles (user_id, plate, vehicle_type)
  VALUES (v_user_b, 'XYZ-999', 'car')
  RETURNING id INTO v_veh_b_id;

  SET LOCAL ROLE authenticated;
  PERFORM set_config('request.jwt.claims', format('{"sub": "%s", "role": "authenticated"}', v_user_a), true);

  SELECT count(*) INTO v_count FROM public.vehicles WHERE id = v_veh_b_id;
  IF v_count <> 0 THEN
    RAISE EXCEPTION 'User A was able to SELECT User B vehicle';
  END IF;

  UPDATE public.vehicles SET plate = 'HACKED' WHERE id = v_veh_b_id;
  GET DIAGNOSTICS v_updated = ROW_COUNT;
  IF v_updated <> 0 THEN
    RAISE EXCEPTION 'User A was able to UPDATE User B vehicle';
  END IF;

  DELETE FROM public.vehicles WHERE id = v_veh_b_id;
  GET DIAGNOSTICS v_updated = ROW_COUNT;
  IF v_updated <> 0 THEN
    RAISE EXCEPTION 'User A was able to DELETE User B vehicle';
  END IF;

  INSERT INTO public.vehicles (user_id, plate, vehicle_type)
  VALUES (v_user_a, 'AAA-111', 'car');

  SELECT count(*) INTO v_count FROM public.vehicles WHERE user_id = v_user_a;
  IF v_count <> 1 THEN
    RAISE EXCEPTION 'User A was unable to insert/select own vehicle';
  END IF;

  RAISE NOTICE '02_vehicles_isolation: PASSED';
END;
$$;

-- ------------------------------------------------------------------------------
-- TEST 03: reservations & payments isolation
-- ------------------------------------------------------------------------------
DO $$
DECLARE
  v_user_a uuid := 'a0000000-0000-4000-8000-00000000000a'::uuid;
  v_user_b uuid := 'b0000000-0000-4000-8000-00000000000b'::uuid;
  v_owner_1 uuid := 'c1000000-0000-4000-8000-0000000000c1'::uuid;
  v_owner_2 uuid := 'c2000000-0000-4000-8000-0000000000c2'::uuid;

  v_lot_1_id uuid;
  v_lot_2_id uuid;
  v_space_2_id uuid;
  v_veh_b_id uuid;
  v_res_b_id uuid;
  v_pay_b_id uuid;
  v_count integer;
BEGIN
  RESET ROLE;
  PERFORM set_config('request.jwt.claims', '', true);

  INSERT INTO auth.users (id, email, raw_user_meta_data) VALUES 
    (v_user_a, 'user_a@test.com', '{"role":"vehicle_owner","full_name":"User A"}'::jsonb),
    (v_user_b, 'user_b@test.com', '{"role":"vehicle_owner","full_name":"User B"}'::jsonb),
    (v_owner_1, 'owner_1@test.com', '{"role":"parking_owner","full_name":"Owner 1"}'::jsonb),
    (v_owner_2, 'owner_2@test.com', '{"role":"parking_owner","full_name":"Owner 2"}'::jsonb)
  ON CONFLICT (id) DO NOTHING;

  INSERT INTO public.parking_lots (owner_id, name, address, latitude, longitude, price_per_hour, status)
  VALUES (v_owner_1, 'Lot 1', 'Street 1', 4.60, -74.08, 5000, 'active')
  RETURNING id INTO v_lot_1_id;

  INSERT INTO public.parking_lots (owner_id, name, address, latitude, longitude, price_per_hour, status)
  VALUES (v_owner_2, 'Lot 2', 'Street 2', 4.61, -74.09, 6000, 'active')
  RETURNING id INTO v_lot_2_id;

  INSERT INTO public.parking_spaces (parking_lot_id, space_number, vehicle_type)
  VALUES (v_lot_2_id, '201', 'car') RETURNING id INTO v_space_2_id;

  INSERT INTO public.vehicles (user_id, plate, vehicle_type)
  VALUES (v_user_b, 'RES-999', 'car') RETURNING id INTO v_veh_b_id;

  INSERT INTO public.reservations (
    user_id, parking_lot_id, parking_space_id, vehicle_id, start_time, end_time, total_price, status
  ) VALUES (
    v_user_b, v_lot_2_id, v_space_2_id, v_veh_b_id, now(), now() + interval '2 hours', 12000, 'confirmed'
  ) RETURNING id INTO v_res_b_id;

  INSERT INTO public.payments (reservation_id, amount, status)
  VALUES (v_res_b_id, 12000, 'approved') RETURNING id INTO v_pay_b_id;

  SET LOCAL ROLE authenticated;
  PERFORM set_config('request.jwt.claims', format('{"sub": "%s", "role": "authenticated"}', v_user_a), true);

  SELECT count(*) INTO v_count FROM public.reservations WHERE id = v_res_b_id;
  IF v_count <> 0 THEN
    RAISE EXCEPTION 'User A can see User B reservation';
  END IF;

  SELECT count(*) INTO v_count FROM public.payments WHERE id = v_pay_b_id;
  IF v_count <> 0 THEN
    RAISE EXCEPTION 'User A can see User B payment';
  END IF;

  PERFORM set_config('request.jwt.claims', format('{"sub": "%s", "role": "authenticated"}', v_owner_1), true);

  SELECT count(*) INTO v_count FROM public.reservations WHERE id = v_res_b_id;
  IF v_count <> 0 THEN
    RAISE EXCEPTION 'Owner 1 can see reservation of Lot 2';
  END IF;

  SELECT count(*) INTO v_count FROM public.payments WHERE id = v_pay_b_id;
  IF v_count <> 0 THEN
    RAISE EXCEPTION 'Owner 1 can see payment of Lot 2';
  END IF;

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

-- ------------------------------------------------------------------------------
-- TEST 04: parking lots role restrictions
-- ------------------------------------------------------------------------------
DO $$
DECLARE
  v_driver uuid := 'a0000000-0000-4000-8000-00000000000a'::uuid;
  v_owner  uuid := 'c1000000-0000-4000-8000-0000000000c1'::uuid;
  v_count  integer;
BEGIN
  RESET ROLE;
  PERFORM set_config('request.jwt.claims', '', true);

  INSERT INTO auth.users (id, email, raw_user_meta_data) VALUES 
    (v_driver, 'driver@test.com', '{"role":"vehicle_owner","full_name":"Driver User"}'::jsonb),
    (v_owner, 'owner@test.com', '{"role":"parking_owner","full_name":"Owner User"}'::jsonb)
  ON CONFLICT (id) DO NOTHING;

  SET LOCAL ROLE authenticated;
  PERFORM set_config('request.jwt.claims', format('{"sub": "%s", "role": "authenticated"}', v_driver), true);

  BEGIN
    INSERT INTO public.parking_lots (owner_id, name, address, latitude, longitude, price_per_hour, status)
    VALUES (v_driver, 'Driver Fake Lot', 'Street X', 4.60, -74.08, 5000, 'active');
    RAISE EXCEPTION 'vehicle_owner should NOT be able to insert parking_lots';
  EXCEPTION WHEN insufficient_privilege THEN
  END;

  PERFORM set_config('request.jwt.claims', format('{"sub": "%s", "role": "authenticated"}', v_owner), true);

  BEGIN
    INSERT INTO public.parking_lots (owner_id, name, address, latitude, longitude, price_per_hour, status)
    VALUES (v_driver, 'Spoofed Owner Lot', 'Street Y', 4.60, -74.08, 5000, 'active');
    RAISE EXCEPTION 'parking_owner should NOT be able to insert with another owner_id';
  EXCEPTION WHEN insufficient_privilege THEN
  END;

  INSERT INTO public.parking_lots (owner_id, name, address, latitude, longitude, price_per_hour, status)
  VALUES (v_owner, 'Legit Parking Lot', 'Street Z', 4.60, -74.08, 5000, 'active');

  SELECT count(*) INTO v_count FROM public.parking_lots WHERE owner_id = v_owner AND name = 'Legit Parking Lot';
  IF v_count <> 1 THEN
    RAISE EXCEPTION 'parking_owner should be able to insert their own lot';
  END IF;

  RAISE NOTICE '04_parking_lots_roles: PASSED';
END;
$$;

-- ------------------------------------------------------------------------------
-- TEST 05: profile role guard
-- ------------------------------------------------------------------------------
DO $$
DECLARE
  v_user  uuid := 'a0000000-0000-4000-8000-00000000000a'::uuid;
  v_admin uuid := 'ad000000-0000-4000-8000-0000000000ad'::uuid;
  v_current_role text;
BEGIN
  RESET ROLE;
  PERFORM set_config('request.jwt.claims', '', true);

  INSERT INTO auth.users (id, email, raw_user_meta_data) VALUES 
    (v_user, 'user@test.com', '{"role":"vehicle_owner","full_name":"Standard User"}'::jsonb),
    (v_admin, 'admin@test.com', '{"role":"vehicle_owner","full_name":"Admin User"}'::jsonb)
  ON CONFLICT (id) DO NOTHING;

  -- Admin promoted from SQL Editor (auth.uid() is null)
  UPDATE public.profiles SET role = 'admin' WHERE id = v_admin;

  -- 1. Switch to user
  SET LOCAL ROLE authenticated;
  PERFORM set_config('request.jwt.claims', format('{"sub": "%s", "role": "authenticated"}', v_user), true);

  UPDATE public.profiles SET full_name = 'Updated Name' WHERE id = v_user;

  BEGIN
    UPDATE public.profiles SET role = 'admin' WHERE id = v_user;
    RAISE EXCEPTION 'User should NOT be able to change their own role to admin';
  EXCEPTION WHEN insufficient_privilege THEN
  END;

  BEGIN
    UPDATE public.profiles SET role = 'parking_owner' WHERE id = v_user;
    RAISE EXCEPTION 'User should NOT be able to change their own role to parking_owner';
  EXCEPTION WHEN insufficient_privilege THEN
  END;

  -- 2. Switch to admin
  PERFORM set_config('request.jwt.claims', format('{"sub": "%s", "role": "authenticated"}', v_admin), true);

  UPDATE public.profiles SET role = 'parking_owner' WHERE id = v_user;

  SELECT role INTO v_current_role FROM public.profiles WHERE id = v_user;
  IF v_current_role <> 'parking_owner' THEN
    RAISE EXCEPTION 'Admin should be able to update user role';
  END IF;

  -- 3. SQL editor promotion
  RESET ROLE;
  PERFORM set_config('request.jwt.claims', '', true);

  UPDATE public.profiles SET role = 'admin' WHERE id = v_user;
  SELECT role INTO v_current_role FROM public.profiles WHERE id = v_user;
  IF v_current_role <> 'admin' THEN
    RAISE EXCEPTION 'Direct SQL editor should be able to promote user to admin';
  END IF;

  RAISE NOTICE '05_profile_role_guard: PASSED';
END;
$$;

-- ------------------------------------------------------------------------------
-- TEST 06: direct writes denied
-- ------------------------------------------------------------------------------
DO $$
DECLARE
  v_user uuid := 'a0000000-0000-4000-8000-00000000000a'::uuid;
  v_notif_id uuid;
  v_count integer;
BEGIN
  RESET ROLE;
  PERFORM set_config('request.jwt.claims', '', true);

  INSERT INTO auth.users (id, email, raw_user_meta_data) VALUES 
    (v_user, 'user@test.com', '{"role":"vehicle_owner","full_name":"Standard User"}'::jsonb)
  ON CONFLICT (id) DO NOTHING;

  INSERT INTO public.notifications (user_id, title, message, type)
  VALUES (v_user, 'Welcome', 'Welcome to parking app', 'info')
  RETURNING id INTO v_notif_id;

  SET LOCAL ROLE authenticated;
  PERFORM set_config('request.jwt.claims', format('{"sub": "%s", "role": "authenticated"}', v_user), true);

  BEGIN
    INSERT INTO public.reservations (user_id, parking_lot_id, parking_space_id, vehicle_id, start_time, end_time, total_price)
    VALUES (v_user, gen_random_uuid(), gen_random_uuid(), gen_random_uuid(), now(), now(), 1000);
    RAISE EXCEPTION 'Direct INSERT into reservations should be DENIED';
  EXCEPTION WHEN insufficient_privilege THEN
  END;

  BEGIN
    INSERT INTO public.payments (reservation_id, amount)
    VALUES (gen_random_uuid(), 5000);
    RAISE EXCEPTION 'Direct INSERT into payments should be DENIED';
  EXCEPTION WHEN insufficient_privilege THEN
  END;

  BEGIN
    INSERT INTO public.security_events (user_id, event_type)
    VALUES (v_user, 'tamper_attempt');
    RAISE EXCEPTION 'Direct INSERT into security_events should be DENIED';
  EXCEPTION WHEN insufficient_privilege THEN
  END;

  PERFORM public.log_security_event('login', 'Pixel 8');
  SELECT count(*) INTO v_count FROM public.security_events WHERE user_id = v_user AND event_type = 'login';
  IF v_count <> 1 THEN
    RAISE EXCEPTION 'log_security_event RPC should have inserted an audit event';
  END IF;

  UPDATE public.notifications SET is_read = true WHERE id = v_notif_id;

  BEGIN
    UPDATE public.notifications SET title = 'Forged Notification' WHERE id = v_notif_id;
    RAISE EXCEPTION 'Column tampering on notifications should be DENIED';
  EXCEPTION WHEN insufficient_privilege THEN
  END;

  RAISE NOTICE '06_direct_writes_denied: PASSED';
END;
$$;

-- ------------------------------------------------------------------------------
-- TEST 07: storage avatars
-- ------------------------------------------------------------------------------
DO $$
DECLARE
  v_user_a uuid := 'a0000000-0000-4000-8000-00000000000a'::uuid;
  v_user_b uuid := 'b0000000-0000-4000-8000-00000000000b'::uuid;
  v_count integer;
BEGIN
  SET LOCAL ROLE authenticated;
  PERFORM set_config('request.jwt.claims', format('{"sub": "%s", "role": "authenticated"}', v_user_a), true);

  BEGIN
    INSERT INTO storage.objects (bucket_id, name, owner)
    VALUES ('avatars', format('%s/profile.png', v_user_b), v_user_a);
    RAISE EXCEPTION 'Uploading to another user avatar folder should be DENIED';
  EXCEPTION WHEN insufficient_privilege THEN
  END;

  INSERT INTO storage.objects (bucket_id, name, owner)
  VALUES ('avatars', format('%s/my_avatar.png', v_user_a), v_user_a);

  PERFORM set_config('request.jwt.claims', format('{"sub": "%s", "role": "authenticated"}', v_user_b), true);
  SELECT count(*) INTO v_count FROM storage.objects WHERE bucket_id = 'avatars' AND name = format('%s/my_avatar.png', v_user_a);
  IF v_count <> 1 THEN
    RAISE EXCEPTION 'Authenticated user should be able to read avatars';
  END IF;

  RAISE NOTICE '07_storage_avatars: PASSED';
END;
$$;

-- ------------------------------------------------------------------------------
-- TEST 08: signup role
-- ------------------------------------------------------------------------------
DO $$
DECLARE
  v_fake_user_1 uuid := gen_random_uuid();
  v_fake_user_2 uuid := gen_random_uuid();
  v_profile_1 record;
  v_profile_2 record;
BEGIN
  RESET ROLE;
  PERFORM set_config('request.jwt.claims', '', true);

  INSERT INTO auth.users (id, email, raw_user_meta_data)
  VALUES (
    v_fake_user_1,
    'attacker@darknet.org',
    '{"role": "admin", "phone": "12345"}'::jsonb
  );

  SELECT * INTO v_profile_1 FROM public.profiles WHERE id = v_fake_user_1;
  IF v_profile_1.role <> 'vehicle_owner' THEN
    RAISE EXCEPTION 'Signup with role=admin should become vehicle_owner, but got %', v_profile_1.role;
  END IF;

  IF v_profile_1.full_name <> 'attacker' THEN
    RAISE EXCEPTION 'Fallback name should be attacker, but got %', v_profile_1.full_name;
  END IF;

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

  RAISE NOTICE '08_signup_role: PASSED';
END;
$$;

ROLLBACK;
