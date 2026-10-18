-- ==============================================================================
-- supabase_stub.sql
--
-- Minimal imitation of the parts of a Supabase project that the migrations and
-- the security tests rely on. It is applied ONLY to the throw-away local
-- PostgreSQL started by run-local.ps1 (never to a real project).
--
--   * roles anon / authenticated / service_role (+ BYPASSRLS on service_role)
--   * schema auth    : users table, auth.uid(), auth.role(), auth.jwt()
--   * schema storage : buckets, objects (RLS on), foldername()
--   * the default privileges Supabase gives to the `public` schema, so the
--     tests prove that migration 006 really REVOKES them.
--
-- When you run the tests against a real Supabase database (supabase start /
-- db reset) do NOT load this file: the real schemas already exist.
-- ==============================================================================

CREATE ROLE anon          NOLOGIN NOINHERIT;
CREATE ROLE authenticated NOLOGIN NOINHERIT;
CREATE ROLE service_role  NOLOGIN NOINHERIT BYPASSRLS;

CREATE SCHEMA IF NOT EXISTS extensions;
CREATE SCHEMA IF NOT EXISTS auth;
CREATE SCHEMA IF NOT EXISTS storage;

GRANT USAGE ON SCHEMA public, extensions, auth, storage TO anon, authenticated, service_role;

-- ------------------------------------------------------------------ auth ----
CREATE TABLE auth.users (
  id                 uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  email              text,
  raw_user_meta_data jsonb,
  created_at         timestamptz DEFAULT now()
);

CREATE FUNCTION auth.uid() RETURNS uuid
LANGUAGE sql STABLE AS $$
  SELECT coalesce(
    nullif(current_setting('request.jwt.claim.sub', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'sub')
  )::uuid
$$;

CREATE FUNCTION auth.role() RETURNS text
LANGUAGE sql STABLE AS $$
  SELECT coalesce(
    nullif(current_setting('request.jwt.claim.role', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'role')
  )::text
$$;

CREATE FUNCTION auth.jwt() RETURNS jsonb
LANGUAGE sql STABLE AS $$
  SELECT coalesce(
    nullif(current_setting('request.jwt.claim', true), ''),
    nullif(current_setting('request.jwt.claims', true), '')
  )::jsonb
$$;

GRANT SELECT ON auth.users TO service_role;
GRANT EXECUTE ON FUNCTION auth.uid(), auth.role(), auth.jwt() TO anon, authenticated, service_role;

-- --------------------------------------------------------------- storage ----
CREATE TABLE storage.buckets (
  id         text PRIMARY KEY,
  name       text NOT NULL UNIQUE,
  public     boolean DEFAULT false,
  created_at timestamptz DEFAULT now()
);

CREATE TABLE storage.objects (
  id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  bucket_id  text REFERENCES storage.buckets (id),
  name       text,
  owner      uuid,
  created_at timestamptz DEFAULT now()
);
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

CREATE FUNCTION storage.foldername(name text) RETURNS text[]
LANGUAGE plpgsql IMMUTABLE AS $$
DECLARE
  _parts text[];
BEGIN
  SELECT string_to_array(name, '/') INTO _parts;
  RETURN _parts[1:array_length(_parts, 1) - 1];
END
$$;

-- Supabase grants everything on storage tables and relies on RLS alone.
GRANT ALL ON storage.buckets, storage.objects TO anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION storage.foldername(text) TO anon, authenticated, service_role;

-- ---------------------------------------------- default privileges (public) --
-- Supabase ships with these; migration 006 must undo them for anon.
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES    TO anon, authenticated, service_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO anon, authenticated, service_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON FUNCTIONS TO anon, authenticated, service_role;
