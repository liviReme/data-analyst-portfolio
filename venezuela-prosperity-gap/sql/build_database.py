"""Builds a SQLite database from the cleaned CSV files produced by the notebook."""
import sqlite3
from pathlib import Path

import pandas as pd

BASE = Path(__file__).resolve().parent
PROCESSED = BASE.parent / "data" / "processed"
DB_PATH = BASE / "prosperity_gap.db"

countries = pd.read_csv(PROCESSED / "prosperity_gap_clean.csv")
aggregates = pd.read_csv(PROCESSED / "prosperity_gap_aggregates.csv")

if DB_PATH.exists():
    DB_PATH.unlink()

with sqlite3.connect(DB_PATH) as conn:
    countries.to_sql("prosperity_gap", conn, index=False)
    aggregates.to_sql("regional_aggregates", conn, index=False)
    conn.execute("CREATE INDEX idx_gap_country_year ON prosperity_gap (country_code, year)")
    conn.execute("CREATE INDEX idx_agg_country_year ON regional_aggregates (country_code, year)")

print(f"Database created: {DB_PATH.name}")
print(f"  prosperity_gap:      {len(countries):,} rows")
print(f"  regional_aggregates: {len(aggregates):,} rows")
