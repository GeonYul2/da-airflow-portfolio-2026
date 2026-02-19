DELETE FROM mart_kpi_segment_daily
WHERE kpi_date = DATE('{{ target_date }}');

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
    CAST(COALESCE(p.gross_revenue, 0) AS DECIMAL(14, 2)) AS gross_revenue,
    CAST(COALESCE(p.refunds, 0) AS DECIMAL(14, 2)) AS refunds,
    CAST(COALESCE(p.net_revenue, 0) AS DECIMAL(14, 2)) AS net_revenue,
    CAST(COALESCE(p.gross_margin, 0) AS DECIMAL(14, 2)) AS gross_margin
FROM (
    SELECT
        DATE('{{ target_date }}') AS kpi_date,
        COALESCE(dc.region, 'UNKNOWN') AS region,
        COALESCE(dc.channel, 'UNKNOWN') AS channel,
        CAST(COUNT(DISTINCT fo.order_id) AS SIGNED) AS orders
    FROM fact_orders fo
    LEFT JOIN dim_customer dc
      ON fo.customer_id = dc.customer_id
    WHERE fo.order_date = DATE('{{ target_date }}')
      AND fo.status IN ('PAID', 'COMPLETED')
    GROUP BY COALESCE(dc.region, 'UNKNOWN'), COALESCE(dc.channel, 'UNKNOWN')
) o
LEFT JOIN (
    SELECT
        DATE('{{ target_date }}') AS kpi_date,
        COALESCE(dc.region, 'UNKNOWN') AS region,
        COALESCE(dc.channel, 'UNKNOWN') AS channel,
        CAST(COUNT(DISTINCT CASE WHEN fp.net_amount > 0 THEN fp.customer_id END) AS SIGNED) AS paying_customers,
        CAST(COALESCE(SUM(fp.amount), 0) AS DECIMAL(14, 2)) AS gross_revenue,
        CAST(COALESCE(SUM(fp.refund_amount), 0) AS DECIMAL(14, 2)) AS refunds,
        CAST(COALESCE(SUM(fp.net_amount), 0) AS DECIMAL(14, 2)) AS net_revenue,
        CAST(
            COALESCE(SUM(fp.net_amount), 0) - COALESCE(SUM(COALESCE(sc.cost_amount, 0)), 0)
            AS DECIMAL(14, 2)
        ) AS gross_margin
    FROM fact_payments fp
    LEFT JOIN dim_customer dc
      ON fp.customer_id = dc.customer_id
    LEFT JOIN stg_costs sc
      ON fp.order_id = sc.order_id
    WHERE fp.paid_date = DATE('{{ target_date }}')
    GROUP BY COALESCE(dc.region, 'UNKNOWN'), COALESCE(dc.channel, 'UNKNOWN')
) p
  ON o.kpi_date = p.kpi_date
 AND o.region = p.region
 AND o.channel = p.channel

UNION

SELECT
    COALESCE(o.kpi_date, p.kpi_date) AS kpi_date,
    COALESCE(o.region, p.region) AS region,
    COALESCE(o.channel, p.channel) AS channel,
    COALESCE(o.orders, 0) AS orders,
    COALESCE(p.paying_customers, 0) AS paying_customers,
    CAST(COALESCE(p.gross_revenue, 0) AS DECIMAL(14, 2)) AS gross_revenue,
    CAST(COALESCE(p.refunds, 0) AS DECIMAL(14, 2)) AS refunds,
    CAST(COALESCE(p.net_revenue, 0) AS DECIMAL(14, 2)) AS net_revenue,
    CAST(COALESCE(p.gross_margin, 0) AS DECIMAL(14, 2)) AS gross_margin
FROM (
    SELECT
        DATE('{{ target_date }}') AS kpi_date,
        COALESCE(dc.region, 'UNKNOWN') AS region,
        COALESCE(dc.channel, 'UNKNOWN') AS channel,
        CAST(COUNT(DISTINCT fo.order_id) AS SIGNED) AS orders
    FROM fact_orders fo
    LEFT JOIN dim_customer dc
      ON fo.customer_id = dc.customer_id
    WHERE fo.order_date = DATE('{{ target_date }}')
      AND fo.status IN ('PAID', 'COMPLETED')
    GROUP BY COALESCE(dc.region, 'UNKNOWN'), COALESCE(dc.channel, 'UNKNOWN')
) o
RIGHT JOIN (
    SELECT
        DATE('{{ target_date }}') AS kpi_date,
        COALESCE(dc.region, 'UNKNOWN') AS region,
        COALESCE(dc.channel, 'UNKNOWN') AS channel,
        CAST(COUNT(DISTINCT CASE WHEN fp.net_amount > 0 THEN fp.customer_id END) AS SIGNED) AS paying_customers,
        CAST(COALESCE(SUM(fp.amount), 0) AS DECIMAL(14, 2)) AS gross_revenue,
        CAST(COALESCE(SUM(fp.refund_amount), 0) AS DECIMAL(14, 2)) AS refunds,
        CAST(COALESCE(SUM(fp.net_amount), 0) AS DECIMAL(14, 2)) AS net_revenue,
        CAST(
            COALESCE(SUM(fp.net_amount), 0) - COALESCE(SUM(COALESCE(sc.cost_amount, 0)), 0)
            AS DECIMAL(14, 2)
        ) AS gross_margin
    FROM fact_payments fp
    LEFT JOIN dim_customer dc
      ON fp.customer_id = dc.customer_id
    LEFT JOIN stg_costs sc
      ON fp.order_id = sc.order_id
    WHERE fp.paid_date = DATE('{{ target_date }}')
    GROUP BY COALESCE(dc.region, 'UNKNOWN'), COALESCE(dc.channel, 'UNKNOWN')
) p
  ON o.kpi_date = p.kpi_date
 AND o.region = p.region
 AND o.channel = p.channel;
