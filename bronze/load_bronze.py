"""
load_bronze.py
Purpose: Load raw CSV data into the bronze.raw_sales table in PostgreSQL.
"""

import os
import pandas as pd
from sqlalchemy import create_engine, text
from dotenv import load_dotenv
import time

load_dotenv()

DB_HOST = os.getenv("DB_HOST")
DB_PORT = os.getenv("DB_PORT")
DB_NAME = os.getenv("DB_NAME")
DB_USER = os.getenv("DB_USER")
DB_PASSWORD = os.getenv("DB_PASSWORD")

CONNECTION_STRING = (
    f"postgresql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"
    f"?sslmode=require"
)

print("Connecting to database...")
engine = create_engine(CONNECTION_STRING)

try:
    with engine.connect() as conn:
        result = conn.execute(text("SELECT version()"))
        print(f"Connected: {result.fetchone()[0][:50]}")
except Exception as e:
    print(f"Connection failed: {e}")
    exit(1)

CSV_PATH = r"C:\projects\retail-data\retail_raw.csv"

print(f"\nLoading CSV from: {CSV_PATH}")
start = time.time()

df = pd.read_csv(
    CSV_PATH,
    encoding="latin-1",
    dtype=str,
    on_bad_lines="skip"
)

print(f"CSV loaded in {time.time() - start:.1f}s")
print(f"Shape: {df.shape[0]:,} rows x {df.shape[1]} columns")
print(f"Columns: {list(df.columns)}")

df.columns = [col.strip().lower().replace(" ", "_") for col in df.columns]

df = df.rename(columns={
    "stockcode": "stock_code",
    "invoicedate": "invoice_date",
})

print(f"\nRenamed columns: {list(df.columns)}")

EXPECTED_COLS = ["invoice", "stock_code", "description",
                 "quantity", "invoice_date", "price",
                 "customer_id", "country"]

df = df[EXPECTED_COLS]

print(f"\nLoading {df.shape[0]:,} rows into bronze.raw_sales...")
print("This will take 2-5 minutes...")

start = time.time()

# ── 5. Load into PostgreSQL ──────────────────────────────────────────────────
print(f"\nLoading {df.shape[0]:,} rows into bronze.raw_sales...")
print("This will take 2-5 minutes...")

start = time.time()

# First truncate the table
with engine.begin() as conn:
    conn.execute(text("TRUNCATE TABLE bronze.raw_sales"))

# Load in chunks with explicit commits
chunk_size = 5000
total_chunks = len(df) // chunk_size + 1

for i, chunk in enumerate(range(0, len(df), chunk_size)):
    df_chunk = df.iloc[chunk:chunk + chunk_size]
    with engine.begin() as conn:
        df_chunk.to_sql(
            name="raw_sales",
            schema="bronze",
            con=conn,
            if_exists="append",
            index=False,
            method="multi"
        )
    if i % 10 == 0:
        print(f"  Chunk {i+1}/{total_chunks} loaded...")

elapsed = time.time() - start
print(f"\nDone! Loaded in {elapsed:.1f}s")

with engine.connect() as conn:
    count = conn.execute(text("SELECT COUNT(*) FROM bronze.raw_sales")).fetchone()[0]
    sample = conn.execute(text("SELECT * FROM bronze.raw_sales LIMIT 3")).fetchall()

print(f"\nVerification:")
print(f"  Total rows in bronze.raw_sales: {count:,}")
print(f"\nSample rows:")
for row in sample:
    print(f"  {row}")

engine.dispose()
print("\nBronze load complete.")