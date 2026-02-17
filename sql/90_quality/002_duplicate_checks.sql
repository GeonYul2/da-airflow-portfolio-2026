SELECT 'raw_orders.duplicate_order_id' AS check_name, order_id, COUNT(*) AS duplicate_count
FROM raw_orders
GROUP BY order_id
HAVING order_id IS NOT NULL AND COUNT(*) > 1

UNION ALL

SELECT 'raw_payments.duplicate_payment_id' AS check_name, payment_id, COUNT(*) AS duplicate_count
FROM raw_payments
GROUP BY payment_id
HAVING payment_id IS NOT NULL AND COUNT(*) > 1;
