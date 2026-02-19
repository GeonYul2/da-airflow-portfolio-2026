DELETE FROM mart_kpi_weekly
WHERE week_start_date = DATE_SUB(DATE('{{ target_date }}'), INTERVAL WEEKDAY(DATE('{{ target_date }}')) DAY);

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
    DATE_SUB(DATE('{{ target_date }}'), INTERVAL WEEKDAY(DATE('{{ target_date }}')) DAY) AS week_start_date,
    DATE_ADD(DATE_SUB(DATE('{{ target_date }}'), INTERVAL WEEKDAY(DATE('{{ target_date }}')) DAY), INTERVAL 6 DAY) AS week_end_date,
    CAST(COALESCE(SUM(d.orders), 0) AS SIGNED) AS orders,
    CAST(COALESCE(SUM(d.paying_customers), 0) AS SIGNED) AS paying_customers,
    CAST(COALESCE(SUM(d.gross_revenue), 0) AS DECIMAL(14, 2)) AS gross_revenue,
    CAST(COALESCE(SUM(d.refunds), 0) AS DECIMAL(14, 2)) AS refunds,
    CAST(COALESCE(SUM(d.net_revenue), 0) AS DECIMAL(14, 2)) AS net_revenue,
    CAST(COALESCE(SUM(d.gross_margin), 0) AS DECIMAL(14, 2)) AS gross_margin
FROM mart_kpi_daily d
WHERE d.kpi_date BETWEEN DATE_SUB(DATE('{{ target_date }}'), INTERVAL WEEKDAY(DATE('{{ target_date }}')) DAY)
                     AND DATE_ADD(DATE_SUB(DATE('{{ target_date }}'), INTERVAL WEEKDAY(DATE('{{ target_date }}')) DAY), INTERVAL 6 DAY);
