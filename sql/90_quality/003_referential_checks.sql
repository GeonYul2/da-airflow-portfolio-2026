SELECT 'fact_orders.customer_missing_in_dim_customer' AS check_name, fo.order_id AS ref_key_1, fo.customer_id AS ref_key_2
FROM fact_orders fo
LEFT JOIN dim_customer dc
    ON fo.customer_id = dc.customer_id
WHERE fo.customer_id IS NOT NULL
  AND dc.customer_id IS NULL

UNION ALL

SELECT 'fact_payments.order_missing_in_fact_orders' AS check_name, fp.payment_id AS ref_key_1, fp.order_id AS ref_key_2
FROM fact_payments fp
LEFT JOIN fact_orders fo
    ON fp.order_id = fo.order_id
WHERE fp.order_id IS NOT NULL
  AND fo.order_id IS NULL;
