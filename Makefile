.PHONY: up down init run-dag psql check logs

up:
	test -f .env || cp .env.example .env
	docker compose up -d --build

down:
	docker compose down

init:
	docker compose exec airflow-apiserver bash -lc "cd /opt/airflow/project && python -m scripts.run_sql_dir --dir sql/00_ddl"

run-dag:
	docker compose exec airflow-apiserver airflow dags trigger da_kpi_daily

psql:
	docker compose exec postgres psql -U airflow -d warehouse

check:
	docker compose exec airflow-apiserver bash -lc "cd /opt/airflow/project && python -m scripts.check_tables"

logs:
	docker compose logs -f airflow-scheduler airflow-apiserver airflow-dag-processor
