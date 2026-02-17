#!/usr/bin/env python
import argparse
import csv
from pathlib import Path

from scripts.utils.db import get_connection


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--target-date", required=True)
    parser.add_argument("--output-path", required=True)
    args = parser.parse_args()

    output_path = Path(args.output_path)
    output_path.parent.mkdir(parents=True, exist_ok=True)

    query = """
        SELECT
            kpi_date,
            orders,
            paying_customers,
            gross_revenue,
            refunds,
            net_revenue,
            gross_margin
        FROM mart_kpi_daily
        WHERE kpi_date = %s::date
    """

    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(query, (args.target_date,))
            rows = cur.fetchall()
            columns = [desc[0] for desc in cur.description]

    if not rows:
        raise SystemExit(f"No KPI row found for target_date={args.target_date}")

    with output_path.open("w", encoding="utf-8", newline="") as f:
        writer = csv.writer(f)
        writer.writerow(columns)
        writer.writerows(rows)

    print(f"Exported {len(rows)} row(s) to {output_path}")


if __name__ == "__main__":
    main()
