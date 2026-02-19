DELETE FROM mart_kpi_daily
WHERE kpi_date = DATE('{{ target_date }}');

INSERT INTO mart_kpi_daily (
    kpi_date,
    orders,
    paying_customers,
    gross_revenue,
    refunds,
    net_revenue,
    gross_margin
)
SELECT
    DATE('{{ target_date }}') AS kpi_date,
    o.orders,
    p.paying_customers,
    p.gross_revenue,
    p.refunds,
    p.net_revenue,
    CAST((p.net_revenue - c.cost_amount) AS DECIMAL(14, 2)) AS gross_margin
FROM (
    SELECT COUNT(DISTINCT order_id) AS orders
    FROM fact_orders
    WHERE order_date = DATE('{{ target_date }}')
      AND status IN ('PAID', 'COMPLETED')
) o
CROSS JOIN (
    SELECT
        COUNT(DISTINCT CASE WHEN net_amount > 0 THEN customer_id END) AS paying_customers,
        CAST(COALESCE(SUM(amount), 0) AS DECIMAL(14, 2)) AS gross_revenue,
        CAST(COALESCE(SUM(refund_amount), 0) AS DECIMAL(14, 2)) AS refunds,
        CAST(COALESCE(SUM(net_amount), 0) AS DECIMAL(14, 2)) AS net_revenue
    FROM fact_payments
    WHERE paid_date = DATE('{{ target_date }}')
) p
CROSS JOIN (
    SELECT CAST(COALESCE(SUM(c.cost_amount), 0) AS DECIMAL(14, 2)) AS cost_amount
    FROM fact_payments p
    LEFT JOIN stg_costs c
      ON p.order_id = c.order_id
    WHERE p.paid_date = DATE('{{ target_date }}')
) c;
