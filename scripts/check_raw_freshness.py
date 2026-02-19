#!/usr/bin/env python
import argparse
from datetime import datetime, timezone
from pathlib import Path


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--data-dir", default="data/raw")
    parser.add_argument("--max-age-hours", type=float, default=24.0)
    args = parser.parse_args()

    data_dir = Path(args.data_dir)
    if not data_dir.exists():
        raise SystemExit(f"Missing data directory: {data_dir}")

    csv_files = sorted(data_dir.glob("*.csv"))
    if not csv_files:
        raise SystemExit(f"No CSV files found in {data_dir}")

    now = datetime.now(timezone.utc)
    stale = []
    for file_path in csv_files:
        mtime = datetime.fromtimestamp(file_path.stat().st_mtime, tz=timezone.utc)
        age_hours = (now - mtime).total_seconds() / 3600
        print(f"[FRESHNESS] {file_path.name}: age={age_hours:.2f}h (max={args.max_age_hours:.2f}h)")
        if age_hours > args.max_age_hours:
            stale.append((file_path.name, age_hours))

    if stale:
        print("\nRaw data freshness check failed:")
        for name, age in stale:
            print(f" - {name}: {age:.2f}h old")
        raise SystemExit(1)

    print("Raw data freshness check passed")


if __name__ == "__main__":
    main()
