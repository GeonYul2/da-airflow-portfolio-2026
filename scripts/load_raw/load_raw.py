#!/usr/bin/env python
import argparse
import csv
import time
from pathlib import Path

from scripts.utils.db import get_connection


TABLE_FILE_MAP = {
    "raw_customers": "customers.csv",
    "raw_orders": "orders.csv",
    "raw_payments": "payments.csv",
    "raw_costs": "costs.csv",
}


def insert_csv_rows(cur, table_name: str, file_path: Path):
    with file_path.open("r", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        columns = reader.fieldnames or []
        if not columns:
            raise ValueError(f"No columns found in CSV header: {file_path}")

        placeholders = ", ".join(["%s"] * len(columns))
        column_sql = ", ".join(columns)
        sql = f"INSERT INTO {table_name} ({column_sql}) VALUES ({placeholders})"

        rows = []
        for row in reader:
            rows.append(tuple((row[col] if row[col] != "" else None) for col in columns))

        if rows:
            cur.executemany(sql, rows)


def log_count(cur, table_name: str):
    cur.execute(f"SELECT COUNT(*) FROM {table_name}")
    count = cur.fetchone()[0]
    print(f"{table_name}: {count} rows")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--data-dir", default="data/raw")
    args = parser.parse_args()

    data_dir = Path(args.data_dir)
    started = time.time()

    with get_connection() as conn:
        with conn.cursor() as cur:
            for table_name in TABLE_FILE_MAP:
                cur.execute(f"TRUNCATE TABLE {table_name}")

            for table_name, file_name in TABLE_FILE_MAP.items():
                file_path = data_dir / file_name
                if not file_path.exists():
                    raise FileNotFoundError(f"Missing file: {file_path}")
                insert_csv_rows(cur, table_name, file_path)
                log_count(cur, table_name)

        conn.commit()

    elapsed = time.time() - started
    print(f"Raw load completed in {elapsed:.2f}s")


if __name__ == "__main__":
    main()
