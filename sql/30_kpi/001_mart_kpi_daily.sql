DELETE FROM mart_kpi_daily
WHERE kpi_date = '{{ target_date }}'::DATE;

INSERT INTO mart_kpi_daily (
    kpi_date,
    orders,
    paying_customers,
    gross_revenue,
    refunds,
    net_revenue,
    gross_margin
)
WITH daily_orders AS (
    SELECT COUNT(DISTINCT order_id) AS orders
    FROM fact_orders
    WHERE order_date = '{{ target_date }}'::DATE
      AND status IN ('PAID', 'COMPLETED')
),
daily_payments AS (
    SELECT
        COUNT(DISTINCT CASE WHEN net_amount > 0 THEN customer_id END) AS paying_customers,
        COALESCE(SUM(amount), 0)::NUMERIC(14, 2) AS gross_revenue,
        COALESCE(SUM(refund_amount), 0)::NUMERIC(14, 2) AS refunds,
        COALESCE(SUM(net_amount), 0)::NUMERIC(14, 2) AS net_revenue
    FROM fact_payments
    WHERE paid_date = '{{ target_date }}'::DATE
),
daily_costs AS (
    SELECT COALESCE(SUM(c.cost_amount), 0)::NUMERIC(14, 2) AS cost_amount
    FROM fact_payments p
    LEFT JOIN stg_costs c
        ON p.order_id = c.order_id
    WHERE p.paid_date = '{{ target_date }}'::DATE
)
SELECT
    '{{ target_date }}'::DATE,
    o.orders,
    p.paying_customers,
    p.gross_revenue,
    p.refunds,
    p.net_revenue,
    (p.net_revenue - c.cost_amount)::NUMERIC(14, 2) AS gross_margin
FROM daily_orders o
CROSS JOIN daily_payments p
CROSS JOIN daily_costs c;
