DELETE FROM mart_kpi_monthly
WHERE month_start_date = STR_TO_DATE(DATE_FORMAT(DATE('{{ target_date }}'), '%Y-%m-01'), '%Y-%m-%d');

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
    STR_TO_DATE(DATE_FORMAT(DATE('{{ target_date }}'), '%Y-%m-01'), '%Y-%m-%d') AS month_start_date,
    LAST_DAY(DATE('{{ target_date }}')) AS month_end_date,
    CAST(COALESCE(SUM(d.orders), 0) AS SIGNED) AS orders,
    CAST(COALESCE(SUM(d.paying_customers), 0) AS SIGNED) AS paying_customers,
    CAST(COALESCE(SUM(d.gross_revenue), 0) AS DECIMAL(14, 2)) AS gross_revenue,
    CAST(COALESCE(SUM(d.refunds), 0) AS DECIMAL(14, 2)) AS refunds,
    CAST(COALESCE(SUM(d.net_revenue), 0) AS DECIMAL(14, 2)) AS net_revenue,
    CAST(COALESCE(SUM(d.gross_margin), 0) AS DECIMAL(14, 2)) AS gross_margin
FROM mart_kpi_daily d
WHERE DATE_FORMAT(d.kpi_date, '%Y-%m') = DATE_FORMAT(DATE('{{ target_date }}'), '%Y-%m');
