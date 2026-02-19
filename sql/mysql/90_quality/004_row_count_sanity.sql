WITH today_orders AS (
    SELECT COUNT(*) AS cnt
    FROM fact_orders
    WHERE order_date = DATE('{{ target_date }}')
      AND status IN ('PAID', 'COMPLETED')
),
yesterday_orders AS (
    SELECT COUNT(*) AS cnt
    FROM fact_orders
    WHERE order_date = DATE_SUB(DATE('{{ target_date }}'), INTERVAL 1 DAY)
      AND status IN ('PAID', 'COMPLETED')
)
SELECT
    'fact_orders.daily_change_out_of_range' AS check_name,
    t.cnt AS today_count,
    y.cnt AS yesterday_count
FROM today_orders t
CROSS JOIN yesterday_orders y
WHERE y.cnt > 0
  AND (t.cnt < y.cnt * 0.5 OR t.cnt > y.cnt * 2.0);
