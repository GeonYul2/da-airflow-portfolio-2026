.PHONY: up down init run-dag psql check logs run-linux reports init-mysql run-linux-mysql check-mysql audit-public

up:
	test -f .env || cp .env.example .env
	docker compose up -d --build

down:
	docker compose down

init:
	docker compose exec airflow-apiserver bash -lc "cd /opt/airflow/project && python -m scripts.run_sql_dir --dir $${SQL_ROOT:-sql}/00_ddl"

run-dag:
	docker compose exec airflow-apiserver airflow dags trigger da_kpi_daily

psql:
	docker compose exec postgres psql -U airflow -d warehouse

check:
	docker compose exec airflow-apiserver bash -lc "cd /opt/airflow/project && python -m scripts.check_tables"

logs:
	docker compose logs -f airflow-scheduler airflow-apiserver airflow-dag-processor

run-linux:
	docker compose exec airflow-apiserver bash -lc "cd /opt/airflow/project && ./scripts/run_pipeline_linux.sh"

reports:
	ls -al logs/reports

init-mysql:
	docker compose exec -e WAREHOUSE_DSN=mysql+pymysql://airflow:airflow@mariadb:3306/warehouse -e SQL_ROOT=sql/mysql airflow-apiserver bash -lc "cd /opt/airflow/project && python -m scripts.run_sql_dir --dir sql/mysql/00_ddl"

run-linux-mysql:
	docker compose exec -e WAREHOUSE_DSN=mysql+pymysql://airflow:airflow@mariadb:3306/warehouse -e SQL_ROOT=sql/mysql airflow-apiserver bash -lc "cd /opt/airflow/project && ./scripts/run_pipeline_linux.sh"

check-mysql:
	docker compose exec -e WAREHOUSE_DSN=mysql+pymysql://airflow:airflow@mariadb:3306/warehouse airflow-apiserver bash -lc "cd /opt/airflow/project && python -m scripts.check_tables"

audit-public:
	python3 scripts/audit_public_release.py
