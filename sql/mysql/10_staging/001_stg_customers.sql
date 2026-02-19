TRUNCATE TABLE stg_customers;

INSERT INTO stg_customers (customer_id, signup_date, region, channel)
SELECT
    NULLIF(TRIM(customer_id), '') AS customer_id,
    CAST(signup_date AS DATE) AS signup_date,
    NULLIF(TRIM(region), '') AS region,
    NULLIF(TRIM(channel), '') AS channel
FROM raw_customers;
