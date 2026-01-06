-- Postgres initialization script
-- Update this file to create additional users/databases on first boot.
-- The postgres Docker image executes any *.sql placed in
-- /docker-entrypoint-initdb.d on database initialization.

-- Example: create a database and user with password (change values):
-- CREATE USER myuser WITH ENCRYPTED PASSWORD 'mypassword';
-- CREATE DATABASE mydb OWNER myuser;
-- GRANT ALL PRIVILEGES ON DATABASE mydb TO myuser;

-- You can add additional CREATE ROLE / CREATE DATABASE statements here.

-- Placeholder: default DB and user are created via container env vars.

-- Idempotent creation of `housefinder` role and database.
-- IMPORTANT: change the password below to a secure value or provision via secrets.
DO
$$
BEGIN
	IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'housefinder') THEN
		CREATE ROLE housefinder WITH LOGIN ENCRYPTED PASSWORD '{{ housefinder_db_password | default(lookup("env","HOUSEFINDER_DB_PASSWORD") | default("change_me_replace")) }}';
	END IF;
END
$$;

DO
$$
BEGIN
	IF NOT EXISTS (SELECT FROM pg_database WHERE datname = 'housefinder') THEN
		CREATE DATABASE housefinder OWNER housefinder;
	END IF;
END
$$;

GRANT ALL PRIVILEGES ON DATABASE housefinder TO housefinder;
