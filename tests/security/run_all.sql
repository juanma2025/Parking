-- ==============================================================================
-- run_all.sql
-- Master runner executing all security test suites.
-- Runs inside a single transaction that ROLLBACKs at the end.
-- ==============================================================================

BEGIN;

\ir 01_anon_reads_nothing.sql
\ir 02_vehicles_isolation.sql
\ir 03_reservations_isolation.sql
\ir 04_parking_lots_roles.sql
\ir 05_profile_role_guard.sql
\ir 06_direct_writes_denied.sql
\ir 07_storage_avatars.sql
\ir 08_signup_role.sql

ROLLBACK;
