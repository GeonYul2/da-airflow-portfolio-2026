SELECT 'raw_customers.customer_id_null' AS check_name, COUNT(*) AS bad_rows
FROM raw_customers
WHERE customer_id IS NULL
HAVING COUNT(*) > 0

UNION ALL

SELECT 'raw_orders.order_id_null' AS check_name, COUNT(*) AS bad_rows
FROM raw_orders
WHERE order_id IS NULL
HAVING COUNT(*) > 0

UNION ALL

SELECT 'raw_orders.customer_id_null' AS check_name, COUNT(*) AS bad_rows
FROM raw_orders
WHERE customer_id IS NULL
HAVING COUNT(*) > 0

UNION ALL

SELECT 'raw_payments.payment_id_null' AS check_name, COUNT(*) AS bad_rows
FROM raw_payments
WHERE payment_id IS NULL
HAVING COUNT(*) > 0

UNION ALL

SELECT 'raw_payments.order_id_null' AS check_name, COUNT(*) AS bad_rows
FROM raw_payments
WHERE order_id IS NULL
HAVING COUNT(*) > 0;
