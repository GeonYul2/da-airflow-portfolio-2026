# METRICS

기준 타임존: UTC
- Daily Grain: `kpi_date` (`mart_kpi_daily`)
- Weekly Grain: `week_start_date`~`week_end_date` (`mart_kpi_weekly`)
- Monthly Grain: `month_start_date`~`month_end_date` (`mart_kpi_monthly`)
- Segment Daily Grain: `kpi_date x region x channel` (`mart_kpi_segment_daily`)

## 1) Orders
- 정의: `fact_orders`에서 상태가 `PAID`, `COMPLETED` 인 주문의 distinct `order_id` 수
- 식: `count(distinct order_id)`
- 제외: `CANCELLED`

## 2) Paying Customers
- 정의: 당일 `net_amount > 0` 결제를 가진 distinct `customer_id` 수
- 식: `count(distinct customer_id)`

## 3) Gross Revenue
- 정의: 당일 결제 금액 합
- 식: `sum(amount)`

## 4) Refunds
- 정의: 당일 환불 금액 합
- 식: `sum(refund_amount)`

## 5) Net Revenue
- 정의: 순매출
- 식: `sum(amount - refund_amount)`

## 6) Gross Margin
- 정의: 순매출 - 원가
- 식: `sum(net_amount - cost_amount)`

## 7) Segment KPI (Region/Channel)
- 정의: region/channel 조합별 Daily KPI
- 목적: 채널/국가 단위 성과 비교 및 대시보드 필터링

## 8) Weekly/Monthly KPI
- 정의: `mart_kpi_daily` 집계를 주간/월간 단위로 롤업
- 목적: 월/분기 리포트에 필요한 기간 단위 KPI 제공

## 한계
- 부분 환불은 `refund_amount` 누계 기준
- 결제일 기준 집계라 주문일과 차이 가능
- 원가가 없는 주문은 0으로 처리
- 주간 기준은 `DATE_TRUNC('week')` (월요일 시작)
