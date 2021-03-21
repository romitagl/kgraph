-- DEVELOPER CHANGES - FIX gen_random_uuid() does not exist:
-- DROP EXTENSION IF EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS pgcrypto; -- to use gen_random_uuid
