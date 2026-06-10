## Bronze Layer Quality Check Results

- Total rows: 541,910
- Null description: 1,454 rows (kept in Bronze, will drop in Silver)
- Null customer_id: 135,080 rows (~25% of data — will be removed in Silver)
- Negative quantities: 10,624 rows (cancellations/returns — will be removed in Silver)
- Bad prices (zero or negative): 2,521 rows (will be removed in Silver)
- Cancelled orders (invoice starts with C): 9,288 rows (will be removed in Silver)
- Date range: January 2011 to September 2011
- Top country: United Kingdom (495,478 rows — ~91% of data)
- Unique customers: 4,372
## Table Definitions

### bronze.raw_sales
| Column | Type | Notes |
|--------|------|-------|
| invoice | VARCHAR(20) | Invoice number |
| stock_code | VARCHAR(20) | Product code |
| description | VARCHAR(255) | Product name |
| quantity | INTEGER | Units sold (negative = return) |
| invoice_date | VARCHAR(30) | Raw string — converted in Silver |
| price | NUMERIC(10,2) | Unit price |
| customer_id | VARCHAR(20) | Nullable — ~25% missing |
| country | VARCHAR(100) | Customer country |
| loaded_at | TIMESTAMP | When row was inserted |

### silver.clean_sales
All bronze columns cleaned plus:
| Column | Type | Notes |
|--------|------|-------|
| invoice_date | TIMESTAMP | Properly cast from VARCHAR |
| total_amount | NUMERIC | quantity × price |

### silver.dim_customers
| Column | Type |
|--------|------|
| customer_id | VARCHAR(20) |
| country | VARCHAR(100) |

### silver.dim_products
| Column | Type |
|--------|------|
| stock_code | VARCHAR(20) |
| description | VARCHAR(255) |

## Design Decisions

- **invoice_date stored as VARCHAR in Bronze** — the raw CSV has inconsistent 
  date formats. Bronze stores exactly what it receives. Silver converts properly.
- **customer_id kept as VARCHAR** — IDs like "17850" look numeric but should 
  never be summed or averaged. VARCHAR prevents accidental math.
- **total_amount calculated in Silver not Bronze** — Bronze never transforms. 
  Derived columns belong in Silver and above.