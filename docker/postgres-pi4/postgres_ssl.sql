-- Postgres SSL configuration applied during initialization
-- This script will be executed by the official postgres image during init
ALTER SYSTEM SET ssl = 'on';
-- Use absolute paths to the certs mounted from the `postgres_certs` volume
ALTER SYSTEM SET ssl_cert_file = '/var/lib/postgresql/certs/server.crt';
ALTER SYSTEM SET ssl_key_file = '/var/lib/postgresql/certs/server.key';
SELECT pg_reload_conf();
