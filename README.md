# DA Airflow KPI Pipeline

Data Analyst 포트폴리오용 MVP.

- Raw CSV 적재
- Staging/Mart/KPI 변환
- 데이터 품질검사 후 실패 처리
- Airflow 일배치 자동화
- 품질검사 통과 시 KPI CSV 자동 export

## Stack
- Airflow 3.1.x (LocalExecutor)
- Postgres
- Python + SQL

## Quickstart
```bash
cp .env.example .env
make up
make init
make run-dag
```

## Airflow UI
- URL: http://localhost:8080
- ID: `admin`
- 비밀번호 확인:
```bash
docker compose exec airflow-apiserver cat /opt/airflow/simple_auth_manager_passwords.json.generated
```
- DAG: `da_kpi_daily`

## KPI 조회
```bash
make psql
```
```sql
SELECT *
FROM mart_kpi_daily
ORDER BY kpi_date DESC
LIMIT 14;
```

## CSV 결과물
- 경로: `logs/reports/kpi_daily_YYYY-MM-DD.csv`
- DAG 마지막 태스크 `export_kpi_csv`에서 생성

## 품질검사 수동 실행
```bash
make check
```

## 문서
- [PRD](docs/PRD.md)
- [METRICS](docs/METRICS.md)
- [DATA_MODEL](docs/DATA_MODEL.md)
- [RUNBOOK](docs/RUNBOOK.md)
