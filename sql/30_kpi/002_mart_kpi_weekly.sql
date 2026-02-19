WITH params AS (
    SELECT DATE_TRUNC('week', '{{ target_date }}'::DATE)::DATE AS week_start_date
)
DELETE FROM mart_kpi_weekly w
USING params p
WHERE w.week_start_date = p.week_start_date;

WITH params AS (
    SELECT DATE_TRUNC('week', '{{ target_date }}'::DATE)::DATE AS week_start_date
),
weekly AS (
    SELECT
        p.week_start_date,
        (p.week_start_date + INTERVAL '6 day')::DATE AS week_end_date,
        COALESCE(SUM(d.orders), 0)::INTEGER AS orders,
        COALESCE(SUM(d.paying_customers), 0)::INTEGER AS paying_customers,
        COALESCE(SUM(d.gross_revenue), 0)::NUMERIC(14, 2) AS gross_revenue,
        COALESCE(SUM(d.refunds), 0)::NUMERIC(14, 2) AS refunds,
        COALESCE(SUM(d.net_revenue), 0)::NUMERIC(14, 2) AS net_revenue,
        COALESCE(SUM(d.gross_margin), 0)::NUMERIC(14, 2) AS gross_margin
    FROM params p
    LEFT JOIN mart_kpi_daily d
      ON d.kpi_date BETWEEN p.week_start_date AND (p.week_start_date + INTERVAL '6 day')::DATE
    GROUP BY p.week_start_date
)
INSERT INTO mart_kpi_weekly (
    week_start_date,
    week_end_date,
    orders,
    paying_customers,
    gross_revenue,
    refunds,
    net_revenue,
    gross_margin
)
SELECT
    week_start_date,
    week_end_date,
    orders,
    paying_customers,
    gross_revenue,
    refunds,
    net_revenue,
    gross_margin
FROM weekly;
