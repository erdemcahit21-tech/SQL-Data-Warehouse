-- Create bronze schema (raw, untouched data layer)
CREATE SCHEMA IF NOT EXISTS bronze;

-- Drop table if it exists so we can recreate cleanly
DROP TABLE IF EXISTS bronze.raw_sales;

-- Create the raw_sales table matching the CSV columns exactly
CREATE TABLE bronze.raw_sales (
    invoice        VARCHAR(20),
    stock_code     VARCHAR(20),
    description    VARCHAR(255),
    quantity       INTEGER,
    invoice_date   VARCHAR(30),
    price          NUMERIC(10, 2),
    customer_id    VARCHAR(20),
    country        VARCHAR(100),
    loaded_at      TIMESTAMP DEFAULT NOW()
);

-- Verify it was created
SELECT table_name, table_schema
FROM information_schema.tables
WHERE table_schema = 'bronze';