#!/usr/bin/env python
import argparse
from pathlib import Path

from scripts.utils.db import get_connection


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--target-date", required=True)
    parser.add_argument("--run-id", required=True)
    parser.add_argument("--output-path", required=True)
    args = parser.parse_args()

    output_path = Path(args.output_path)
    output_path.parent.mkdir(parents=True, exist_ok=True)

    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                """
                SELECT
                    kpi_date,
                    orders,
                    paying_customers,
                    gross_revenue,
                    refunds,
                    net_revenue,
                    gross_margin
                FROM mart_kpi_daily
                WHERE kpi_date = %s
                """,
                (args.target_date,),
            )
            daily_row = cur.fetchone()

            cur.execute(
                """
                SELECT check_name, status, result_row_count
                FROM quality_check_runs
                WHERE dag_run_id = %s
                  AND target_date = %s
                ORDER BY id
                """,
                (args.run_id, args.target_date),
            )
            check_rows = cur.fetchall()

    if not daily_row:
        raise SystemExit(f"No mart_kpi_daily row for target_date={args.target_date}")

    summary_lines = [
        f"run_id={args.run_id}",
        f"target_date={args.target_date}",
        "",
        "[daily_kpi]",
        f"kpi_date={daily_row[0]}",
        f"orders={daily_row[1]}",
        f"paying_customers={daily_row[2]}",
        f"gross_revenue={daily_row[3]}",
        f"refunds={daily_row[4]}",
        f"net_revenue={daily_row[5]}",
        f"gross_margin={daily_row[6]}",
        "",
        "[quality_checks]",
    ]

    if not check_rows:
        summary_lines.append("no_quality_records_found=true")
    else:
        for check_name, status, result_row_count in check_rows:
            summary_lines.append(f"{check_name}={status} (rows={result_row_count})")

    output_path.write_text("\n".join(summary_lines) + "\n", encoding="utf-8")
    print(f"Pipeline summary written to {output_path}")


if __name__ == "__main__":
    main()
