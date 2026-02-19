TRUNCATE TABLE dim_customer;

INSERT INTO dim_customer (customer_id, signup_date, first_order_date, region, channel)
SELECT
    c.customer_id,
    c.signup_date,
    MIN(o.order_date) AS first_order_date,
    c.region,
    c.channel
FROM stg_customers c
LEFT JOIN stg_orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.signup_date, c.region, c.channel;
