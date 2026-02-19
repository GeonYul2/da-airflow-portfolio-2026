DELETE FROM mart_kpi_segment_daily
WHERE kpi_date = '{{ target_date }}'::DATE;

WITH daily_orders AS (
    SELECT
        '{{ target_date }}'::DATE AS kpi_date,
        COALESCE(dc.region, 'UNKNOWN') AS region,
        COALESCE(dc.channel, 'UNKNOWN') AS channel,
        fo.order_id,
        fo.customer_id
    FROM fact_orders fo
    LEFT JOIN dim_customer dc
      ON fo.customer_id = dc.customer_id
    WHERE fo.order_date = '{{ target_date }}'::DATE
      AND fo.status IN ('PAID', 'COMPLETED')
),
daily_payments AS (
    SELECT
        '{{ target_date }}'::DATE AS kpi_date,
        COALESCE(dc.region, 'UNKNOWN') AS region,
        COALESCE(dc.channel, 'UNKNOWN') AS channel,
        fp.payment_id,
        fp.order_id,
        fp.customer_id,
        fp.amount,
        fp.refund_amount,
        fp.net_amount,
        COALESCE(sc.cost_amount, 0)::NUMERIC(14, 2) AS cost_amount
    FROM fact_payments fp
    LEFT JOIN dim_customer dc
      ON fp.customer_id = dc.customer_id
    LEFT JOIN stg_costs sc
      ON fp.order_id = sc.order_id
    WHERE fp.paid_date = '{{ target_date }}'::DATE
),
orders_agg AS (
    SELECT
        kpi_date,
        region,
        channel,
        COUNT(DISTINCT order_id)::INTEGER AS orders
    FROM daily_orders
    GROUP BY kpi_date, region, channel
),
payments_agg AS (
    SELECT
        kpi_date,
        region,
        channel,
        COUNT(DISTINCT CASE WHEN net_amount > 0 THEN customer_id END)::INTEGER AS paying_customers,
        COALESCE(SUM(amount), 0)::NUMERIC(14, 2) AS gross_revenue,
        COALESCE(SUM(refund_amount), 0)::NUMERIC(14, 2) AS refunds,
        COALESCE(SUM(net_amount), 0)::NUMERIC(14, 2) AS net_revenue,
        (COALESCE(SUM(net_amount), 0) - COALESCE(SUM(cost_amount), 0))::NUMERIC(14, 2) AS gross_margin
    FROM daily_payments
    GROUP BY kpi_date, region, channel
)
INSERT INTO mart_kpi_segment_daily (
    kpi_date,
    region,
    channel,
    orders,
    paying_customers,
    gross_revenue,
    refunds,
    net_revenue,
    gross_margin
)
SELECT
    COALESCE(o.kpi_date, p.kpi_date) AS kpi_date,
    COALESCE(o.region, p.region) AS region,
    COALESCE(o.channel, p.channel) AS channel,
    COALESCE(o.orders, 0) AS orders,
    COALESCE(p.paying_customers, 0) AS paying_customers,
    COALESCE(p.gross_revenue, 0)::NUMERIC(14, 2) AS gross_revenue,
    COALESCE(p.refunds, 0)::NUMERIC(14, 2) AS refunds,
    COALESCE(p.net_revenue, 0)::NUMERIC(14, 2) AS net_revenue,
    COALESCE(p.gross_margin, 0)::NUMERIC(14, 2) AS gross_margin
FROM orders_agg o
FULL OUTER JOIN payments_agg p
  ON o.kpi_date = p.kpi_date
 AND o.region = p.region
 AND o.channel = p.channel;
