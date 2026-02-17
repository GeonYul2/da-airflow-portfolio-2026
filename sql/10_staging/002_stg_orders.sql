TRUNCATE TABLE stg_orders;

INSERT INTO stg_orders (order_id, customer_id, order_ts, order_date, status)
SELECT
    NULLIF(TRIM(order_id), '') AS order_id,
    NULLIF(TRIM(customer_id), '') AS customer_id,
    order_ts::TIMESTAMP,
    DATE(order_ts) AS order_date,
    UPPER(TRIM(status)) AS status
FROM raw_orders;
