#!/usr/bin/env python
from scripts.utils.db import get_connection, get_db_type


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
    "mart_kpi_weekly",
    "mart_kpi_monthly",
    "mart_kpi_segment_daily",
    "quality_check_runs",
]


def main():
    db_type = get_db_type()

    with get_connection() as conn:
        with conn.cursor() as cur:
            if db_type == "postgres":
                cur.execute(
                    """
                    SELECT table_name
                    FROM information_schema.tables
                    WHERE table_schema = 'public'
                    """
                )
            else:
                cur.execute(
                    """
                    SELECT table_name
                    FROM information_schema.tables
                    WHERE table_schema = DATABASE()
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
