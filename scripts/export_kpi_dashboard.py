#!/usr/bin/env python
import argparse
from datetime import date, timedelta
from pathlib import Path
from typing import List, Sequence

from scripts.utils.db import get_connection


def _table_html(title: str, columns: Sequence[str], rows: Sequence[Sequence[object]]) -> str:
    if not rows:
        return f"<h2>{title}</h2><p>No data</p>"

    head = "".join(f"<th>{c}</th>" for c in columns)
    body = ""
    for row in rows:
        body += "<tr>" + "".join(f"<td>{value}</td>" for value in row) + "</tr>"
    return f"<h2>{title}</h2><table><thead><tr>{head}</tr></thead><tbody>{body}</tbody></table>"


def _fetch(cur, query: str, params: Sequence[object]) -> tuple[List[str], List[Sequence[object]]]:
    cur.execute(query, params)
    rows = cur.fetchall()
    cols = [d[0] for d in cur.description]
    return cols, rows


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--target-date", required=True)
    parser.add_argument("--output-path", required=True)
    args = parser.parse_args()

    output_path = Path(args.output_path)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    target_date_obj = date.fromisoformat(args.target_date)
    week_start = target_date_obj - timedelta(days=target_date_obj.weekday())
    month_start = target_date_obj.replace(day=1)

    with get_connection() as conn:
        with conn.cursor() as cur:
            daily_cols, daily_rows = _fetch(
                cur,
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
            weekly_cols, weekly_rows = _fetch(
                cur,
                """
                SELECT
                    week_start_date,
                    week_end_date,
                    orders,
                    paying_customers,
                    gross_revenue,
                    refunds,
                    net_revenue,
                    gross_margin
                FROM mart_kpi_weekly
                WHERE week_start_date = %s
                """,
                (week_start.isoformat(),),
            )
            monthly_cols, monthly_rows = _fetch(
                cur,
                """
                SELECT
                    month_start_date,
                    month_end_date,
                    orders,
                    paying_customers,
                    gross_revenue,
                    refunds,
                    net_revenue,
                    gross_margin
                FROM mart_kpi_monthly
                WHERE month_start_date = %s
                """,
                (month_start.isoformat(),),
            )
            segment_cols, segment_rows = _fetch(
                cur,
                """
                SELECT
                    region,
                    channel,
                    orders,
                    paying_customers,
                    gross_revenue,
                    refunds,
                    net_revenue,
                    gross_margin
                FROM mart_kpi_segment_daily
                WHERE kpi_date = %s
                ORDER BY net_revenue DESC, orders DESC
                """,
                (args.target_date,),
            )

    html = f"""<!doctype html>
<html lang="ko">
<head>
  <meta charset="utf-8" />
  <title>KPI Dashboard - {args.target_date}</title>
  <style>
    body {{ font-family: Arial, sans-serif; margin: 24px; color: #111827; }}
    h1 {{ margin-bottom: 8px; }}
    h2 {{ margin-top: 24px; }}
    table {{ border-collapse: collapse; width: 100%; margin-top: 8px; }}
    th, td {{ border: 1px solid #d1d5db; padding: 8px; text-align: right; }}
    th:first-child, td:first-child {{ text-align: left; }}
    .meta {{ color: #6b7280; font-size: 14px; }}
  </style>
</head>
<body>
  <h1>Finance KPI Dashboard</h1>
  <p class="meta">target_date={args.target_date}</p>
  {_table_html("Daily KPI", daily_cols, daily_rows)}
  {_table_html("Weekly KPI", weekly_cols, weekly_rows)}
  {_table_html("Monthly KPI", monthly_cols, monthly_rows)}
  {_table_html("Daily KPI by Region/Channel", segment_cols, segment_rows)}
</body>
</html>
"""

    output_path.write_text(html, encoding="utf-8")
    print(f"Dashboard exported to {output_path}")


if __name__ == "__main__":
    main()
