-- Create a books table on each sharded instance
CREATE TABLE IF NOT EXISTS books (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255),
    author VARCHAR(255),
    published DATE
);

CREATE INDEX IF NOT EXISTS books_id_idx ON books (id);
