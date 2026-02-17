# PRD — DA Airflow KPI Pipeline (MVP)

## 1) Background / Why
Many Data Analyst roles require:
- SQL-based KPI computation & reporting
- Dashboard refresh cadence (daily/weekly/monthly)
- Data consistency checks (null/dup/mismatch)
- Automation (Airflow, scheduling, Linux familiarity)

This project demonstrates end-to-end capability:
**ingest → model → measure → validate → automate**.

## 2) Goals
### Business goal (portfolio)
Show that I can:
1) define business KPIs with clear definitions
2) design a small data mart aligned to those KPIs
3) automate KPI refresh with Airflow
4) implement data quality checks and fail fast when data is wrong

### Technical goal (MVP)
Provide a reproducible local stack using Docker Compose:
- Airflow (scheduler)
- Postgres (warehouse)
- SQL transforms + small Python loaders

## 3) Target users
- Myself (DA): build/run/iterate metrics pipeline
- Reviewer/interviewer: clone repo, run pipeline, verify outputs and checks

## 4) Non-goals (Out of scope for MVP)
- Production deployment (K8s, cloud)
- Streaming/real-time ingestion
- Full BI semantic layer tooling (dbt Cloud, LookML)
- Complex ML modeling

## 5) Dataset & Data Model (MVP)
### Dataset choice
Use a **small synthetic transactional dataset** to avoid licensing issues and keep repo lightweight.
Files (in `data/raw/`):
- customers.csv
- orders.csv
- payments.csv
- (optional) costs.csv

### Raw tables (Postgres)
- raw_customers(customer_id, signup_date, region, channel)
- raw_orders(order_id, customer_id, order_ts, status)
- raw_payments(payment_id, order_id, paid_ts, amount, refund_amount)
- raw_costs(order_id, cost_amount)   # optional, for margin

### Staging tables (clean + typed + normalized)
- stg_customers
- stg_orders
- stg_payments
- stg_costs

### Mart layer (analytics-ready)
- dim_customer (customer_id, region, channel, first_order_date, signup_date)
- fact_orders (order_id, customer_id, order_date, status)
- fact_payments (payment_id, order_id, paid_date, amount, refund_amount, net_amount)
- mart_kpi_daily (date, orders, paying_customers, gross_revenue, refunds, net_revenue, gross_margin)

> All mart tables must have clear grain and stable keys.

## 6) KPI Definitions (MVP)
All KPIs are computed daily (DATE grain, UTC unless noted).

- Orders: count distinct order_id where status in ('PAID','COMPLETED')
- Paying customers: count distinct customer_id with net_amount > 0 on that date
- Gross revenue: sum(amount)
- Refunds: sum(refund_amount)
- Net revenue: sum(amount - refund_amount)
- Gross margin (if costs exist): sum(net_amount - cost_amount)

Each KPI must be documented in `docs/METRICS.md`:
- definition
- numerator/denominator (if ratio)
- filters (status, refund handling)
- caveats (partial refunds, late payments)

## 7) Orchestration Requirements (Airflow)
### DAG: `da_kpi_daily`
- Schedule: daily (e.g., 09:00 UTC) — configurable
- Supports backfill: run for a date range (at least last 7 days)
- Idempotent:
  - writing pattern should be `DELETE/INSERT` by partition date or `MERGE` equivalent
- Tasks (MVP):
  1) `load_raw_to_postgres` (CSV → raw_*)
  2) `build_staging` (run stg SQL)
  3) `build_mart` (run mart SQL)
  4) `compute_kpi_daily` (write mart_kpi_daily / kpi_daily)
  5) `run_quality_checks` (SQL checks; fail DAG on violations)

### Logging
Each task must log:
- row counts written
- target date
- execution time
- failure reason (for quality checks, show which check failed)

## 8) Data Quality Requirements
Implement checks in `sql/90_quality/` and run them in Airflow.

### Must-have checks
1) Null checks:
   - keys are not null (customer_id, order_id, payment_id)
2) Duplicate checks:
   - key uniqueness for each fact table
3) Referential integrity:
   - fact_orders.customer_id exists in dim_customer
   - fact_payments.order_id exists in fact_orders
4) Row count sanity:
   - today orders within [yesterday * 0.5, yesterday * 2.0] (configurable)
5) KPI sanity:
   - net_revenue >= 0
   - refunds <= gross_revenue

### Output behavior
- If any check fails: Airflow task fails and prints the violating rows/counts.

## 9) Reporting Output (MVP)
### Primary output
- Postgres table: `mart_kpi_daily` (or `kpi_daily`)
- Example query in README:
  - last 14 days KPIs
  - top regions by revenue (if region included)

### Optional output
- Auto-generate a simple CSV report `reports/kpi_daily_YYYY-MM-DD.csv`
- Or post summary to console logs (no external integrations in MVP)

## 10) Success Criteria
- New user can run:
  - `docker compose up -d`
  - trigger DAG in Airflow UI
  - confirm mart + KPI tables exist and have rows
- Quality checks can be demonstrated:
  - intentionally insert a bad row (null key / duplicate) → DAG fails
- Repo communicates DA skill clearly:
  - PRD + METRICS + DATA_MODEL + RUNBOOK are concise and consistent

## 11) Roadmap (post-MVP)
- Add Airflow alerting (Slack/email) with secrets via env
- Add metric layer approach (versioned KPI definitions)
- Add incremental loading (simulate late arriving data)
- Add a small dashboard (Looker Studio/Tableau screenshot) using `mart_kpi_daily`
