TRUNCATE TABLE fact_payments;

INSERT INTO fact_payments (payment_id, order_id, customer_id, paid_date, amount, refund_amount, net_amount)
SELECT
    p.payment_id,
    p.order_id,
    o.customer_id,
    p.paid_date,
    p.amount,
    p.refund_amount,
    p.net_amount
FROM stg_payments p
LEFT JOIN fact_orders o
    ON p.order_id = o.order_id;
