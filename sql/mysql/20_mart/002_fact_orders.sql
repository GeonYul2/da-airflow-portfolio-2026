TRUNCATE TABLE fact_orders;

INSERT INTO fact_orders (order_id, customer_id, order_date, status)
SELECT
    order_id,
    customer_id,
    order_date,
    status
FROM stg_orders;
