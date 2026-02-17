# AGENTS.md — da-airflow-project

## 0) One-liner
This repo demonstrates a **Data Analyst-style** automated KPI pipeline:
**raw → staging → mart → KPI → data quality checks → (optional) report**, orchestrated by **Airflow**.

## 1) Primary target role
- Data Analyst / BI Analyst (junior-friendly) who can:
  - define KPIs (numerator/denominator, grain, filters)
  - build a small data mart
  - validate data quality (null/dup/anomaly)
  - automate daily refresh via Airflow

## 2) Local environment assumptions
- OS: WSL2 Ubuntu
- Runtime: Docker + Docker Compose
- Stack (MVP):
  - Postgres (warehouse)
  - Airflow (scheduler/orchestrator)
  - Python (transform scripts) + SQL (transform/KPI)

## 3) Repo structure (must follow)
- dags/                 Airflow DAGs
- sql/
  - 00_ddl/             schema + tables
  - 10_staging/         staging transforms
  - 20_mart/            mart transforms (facts/dims)
  - 30_kpi/             KPI queries (daily/weekly)
  - 90_quality/         data quality checks (SQL)
- scripts/
  - load_raw/           raw loaders (CSV → Postgres)
  - utils/              helpers (db, dates, logging)
- data/
  - raw/                small sample CSV (<= a few MB)
- docs/
  - PRD.md              product requirements
  - DATA_MODEL.md       entities + relationships
  - METRICS.md          KPI definitions + examples
  - RUNBOOK.md          how to operate/debug pipeline

## 4) Definition of Done (MVP)
### Functional
1) `docker compose up -d` brings up Airflow + Postgres
2) One DAG runs end-to-end:
   - load raw data (or ensure raw exists)
   - build staging tables
   - build mart tables
   - compute KPI tables
   - run data quality checks (fail the DAG if checks fail)
3) Postgres contains:
   - staging tables
   - mart tables (facts/dims)
   - KPI table(s): `kpi_daily` (and optional `kpi_weekly`)
4) README explains:
   - how to run locally
   - how to view Airflow UI
   - how to query KPI results
   - how to intentionally break data and see checks fail

### Quality/Engineering
- Idempotency: Re-running a DAG for the same date must not duplicate rows
- Backfill: DAG supports running for a past date range (at least last 7 days)
- Observability: Each task logs counts and key stats
- Minimal tests: at least one `make check` (or script) verifying DB tables exist

## 5) KPI scope (MVP)
We target **finance/ops-style KPIs** because many DA JDs emphasize revenue/cost/reporting:
- Revenue (gross), Refunds, Net Revenue
- Orders/Transactions count
- Active customers (daily)
- Gross margin (if costs exist)
- Optional: cohort retention proxy (repeat purchase within 7 days)

These must be defined in `docs/METRICS.md` with:
- definition
- grain (daily)
- filters/exclusions
- known limitations

## 6) Data model scope (MVP dataset)
We will use a small synthetic but realistic schema representing “transactions”:
- `raw_customers`
- `raw_orders`
- `raw_payments`
- optional `raw_costs` (to compute margin)

The mart layer should include:
- `dim_customer`
- `fact_orders`
- `fact_payments`
- `mart_kpi_daily` or `kpi_daily`

## 7) Data quality checks (must-have)
Implement as SQL in `sql/90_quality/` and run via Airflow:
- Null checks: primary keys + required columns
- Duplicate checks: key uniqueness (order_id, payment_id)
- Referential integrity: fact keys must exist in dims
- Row count sanity: today's count should be within threshold vs yesterday (configurable)
- KPI anomaly (simple): net revenue negative or spikes beyond threshold → fail or warn

## 8) Agent working rules (for OMX / Codex)
### Coding style
- Prefer SQL transformations where reasonable; Python only for orchestration/loading.
- Keep SQL readable: CTEs, explicit column lists, consistent naming.
- Use UTC or clearly document timezone assumptions.

### Commit/PR discipline
- Small commits: one feature per commit when possible.
- Each change must update docs if it changes:
  - data model
  - KPI definition
  - DAG behavior

### Must not
- Commit secrets (no credentials in repo)
- Add huge datasets (keep raw samples small)
- Depend on paid services

## 9) Task plan for the agent (MVP order)
1) Create docker-compose for Airflow + Postgres
2) Create DB schema + raw/staging/mart/KPI tables (SQL DDL)
3) Create raw CSV sample + loader script
4) Create Airflow DAG:
   - load_raw → build_staging → build_mart → build_kpi → run_quality_checks
5) Add METRICS + DATA_MODEL docs
6) Add RUNBOOK + README (quickstart + troubleshooting)

## 10) Quick command expectations (to implement)
- `make up` / `make down`
- `make init` (create tables)
- `make run-dag` (trigger DAG)
- `make psql` (open psql shell)
- `make check` (run quality checks manually)
