-- ==============================================================================
-- 07_storage_avatars.sql
-- Verify storage RLS for "avatars" bucket:
-- - Writing to another user's folder is DENIED.
-- - Writing to own folder is ALLOWED.
-- - Reading avatars is ALLOWED for authenticated users.
-- ==============================================================================

BEGIN;

DO $$
DECLARE
  v_user_a uuid := 'a0000000-0000-4000-8000-00000000000a'::uuid;
  v_user_b uuid := 'b0000000-0000-4000-8000-00000000000b'::uuid;
  v_count integer;
BEGIN
  -- Switch to User A
  SET LOCAL ROLE authenticated;
  PERFORM set_config('request.jwt.claims', format('{"sub": "%s", "role": "authenticated"}', v_user_a), true);

  -- 1. User A attempts to upload into User B's folder -> MUST FAIL
  BEGIN
    INSERT INTO storage.objects (bucket_id, name, owner)
    VALUES ('avatars', format('%s/profile.png', v_user_b), v_user_a);
    RAISE EXCEPTION 'Uploading to another user avatar folder should be DENIED';
  EXCEPTION WHEN insufficient_privilege THEN
    -- Expected: RLS WITH CHECK failure
  END;

  -- 2. User A uploads into own folder -> SUCCEEDS
  INSERT INTO storage.objects (bucket_id, name, owner)
  VALUES ('avatars', format('%s/my_avatar.png', v_user_a), v_user_a);

  -- 3. User B can read User A's avatar (authenticated read)
  PERFORM set_config('request.jwt.claims', format('{"sub": "%s", "role": "authenticated"}', v_user_b), true);
  SELECT count(*) INTO v_count FROM storage.objects WHERE bucket_id = 'avatars' AND name = format('%s/my_avatar.png', v_user_a);
  IF v_count <> 1 THEN
    RAISE EXCEPTION 'Authenticated user should be able to read avatars';
  END IF;

  RAISE NOTICE '07_storage_avatars: PASSED';
END;
$$;

ROLLBACK;
