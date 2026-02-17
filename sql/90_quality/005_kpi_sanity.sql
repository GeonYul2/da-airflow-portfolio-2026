SELECT
    'mart_kpi_daily.invalid_finance_values' AS check_name,
    kpi_date,
    gross_revenue,
    refunds,
    net_revenue
FROM mart_kpi_daily
WHERE kpi_date = '{{ target_date }}'::DATE
  AND (net_revenue < 0 OR refunds > gross_revenue);
