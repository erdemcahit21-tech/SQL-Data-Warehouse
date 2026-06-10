-- ═══════════════════════════════════════════════
-- GOLD LAYER — Analytical Views
-- Business-ready queries built on silver.clean_sales
-- ═══════════════════════════════════════════════

CREATE SCHEMA IF NOT EXISTS gold;

-- ── 1. Monthly Revenue ─────────────────────────
CREATE OR REPLACE VIEW gold.monthly_revenue AS
SELECT
    DATE_TRUNC('month', invoice_date) AS month,
    COUNT(DISTINCT invoice)           AS total_orders,
    ROUND(SUM(total_amount)::NUMERIC, 2) AS revenue
FROM silver.clean_sales
GROUP BY 1
ORDER BY 1;

-- ── 2. Top 20 Customers ────────────────────────
CREATE OR REPLACE VIEW gold.top_customers AS
WITH customer_totals AS (
    SELECT
        customer_id,
        country,
        ROUND(SUM(total_amount)::NUMERIC, 2) AS total_spend,
        COUNT(DISTINCT invoice)              AS order_count
    FROM silver.clean_sales
    GROUP BY customer_id, country
)
SELECT
    customer_id,
    country,
    total_spend,
    order_count,
    RANK() OVER (ORDER BY total_spend DESC) AS spend_rank
FROM customer_totals
LIMIT 20;

-- ── 3. Top 20 Products ─────────────────────────
CREATE OR REPLACE VIEW gold.top_products AS
SELECT
    stock_code,
    description,
    SUM(quantity)                            AS total_qty_sold,
    ROUND(SUM(total_amount)::NUMERIC, 2)     AS total_revenue
FROM silver.clean_sales
GROUP BY stock_code, description
ORDER BY total_qty_sold DESC
LIMIT 20;

-- ── 4. Country Summary ─────────────────────────
CREATE OR REPLACE VIEW gold.country_summary AS
SELECT
    country,
    COUNT(DISTINCT customer_id)          AS unique_customers,
    COUNT(DISTINCT invoice)              AS total_orders,
    ROUND(SUM(total_amount)::NUMERIC, 2) AS total_revenue
FROM silver.clean_sales
GROUP BY country
ORDER BY total_revenue DESC;

-- ── 5. RFM Analysis ────────────────────────────
CREATE OR REPLACE VIEW gold.customer_rfm AS
WITH rfm_base AS (
    SELECT
        customer_id,
        MAX(invoice_date)                        AS last_order_date,
        COUNT(DISTINCT invoice)                  AS frequency,
        ROUND(SUM(total_amount)::NUMERIC, 2)     AS monetary
    FROM silver.clean_sales
    GROUP BY customer_id
)
SELECT
    customer_id,
    CURRENT_DATE - last_order_date::DATE         AS recency_days,
    frequency,
    monetary
FROM rfm_base
ORDER BY monetary DESC;

-- ── Verify all views ───────────────────────────
SELECT * FROM gold.monthly_revenue LIMIT 5;
SELECT * FROM gold.top_customers LIMIT 5;
SELECT * FROM gold.country_summary LIMIT 5;
SELECT * FROM gold.customer_rfm LIMIT 5;