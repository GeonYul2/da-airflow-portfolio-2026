TRUNCATE TABLE stg_payments;

INSERT INTO stg_payments (payment_id, order_id, paid_ts, paid_date, amount, refund_amount, net_amount)
SELECT
    NULLIF(TRIM(payment_id), '') AS payment_id,
    NULLIF(TRIM(order_id), '') AS order_id,
    paid_ts::TIMESTAMP,
    DATE(paid_ts) AS paid_date,
    COALESCE(amount, 0)::NUMERIC(12, 2) AS amount,
    COALESCE(refund_amount, 0)::NUMERIC(12, 2) AS refund_amount,
    (COALESCE(amount, 0) - COALESCE(refund_amount, 0))::NUMERIC(12, 2) AS net_amount
FROM raw_payments;
