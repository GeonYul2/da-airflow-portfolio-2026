# RUNBOOK

## 1. 환경 시작
```bash
cp .env.example .env
make up
```

## 2. 테이블 초기화
```bash
make init
```

## 3. DAG 실행
- Airflow UI: http://localhost:8080
- ID: `admin`
- 비밀번호 확인:
```bash
docker compose exec airflow-apiserver cat /opt/airflow/simple_auth_manager_passwords.json.generated
```
- DAG: `da_kpi_daily` Trigger

또는 CLI:
```bash
make run-dag
```

## 4. KPI 확인
```bash
make psql
-- psql 내부
SELECT * FROM mart_kpi_daily ORDER BY kpi_date DESC LIMIT 14;
```

## 5. CSV 확인
```bash
ls -al logs/reports/
cat logs/reports/kpi_daily_2026-02-17.csv
```

## 6. 품질검사 실패 데모
```sql
INSERT INTO raw_payments(payment_id, order_id, paid_ts, amount, refund_amount)
VALUES ('P2001', 'O1001', NOW(), 10, 0);
```
중복 payment_id 생성 후 DAG 재실행하면 `run_quality_checks` 실패.

## 7. 복구
```sql
DELETE FROM raw_payments WHERE paid_ts::date = CURRENT_DATE AND payment_id = 'P2001';
```
