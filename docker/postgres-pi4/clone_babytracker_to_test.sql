-- Post-initialization script to clone babytracker data to babytracker_test
-- This script should be run AFTER the postgres container is fully initialized
-- and the init_db.sql script has completed.

-- Dump and restore babytracker to babytracker_test
-- Note: This uses pg_dump/psql internally via shell commands
-- Alternative: Use Ansible or a container hook to run this after DB is ready

-- Optional: Clear target database first if re-running
-- DROP DATABASE IF EXISTS babytracker_test;
-- CREATE DATABASE babytracker_test OWNER babytracker_test;

-- Copy schema and data from babytracker to babytracker_test
-- This must be run via shell: pg_dump babytracker | psql babytracker_test
-- OR via Ansible task after DB initialization is complete
