-- Create FDW extension and set up foreign tables
CREATE EXTENSION IF NOT EXISTS postgres_fdw;

-- Set up foreign data wrappers for shards
CREATE SERVER IF NOT EXISTS shard1 FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host 'postgresql-b1', dbname 'books_db_1', port '5432');
CREATE SERVER IF NOT EXISTS shard2 FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host 'postgresql-b2', dbname 'books_db_2', port '5432');

GRANT USAGE ON FOREIGN SERVER shard1 TO "user";
GRANT USAGE ON FOREIGN SERVER shard2 TO "user";

-- Create user mappings for foreign servers
CREATE USER MAPPING IF NOT EXISTS FOR "user" SERVER shard1 OPTIONS (user 'user', password 'password');
CREATE USER MAPPING IF NOT EXISTS FOR "user" SERVER shard2 OPTIONS (user 'user', password 'password');

-- Drop unique constraints and indexes that may cause issues with foreign partitions
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'books_pkey') THEN
        EXECUTE 'ALTER TABLE books DROP CONSTRAINT books_pkey';
    END IF;

    IF EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'books_unique_idx') THEN
        EXECUTE 'DROP INDEX books_unique_idx';
    END IF;
END $$;

-- Create partitioned table (without unique constraints initially)
CREATE TABLE books (
    id SERIAL,
    title VARCHAR(255),
    author VARCHAR(255),
    published DATE
) PARTITION BY RANGE (id);

-- Define foreign partitions
CREATE FOREIGN TABLE books_1 PARTITION OF books FOR VALUES FROM (1) TO (500000) SERVER shard1 OPTIONS (schema_name 'public');
CREATE FOREIGN TABLE books_2 PARTITION OF books FOR VALUES FROM (500001) TO (1000000) SERVER shard2 OPTIONS (schema_name 'public');

-- Grant privileges on all tables in schema public to user
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO "user";

