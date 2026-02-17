TRUNCATE TABLE stg_costs;

INSERT INTO stg_costs (order_id, cost_amount)
SELECT
    NULLIF(TRIM(order_id), '') AS order_id,
    COALESCE(cost_amount, 0)::NUMERIC(12, 2) AS cost_amount
FROM raw_costs;
