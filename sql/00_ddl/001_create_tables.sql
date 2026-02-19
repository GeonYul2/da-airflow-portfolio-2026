CREATE TABLE IF NOT EXISTS raw_customers (
    customer_id TEXT,
    signup_date DATE,
    region TEXT,
    channel TEXT
);

CREATE TABLE IF NOT EXISTS raw_orders (
    order_id TEXT,
    customer_id TEXT,
    order_ts TIMESTAMP,
    status TEXT
);

CREATE TABLE IF NOT EXISTS raw_payments (
    payment_id TEXT,
    order_id TEXT,
    paid_ts TIMESTAMP,
    amount NUMERIC(12, 2),
    refund_amount NUMERIC(12, 2)
);

CREATE TABLE IF NOT EXISTS raw_costs (
    order_id TEXT,
    cost_amount NUMERIC(12, 2)
);

CREATE TABLE IF NOT EXISTS stg_customers (
    customer_id TEXT,
    signup_date DATE,
    region TEXT,
    channel TEXT
);

CREATE TABLE IF NOT EXISTS stg_orders (
    order_id TEXT,
    customer_id TEXT,
    order_ts TIMESTAMP,
    order_date DATE,
    status TEXT
);

CREATE TABLE IF NOT EXISTS stg_payments (
    payment_id TEXT,
    order_id TEXT,
    paid_ts TIMESTAMP,
    paid_date DATE,
    amount NUMERIC(12, 2),
    refund_amount NUMERIC(12, 2),
    net_amount NUMERIC(12, 2)
);

CREATE TABLE IF NOT EXISTS stg_costs (
    order_id TEXT,
    cost_amount NUMERIC(12, 2)
);

CREATE TABLE IF NOT EXISTS dim_customer (
    customer_id TEXT,
    signup_date DATE,
    first_order_date DATE,
    region TEXT,
    channel TEXT
);

CREATE TABLE IF NOT EXISTS fact_orders (
    order_id TEXT,
    customer_id TEXT,
    order_date DATE,
    status TEXT
);

CREATE TABLE IF NOT EXISTS fact_payments (
    payment_id TEXT,
    order_id TEXT,
    customer_id TEXT,
    paid_date DATE,
    amount NUMERIC(12, 2),
    refund_amount NUMERIC(12, 2),
    net_amount NUMERIC(12, 2)
);

CREATE TABLE IF NOT EXISTS mart_kpi_daily (
    kpi_date DATE PRIMARY KEY,
    orders INTEGER,
    paying_customers INTEGER,
    gross_revenue NUMERIC(14, 2),
    refunds NUMERIC(14, 2),
    net_revenue NUMERIC(14, 2),
    gross_margin NUMERIC(14, 2)
);

CREATE TABLE IF NOT EXISTS mart_kpi_weekly (
    week_start_date DATE PRIMARY KEY,
    week_end_date DATE,
    orders INTEGER,
    paying_customers INTEGER,
    gross_revenue NUMERIC(14, 2),
    refunds NUMERIC(14, 2),
    net_revenue NUMERIC(14, 2),
    gross_margin NUMERIC(14, 2)
);

CREATE TABLE IF NOT EXISTS mart_kpi_monthly (
    month_start_date DATE PRIMARY KEY,
    month_end_date DATE,
    orders INTEGER,
    paying_customers INTEGER,
    gross_revenue NUMERIC(14, 2),
    refunds NUMERIC(14, 2),
    net_revenue NUMERIC(14, 2),
    gross_margin NUMERIC(14, 2)
);

CREATE TABLE IF NOT EXISTS mart_kpi_segment_daily (
    kpi_date DATE,
    region TEXT,
    channel TEXT,
    orders INTEGER,
    paying_customers INTEGER,
    gross_revenue NUMERIC(14, 2),
    refunds NUMERIC(14, 2),
    net_revenue NUMERIC(14, 2),
    gross_margin NUMERIC(14, 2),
    PRIMARY KEY (kpi_date, region, channel)
);

CREATE TABLE IF NOT EXISTS quality_check_runs (
    id BIGSERIAL PRIMARY KEY,
    checked_at TIMESTAMP NOT NULL DEFAULT NOW(),
    dag_run_id TEXT,
    target_date DATE NOT NULL,
    check_name TEXT NOT NULL,
    status TEXT NOT NULL,
    result_row_count INTEGER NOT NULL,
    sample_rows TEXT
);
