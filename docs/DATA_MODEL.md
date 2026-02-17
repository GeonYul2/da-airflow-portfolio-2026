# DATA MODEL

## Raw
- `raw_customers(customer_id, signup_date, region, channel)`
- `raw_orders(order_id, customer_id, order_ts, status)`
- `raw_payments(payment_id, order_id, paid_ts, amount, refund_amount)`
- `raw_costs(order_id, cost_amount)`

## Staging
- `stg_customers`
- `stg_orders` (`order_date` 파생)
- `stg_payments` (`paid_date`, `net_amount` 파생)
- `stg_costs`

## Mart
- `dim_customer(customer_id, signup_date, first_order_date, region, channel)`
- `fact_orders(order_id, customer_id, order_date, status)`
- `fact_payments(payment_id, order_id, customer_id, paid_date, amount, refund_amount, net_amount)`
- `mart_kpi_daily(kpi_date, orders, paying_customers, gross_revenue, refunds, net_revenue, gross_margin)`

## 관계
- `dim_customer.customer_id` ← `fact_orders.customer_id`
- `fact_orders.order_id` ← `fact_payments.order_id`
