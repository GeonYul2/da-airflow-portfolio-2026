TRUNCATE TABLE stg_payments;

INSERT INTO stg_payments (payment_id, order_id, paid_ts, paid_date, amount, refund_amount, net_amount)
SELECT
    NULLIF(TRIM(payment_id), '') AS payment_id,
    NULLIF(TRIM(order_id), '') AS order_id,
    CAST(paid_ts AS DATETIME) AS paid_ts,
    DATE(paid_ts) AS paid_date,
    CAST(COALESCE(amount, 0) AS DECIMAL(12, 2)) AS amount,
    CAST(COALESCE(refund_amount, 0) AS DECIMAL(12, 2)) AS refund_amount,
    CAST((COALESCE(amount, 0) - COALESCE(refund_amount, 0)) AS DECIMAL(12, 2)) AS net_amount
FROM raw_payments;
