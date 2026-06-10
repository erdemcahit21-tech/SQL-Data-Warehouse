## SQL Data Warehouse — Retail Sales Analytics

A Bronze/Silver/Gold data warehouse built on PostgreSQL (Supabase), 
ingesting and transforming 500,000+ rows of real retail sales data.

## Architecture 
CSV (Raw Data)
│
▼
┌─────────────┐
│   BRONZE    │  Raw, untouched data — 541,910 rows
│  raw_sales  │  Loaded via Python (pandas + SQLAlchemy)
└──────┬──────┘
│  Remove: nulls, negatives, cancellations
▼
┌─────────────┐
│   SILVER    │  Clean, trusted data — 397,881 rows
│ clean_sales │  + dim_customers (4,346) + dim_products (3,893)
│ dim_*       │
└──────┬──────┘
│  Aggregate, rank, analyze
▼
┌─────────────┐
│    GOLD     │  Business-ready analytical views
│  5 views    │  Revenue, RFM, Top Customers, Products, Countries
└─────────────┘
## Dataset

- **Source:** Online Retail II (UCI / Kaggle)
- **Size:** 541,910 transactions
- **Period:** 2010–2011
- **Fields:** Invoice, StockCode, Description, Quantity, InvoiceDate, Price, CustomerID, Country

## Project Structure
SQL-Data-Warehouse/
├── bronze/
│   ├── create_bronze.sql     # Schema and table creation
│   ├── load_bronze.py        # Python ingestion script
│   └── bronze_checks.sql     # 8 data quality checks
├── silver/
│   └── silver_transform.sql  # Cleaning + dimension tables
├── gold/
│   └── gold_views.sql        # 5 analytical views
└── docs/
└── data_model.md         # Table definitions and design decisions

## Key SQL Concepts Used

- Schema design (Bronze/Silver/Gold medallion architecture)
- CTEs (Common Table Expressions)
- Window functions (RANK())
- DATE_TRUNC for time-series aggregation
- RFM customer segmentation model
- Dimension table modelling (dim_customers, dim_products)

## Gold Layer Views

| View | Description |
|------|-------------|
| `gold.monthly_revenue` | Total revenue and orders per month |
| `gold.top_customers` | Top 20 customers ranked by spend |
| `gold.top_products` | Top 20 products by quantity sold |
| `gold.country_summary` | Revenue and orders by country |
| `gold.customer_rfm` | Recency, Frequency, Monetary per customer |

## How to Run

1. Clone the repo
2. Create a `.env` file with your PostgreSQL credentials
3. Run `pip install pandas sqlalchemy python-dotenv psycopg2-binary`
4. Run `python bronze/load_bronze.py` to load raw data
5. Run `silver/silver_transform.sql` in your SQL editor
6. Run `gold/gold_views.sql` to create analytical views

## Key Findings (Bronze Quality Checks)

- 135,080 rows had null CustomerID (~25%) — removed in Silver
- 10,624 rows had negative quantities (returns) — removed in Silver
- 9,288 cancelled invoices (prefix "C") — removed in Silver
- United Kingdom dominates: 495,478 rows (~91% of data)
- 4,372 unique customers across 38 countries
