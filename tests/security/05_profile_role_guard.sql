-- ==============================================================================
-- 05_profile_role_guard.sql
-- Verify role-escalation guard (protect_profile_role trigger):
-- - A user cannot change their own role.
-- - An admin can change roles.
-- - When auth.uid() is null (SQL editor / migrations), role changes are allowed.
-- ==============================================================================

BEGIN;

DO $$
DECLARE
  v_user  uuid := 'a0000000-0000-4000-8000-00000000000a'::uuid;
  v_admin uuid := 'ad000000-0000-4000-8000-0000000000ad'::uuid;
  v_current_role text;
BEGIN
  -- Setup profiles
  INSERT INTO public.profiles (id, full_name, role) VALUES 
    (v_user, 'Standard User', 'vehicle_owner'),
    (v_admin, 'Admin User', 'admin')
  ON CONFLICT (id) DO UPDATE SET role = EXCLUDED.role;

  -- 1. Switch to standard user
  SET LOCAL ROLE authenticated;
  PERFORM set_config('request.jwt.claims', format('{"sub": "%s", "role": "authenticated"}', v_user), true);

  -- User can update own full_name
  UPDATE public.profiles SET full_name = 'Updated Name' WHERE id = v_user;

  -- User attempts to escalate own role to admin -> MUST FAIL
  BEGIN
    UPDATE public.profiles SET role = 'admin' WHERE id = v_user;
    RAISE EXCEPTION 'User should NOT be able to change their own role to admin';
  EXCEPTION WHEN insufficient_privilege THEN
    -- Expected: 42501 raised by protect_profile_role trigger
  END;

  -- User attempts to change role to parking_owner -> MUST FAIL
  BEGIN
    UPDATE public.profiles SET role = 'parking_owner' WHERE id = v_user;
    RAISE EXCEPTION 'User should NOT be able to change their own role to parking_owner';
  EXCEPTION WHEN insufficient_privilege THEN
    -- Expected: 42501
  END;

  -- 2. Switch to admin user -> CAN change user's role
  PERFORM set_config('request.jwt.claims', format('{"sub": "%s", "role": "authenticated"}', v_admin), true);

  UPDATE public.profiles SET role = 'parking_owner' WHERE id = v_user;

  SELECT role INTO v_current_role FROM public.profiles WHERE id = v_user;
  IF v_current_role <> 'parking_owner' THEN
    RAISE EXCEPTION 'Admin should be able to update user role';
  END IF;

  -- 3. Reset claims so auth.uid() is null (SQL editor / service_role)
  PERFORM set_config('request.jwt.claims', '', true);
  RESET ROLE;

  UPDATE public.profiles SET role = 'admin' WHERE id = v_user;
  SELECT role INTO v_current_role FROM public.profiles WHERE id = v_user;
  IF v_current_role <> 'admin' THEN
    RAISE EXCEPTION 'Direct SQL editor should be able to promote user to admin';
  END IF;

  RAISE NOTICE '05_profile_role_guard: PASSED';
END;
$$;

ROLLBACK;
