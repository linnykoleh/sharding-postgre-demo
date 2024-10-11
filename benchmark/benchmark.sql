-- Benchmark for data insertion
DO $$
BEGIN
    RAISE NOTICE 'Benchmarking insert';
    PERFORM pg_sleep(1); -- To simulate preparation time

    -- Measure insert time
    EXPLAIN ANALYZE
    INSERT INTO books (title, author, published)
    SELECT 'Book ' || i, 'Author ' || i, CURRENT_DATE - i
    FROM generate_series(1, 1000000) AS i;
END $$;

-- Benchmark for data reading
DO $$
BEGIN
    RAISE NOTICE 'Benchmarking read';
    PERFORM pg_sleep(1); -- To simulate preparation time

    EXPLAIN ANALYZE
    SELECT * FROM books WHERE id = 500000;
END $$;
