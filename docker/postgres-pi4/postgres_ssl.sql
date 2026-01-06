-- Postgres SSL configuration applied during initialization
-- This script will be executed by the official postgres image during init
ALTER SYSTEM SET ssl = 'on';
ALTER SYSTEM SET ssl_cert_file = 'server.crt';
ALTER SYSTEM SET ssl_key_file = 'server.key';
SELECT pg_reload_conf();
