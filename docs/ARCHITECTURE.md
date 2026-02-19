# ARCHITECTURE

## 1) System Overview

```mermaid
flowchart LR
    A[data/raw CSV] --> B[load_raw.py]
    B --> C[raw_* tables]
    C --> D[sql/10_staging]
    D --> E[stg_* tables]
    E --> F[sql/20_mart]
    F --> G[dim/fact tables]
    G --> H[sql/30_kpi]
    H --> I[mart_kpi_daily/weekly/monthly/segment]
    I --> J[sql/90_quality + run_quality_checks.py]
    J --> K{PASS?}
    K -- Yes --> L[export_kpi_csv.py]
    K -- Yes --> M[export_kpi_dashboard.py]
    K -- Yes --> N[write_pipeline_summary.py]
    K -- No --> O[DAG failed + quality_check_runs 기록]
```

---

## 2) Airflow DAG Task Flow

`da_kpi_daily` (daily schedule, catchup enabled)

```mermaid
flowchart TD
    A[check_raw_freshness]
    B[load_raw_to_postgres]
    C[build_staging]
    D[build_mart]
    E[compute_kpi_daily]
    F[compute_kpi_weekly]
    G[compute_kpi_monthly]
    H[compute_kpi_segment_daily]
    I[run_quality_checks]
    J[export_kpi_csv]
    K[export_kpi_dashboard]
    L[write_pipeline_summary]

    A --> B --> C --> D --> E --> F --> G --> H --> I --> J --> K --> L
```

---

## 3) Data Model (Logical)

- Raw: `raw_customers`, `raw_orders`, `raw_payments`, `raw_costs`
- Staging: `stg_customers`, `stg_orders`, `stg_payments`, `stg_costs`
- Mart:
  - `dim_customer`
  - `fact_orders`
  - `fact_payments`
- KPI:
  - `mart_kpi_daily`
  - `mart_kpi_weekly`
  - `mart_kpi_monthly`
  - `mart_kpi_segment_daily`
- Quality audit: `quality_check_runs`

---

## 4) Dual Warehouse Strategy

- 기본 모드: Postgres + `sql/*`
- 대체 모드: MariaDB + `sql/mysql/*`
- 전환 기준:
  - `WAREHOUSE_DSN` (postgresql / mysql+pymysql)
  - `SQL_ROOT` (`sql` 또는 `sql/mysql`)

예시:

```bash
# Postgres
export WAREHOUSE_DSN=postgresql://airflow:airflow@postgres:5432/warehouse
export SQL_ROOT=sql

# MariaDB
export WAREHOUSE_DSN=mysql+pymysql://airflow:airflow@mariadb:3306/warehouse
export SQL_ROOT=sql/mysql
```

---

## 5) Reliability / Portfolio Talking Points

1. **Idempotency**: KPI 테이블은 target date 기준 delete+insert로 재실행 안전
2. **Observability**: 품질검사 결과를 `quality_check_runs`에 영구 저장
3. **Operational readiness**: Airflow + Linux 수동 실행(`make run-linux*`) 모두 지원
4. **Business alignment**: 재무 KPI(매출/환불/순매출/마진) + 주/월 롤업 + 세그먼트 분석
