#!/usr/bin/env python
import argparse
import time

from scripts.utils.db import get_connection, list_sql_files, render_sql


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--dir", required=True)
    parser.add_argument("--target-date", dest="target_date")
    args = parser.parse_args()

    variables = {}
    if args.target_date:
        variables["target_date"] = args.target_date

    sql_files = list(list_sql_files(args.dir))
    if not sql_files:
        raise SystemExit(f"No SQL files found in {args.dir}")

    started = time.time()
    with get_connection() as conn:
        with conn.cursor() as cur:
            for sql_file in sql_files:
                sql = sql_file.read_text()
                cur.execute(render_sql(sql, variables))
                print(f"[OK] {sql_file}")
        conn.commit()

    elapsed = time.time() - started
    print(f"Completed {len(sql_files)} files in {elapsed:.2f}s")


if __name__ == "__main__":
    main()
