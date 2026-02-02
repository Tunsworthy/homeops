-- Postgres initialization script
-- Update this file to create additional users/databases on first boot.
-- The postgres Docker image executes any *.sql placed in
-- /docker-entrypoint-initdb.d on database initialization.

-- Idempotent creation of `housefinder` role and database.
CREATE ROLE housefinder WITH LOGIN ENCRYPTED PASSWORD '{{ housefinder_db_password | default("change_me_replace") }}';
CREATE DATABASE housefinder OWNER housefinder;
GRANT ALL PRIVILEGES ON DATABASE housefinder TO housefinder;

-- Idempotent creation of `babytracker` role and database.
CREATE ROLE {{ babytracker_db_user | default("babytracker") }} WITH LOGIN ENCRYPTED PASSWORD '{{ babytracker_db_password | default("change_me_replace") }}';
CREATE DATABASE babytracker OWNER {{ babytracker_db_user | default("babytracker") }};
GRANT ALL PRIVILEGES ON DATABASE babytracker TO {{ babytracker_db_user | default("babytracker") }};

CREATE ROLE {{ babytracker_prod_db_user | default("babytracker-prod") }} WITH LOGIN ENCRYPTED PASSWORD '{{ babytracker_prod_db_password | default("change_me_replace") }}';
CREATE DATABASE babytracker OWNER {{ babytracker_prod_db_user | default("babytracker-prod") }};
GRANT ALL PRIVILEGES ON DATABASE babytracker TO {{ babytracker_db_user | default("babytracker-prod") }};