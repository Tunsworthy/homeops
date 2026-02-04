-- Postgres initialization script
-- Update this file to create additional users/databases on first boot.
-- The postgres Docker image executes any *.sql placed in
-- /docker-entrypoint-initdb.d on database initialization.

-- Idempotent creation of `housefinder` role and database.
CREATE ROLE IF NOT EXISTS housefinder WITH LOGIN ENCRYPTED PASSWORD '{{ housefinder_db_password | default("change_me_replace") }}';
CREATE DATABASE IF NOT EXISTS housefinder OWNER housefinder;
GRANT ALL PRIVILEGES ON DATABASE housefinder TO housefinder;

-- Idempotent creation of `babytracker` role and database.
CREATE ROLE IF NOT EXISTS {{ babytracker_db_user | default("babytracker") }} WITH LOGIN ENCRYPTED PASSWORD '{{ babytracker_db_password | default("change_me_replace") }}';
CREATE DATABASE IF NOT EXISTS babytracker OWNER {{ babytracker_db_user | default("babytracker") }};
GRANT ALL PRIVILEGES ON DATABASE babytracker TO {{ babytracker_db_user | default("babytracker") }};

-- Idempotent creation of `babytracker_test` role and database (empty - data cloned separately).
CREATE ROLE IF NOT EXISTS {{ babytracker_test_db_user | default("babytracker_test") }} WITH LOGIN ENCRYPTED PASSWORD '{{ babytracker_test_db_password | default("change_me_replace") }}';
CREATE DATABASE IF NOT EXISTS babytracker_test OWNER {{ babytracker_test_db_user | default("babytracker_test") }};
GRANT ALL PRIVILEGES ON DATABASE babytracker_test TO {{ babytracker_test_db_user | default("babytracker_test") }};

CREATE ROLE IF NOT EXISTS {{ babytracker_prod_db_user | default("babytracker_prod") }} WITH LOGIN ENCRYPTED PASSWORD '{{ babytracker_prod_db_password | default("change_me_replace") }}';
CREATE DATABASE IF NOT EXISTS babytracker_prod OWNER {{ babytracker_prod_db_user | default("babytracker_prod") }};
GRANT ALL PRIVILEGES ON DATABASE babytracker_prod TO {{ babytracker_prod_db_user | default("babytracker_prod") }};