#!/usr/bin/env python
from scripts.utils.db import get_connection


REQUIRED_TABLES = [
    "raw_customers",
    "raw_orders",
    "raw_payments",
    "stg_customers",
    "stg_orders",
    "stg_payments",
    "dim_customer",
    "fact_orders",
    "fact_payments",
    "mart_kpi_daily",
]


def main():
    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                """
                SELECT table_name
                FROM information_schema.tables
                WHERE table_schema = 'public'
                """
            )
            existing = {row[0] for row in cur.fetchall()}

    missing = [table for table in REQUIRED_TABLES if table not in existing]
    if missing:
        print("Missing tables:")
        for table in missing:
            print(f" - {table}")
        raise SystemExit(1)

    print("All required tables exist")


if __name__ == "__main__":
    main()
