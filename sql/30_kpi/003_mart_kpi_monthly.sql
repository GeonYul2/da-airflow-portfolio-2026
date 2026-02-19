WITH params AS (
    SELECT DATE_TRUNC('month', '{{ target_date }}'::DATE)::DATE AS month_start_date
)
DELETE FROM mart_kpi_monthly m
USING params p
WHERE m.month_start_date = p.month_start_date;

WITH params AS (
    SELECT DATE_TRUNC('month', '{{ target_date }}'::DATE)::DATE AS month_start_date
),
monthly AS (
    SELECT
        p.month_start_date,
        (p.month_start_date + INTERVAL '1 month - 1 day')::DATE AS month_end_date,
        COALESCE(SUM(d.orders), 0)::INTEGER AS orders,
        COALESCE(SUM(d.paying_customers), 0)::INTEGER AS paying_customers,
        COALESCE(SUM(d.gross_revenue), 0)::NUMERIC(14, 2) AS gross_revenue,
        COALESCE(SUM(d.refunds), 0)::NUMERIC(14, 2) AS refunds,
        COALESCE(SUM(d.net_revenue), 0)::NUMERIC(14, 2) AS net_revenue,
        COALESCE(SUM(d.gross_margin), 0)::NUMERIC(14, 2) AS gross_margin
    FROM params p
    LEFT JOIN mart_kpi_daily d
      ON DATE_TRUNC('month', d.kpi_date)::DATE = p.month_start_date
    GROUP BY p.month_start_date
)
INSERT INTO mart_kpi_monthly (
    month_start_date,
    month_end_date,
    orders,
    paying_customers,
    gross_revenue,
    refunds,
    net_revenue,
    gross_margin
)
SELECT
    month_start_date,
    month_end_date,
    orders,
    paying_customers,
    gross_revenue,
    refunds,
    net_revenue,
    gross_margin
FROM monthly;
