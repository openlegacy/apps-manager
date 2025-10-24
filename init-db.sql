-- Create databases for OpenLegacy services
-- This script runs automatically on first PostgreSQL startup

-- Create termiq database
CREATE DATABASE termiq;

-- Grant all privileges to postgres user (already default, but explicit)
GRANT ALL PRIVILEGES ON DATABASE termiq TO postgres;

