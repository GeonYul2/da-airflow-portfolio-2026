CREATE TABLE IF NOT EXISTS raw_customers (
    customer_id VARCHAR(64),
    signup_date DATE,
    region VARCHAR(64),
    channel VARCHAR(64)
);

CREATE TABLE IF NOT EXISTS raw_orders (
    order_id VARCHAR(64),
    customer_id VARCHAR(64),
    order_ts DATETIME,
    status VARCHAR(64)
);

CREATE TABLE IF NOT EXISTS raw_payments (
    payment_id VARCHAR(64),
    order_id VARCHAR(64),
    paid_ts DATETIME,
    amount DECIMAL(12, 2),
    refund_amount DECIMAL(12, 2)
);

CREATE TABLE IF NOT EXISTS raw_costs (
    order_id VARCHAR(64),
    cost_amount DECIMAL(12, 2)
);

CREATE TABLE IF NOT EXISTS stg_customers (
    customer_id VARCHAR(64),
    signup_date DATE,
    region VARCHAR(64),
    channel VARCHAR(64)
);

CREATE TABLE IF NOT EXISTS stg_orders (
    order_id VARCHAR(64),
    customer_id VARCHAR(64),
    order_ts DATETIME,
    order_date DATE,
    status VARCHAR(64)
);

CREATE TABLE IF NOT EXISTS stg_payments (
    payment_id VARCHAR(64),
    order_id VARCHAR(64),
    paid_ts DATETIME,
    paid_date DATE,
    amount DECIMAL(12, 2),
    refund_amount DECIMAL(12, 2),
    net_amount DECIMAL(12, 2)
);

CREATE TABLE IF NOT EXISTS stg_costs (
    order_id VARCHAR(64),
    cost_amount DECIMAL(12, 2)
);

CREATE TABLE IF NOT EXISTS dim_customer (
    customer_id VARCHAR(64),
    signup_date DATE,
    first_order_date DATE,
    region VARCHAR(64),
    channel VARCHAR(64)
);

CREATE TABLE IF NOT EXISTS fact_orders (
    order_id VARCHAR(64),
    customer_id VARCHAR(64),
    order_date DATE,
    status VARCHAR(64)
);

CREATE TABLE IF NOT EXISTS fact_payments (
    payment_id VARCHAR(64),
    order_id VARCHAR(64),
    customer_id VARCHAR(64),
    paid_date DATE,
    amount DECIMAL(12, 2),
    refund_amount DECIMAL(12, 2),
    net_amount DECIMAL(12, 2)
);

CREATE TABLE IF NOT EXISTS mart_kpi_daily (
    kpi_date DATE PRIMARY KEY,
    orders INT,
    paying_customers INT,
    gross_revenue DECIMAL(14, 2),
    refunds DECIMAL(14, 2),
    net_revenue DECIMAL(14, 2),
    gross_margin DECIMAL(14, 2)
);

CREATE TABLE IF NOT EXISTS mart_kpi_weekly (
    week_start_date DATE PRIMARY KEY,
    week_end_date DATE,
    orders INT,
    paying_customers INT,
    gross_revenue DECIMAL(14, 2),
    refunds DECIMAL(14, 2),
    net_revenue DECIMAL(14, 2),
    gross_margin DECIMAL(14, 2)
);

CREATE TABLE IF NOT EXISTS mart_kpi_monthly (
    month_start_date DATE PRIMARY KEY,
    month_end_date DATE,
    orders INT,
    paying_customers INT,
    gross_revenue DECIMAL(14, 2),
    refunds DECIMAL(14, 2),
    net_revenue DECIMAL(14, 2),
    gross_margin DECIMAL(14, 2)
);

CREATE TABLE IF NOT EXISTS mart_kpi_segment_daily (
    kpi_date DATE,
    region VARCHAR(64),
    channel VARCHAR(64),
    orders INT,
    paying_customers INT,
    gross_revenue DECIMAL(14, 2),
    refunds DECIMAL(14, 2),
    net_revenue DECIMAL(14, 2),
    gross_margin DECIMAL(14, 2),
    PRIMARY KEY (kpi_date, region, channel)
);

CREATE TABLE IF NOT EXISTS quality_check_runs (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    checked_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    dag_run_id VARCHAR(255),
    target_date DATE NOT NULL,
    check_name VARCHAR(255) NOT NULL,
    status VARCHAR(32) NOT NULL,
    result_row_count INT NOT NULL,
    sample_rows TEXT
);
