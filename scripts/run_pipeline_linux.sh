#!/usr/bin/env bash
set -euo pipefail

DEFAULT_TARGET_DATE="$(
python - <<'PY'
import csv
from datetime import datetime
from pathlib import Path

payments = Path("data/raw/payments.csv")
if not payments.exists():
    print(datetime.utcnow().strftime("%Y-%m-%d"))
    raise SystemExit(0)

with payments.open("r", encoding="utf-8") as f:
    rows = list(csv.DictReader(f))

if not rows:
    print(datetime.utcnow().strftime("%Y-%m-%d"))
else:
    max_paid = max(datetime.fromisoformat(r["paid_ts"]) for r in rows if r.get("paid_ts"))
    print(max_paid.strftime("%Y-%m-%d"))
PY
)"

TARGET_DATE="${1:-$DEFAULT_TARGET_DATE}"
REPORT_DIR="${2:-logs/reports}"
SQL_ROOT="${SQL_ROOT:-sql}"

echo "[PIPELINE] target_date=${TARGET_DATE}"
echo "[PIPELINE] sql_root=${SQL_ROOT}"

python -m scripts.check_raw_freshness --max-age-hours "${RAW_FRESHNESS_MAX_HOURS:-168}"
python -m scripts.load_raw.load_raw
python -m scripts.run_sql_dir --dir "${SQL_ROOT}/10_staging"
python -m scripts.run_sql_dir --dir "${SQL_ROOT}/20_mart"
python -m scripts.run_sql_dir --dir "${SQL_ROOT}/30_kpi" --target-date "${TARGET_DATE}"
python -m scripts.run_quality_checks --target-date "${TARGET_DATE}" --dir "${SQL_ROOT}/90_quality" --run-id "linux_manual_${TARGET_DATE}"
python -m scripts.export_kpi_csv \
  --target-date "${TARGET_DATE}" \
  --output-path "${REPORT_DIR}/kpi_daily_${TARGET_DATE}.csv"
python -m scripts.export_kpi_dashboard \
  --target-date "${TARGET_DATE}" \
  --output-path "${REPORT_DIR}/dashboard_${TARGET_DATE}.html"
python -m scripts.write_pipeline_summary \
  --target-date "${TARGET_DATE}" \
  --run-id "linux_manual_${TARGET_DATE}" \
  --output-path "${REPORT_DIR}/pipeline_summary_${TARGET_DATE}.txt"

echo "[PIPELINE] completed"
