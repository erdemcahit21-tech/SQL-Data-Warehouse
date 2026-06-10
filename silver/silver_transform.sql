-- ═══════════════════════════════════════════════
-- SILVER LAYER — Cleaning and Standardization
-- Removes bad data found in Bronze quality checks
-- ═══════════════════════════════════════════════

-- Create silver schema
CREATE SCHEMA IF NOT EXISTS silver;

-- ── 1. Main clean sales table ──────────────────
DROP TABLE IF EXISTS silver.clean_sales;

CREATE TABLE silver.clean_sales AS
SELECT
    invoice,
    stock_code,
    TRIM(description)                          AS description,
    CAST(quantity AS INTEGER)                  AS quantity,
    TO_TIMESTAMP(invoice_date, 'MM/DD/YY HH24:MI') AS invoice_date,
    CAST(price AS NUMERIC(10,2))               AS price,
    customer_id,
    TRIM(country)                              AS country,
    CAST(quantity AS INTEGER) * 
        CAST(price AS NUMERIC(10,2))           AS total_amount
FROM bronze.raw_sales
WHERE
    CAST(quantity AS INTEGER) > 0          -- remove returns/cancellations
    AND CAST(price AS NUMERIC(10,2)) > 0   -- remove zero/negative prices
    AND customer_id IS NOT NULL            -- remove anonymous transactions
    AND invoice NOT LIKE 'C%';            -- remove cancelled invoices

-- ── 2. Dimension: Customers ────────────────────
DROP TABLE IF EXISTS silver.dim_customers;

CREATE TABLE silver.dim_customers AS
SELECT DISTINCT
    customer_id,
    TRIM(country) AS country
FROM silver.clean_sales;

-- ── 3. Dimension: Products ─────────────────────
DROP TABLE IF EXISTS silver.dim_products;

CREATE TABLE silver.dim_products AS
SELECT DISTINCT
    stock_code,
    TRIM(description) AS description
FROM silver.clean_sales
WHERE description IS NOT NULL;

-- ── 4. Verify ──────────────────────────────────
SELECT 'bronze.raw_sales'    AS layer, COUNT(*) AS rows FROM bronze.raw_sales
UNION ALL
SELECT 'silver.clean_sales'  AS layer, COUNT(*) AS rows FROM silver.clean_sales
UNION ALL
SELECT 'silver.dim_customers' AS layer, COUNT(*) AS rows FROM silver.dim_customers
UNION ALL
SELECT 'silver.dim_products'  AS layer, COUNT(*) AS rows FROM silver.dim_products;