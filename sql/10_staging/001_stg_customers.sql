TRUNCATE TABLE stg_customers;

INSERT INTO stg_customers (customer_id, signup_date, region, channel)
SELECT
    NULLIF(TRIM(customer_id), '') AS customer_id,
    signup_date::DATE,
    NULLIF(TRIM(region), '') AS region,
    NULLIF(TRIM(channel), '') AS channel
FROM raw_customers;
