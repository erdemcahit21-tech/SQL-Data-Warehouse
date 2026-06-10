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