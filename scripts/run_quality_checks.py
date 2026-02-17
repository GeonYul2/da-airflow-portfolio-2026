#!/usr/bin/env python
import argparse
from pathlib import Path

from scripts.utils.db import get_connection, render_sql


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--target-date", required=True)
    parser.add_argument("--dir", default="sql/90_quality")
    args = parser.parse_args()

    variables = {"target_date": args.target_date}
    sql_files = sorted(Path(args.dir).glob("*.sql"))
    if not sql_files:
        raise SystemExit(f"No SQL files found in {args.dir}")

    failures = []
    with get_connection() as conn:
        with conn.cursor() as cur:
            for sql_file in sql_files:
                sql = render_sql(sql_file.read_text(), variables)
                cur.execute(sql)
                rows = cur.fetchall()
                if rows:
                    failures.append((sql_file.name, rows[:10]))
                print(f"[CHECK] {sql_file.name}: {'FAIL' if rows else 'PASS'}")

    if failures:
        for name, rows in failures:
            print(f"\n{name} failed:")
            for row in rows:
                print(f"  {row}")
        raise SystemExit(1)

    print("All quality checks passed")


if __name__ == "__main__":
    main()
