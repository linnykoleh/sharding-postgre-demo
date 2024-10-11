-- Create Citus extension for distributed tables
CREATE EXTENSION IF NOT EXISTS citus;

-- Create worker nodes for Citus cluster (using Citus functions instead of FDW)
-- Add worker nodes to Citus cluster
SELECT * FROM master_add_node('postgresql-b1', 5432);
SELECT * FROM master_add_node('postgresql-b2', 5432);

-- Create the main table and distribute it using Citus
CREATE TABLE books (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255),
    author VARCHAR(255),
    published DATE
);

-- Distribute the table across worker nodes by range (partition)
SELECT create_distributed_table('books', 'id');

-- Grant privileges on distributed table to user
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE books TO "user";

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS books_title_idx ON books (title);
CREATE INDEX IF NOT EXISTS books_author_idx ON books (author);