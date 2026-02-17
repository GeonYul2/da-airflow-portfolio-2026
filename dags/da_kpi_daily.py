from datetime import timedelta

from airflow.providers.standard.operators.bash import BashOperator
from airflow.sdk import DAG
from pendulum import datetime


TARGET_DATE_TEMPLATE = "{{ dag_run.logical_date.strftime('%Y-%m-%d') if dag_run.logical_date else dag_run.run_after.strftime('%Y-%m-%d') }}"


with DAG(
    dag_id="da_kpi_daily",
    description="Raw to KPI pipeline with quality checks",
    schedule="0 9 * * *",
    start_date=datetime(2026, 2, 10, tz="UTC"),
    catchup=True,
    max_active_runs=1,
    default_args={"retries": 1, "retry_delay": timedelta(minutes=5)},
    tags=["da", "kpi", "portfolio"],
) as dag:
    load_raw_to_postgres = BashOperator(
        task_id="load_raw_to_postgres",
        bash_command="cd /opt/airflow/project && python -m scripts.load_raw.load_raw",
    )

    build_staging = BashOperator(
        task_id="build_staging",
        bash_command="cd /opt/airflow/project && python -m scripts.run_sql_dir --dir sql/10_staging",
    )

    build_mart = BashOperator(
        task_id="build_mart",
        bash_command="cd /opt/airflow/project && python -m scripts.run_sql_dir --dir sql/20_mart",
    )

    compute_kpi_daily = BashOperator(
        task_id="compute_kpi_daily",
        bash_command=(
            "cd /opt/airflow/project && "
            f"python -m scripts.run_sql_dir --dir sql/30_kpi --target-date {TARGET_DATE_TEMPLATE}"
        ),
    )

    run_quality_checks = BashOperator(
        task_id="run_quality_checks",
        bash_command=(
            "cd /opt/airflow/project && "
            f"python -m scripts.run_quality_checks --target-date {TARGET_DATE_TEMPLATE}"
        ),
    )

    export_kpi_csv = BashOperator(
        task_id="export_kpi_csv",
        bash_command=(
            "cd /opt/airflow/project && "
            f"python -m scripts.export_kpi_csv --target-date {TARGET_DATE_TEMPLATE} "
            f"--output-path logs/reports/kpi_daily_{TARGET_DATE_TEMPLATE}.csv"
        ),
    )

    load_raw_to_postgres >> build_staging >> build_mart >> compute_kpi_daily >> run_quality_checks >> export_kpi_csv
