from datetime import timedelta

from airflow.providers.standard.operators.bash import BashOperator
from airflow.sdk import DAG
from pendulum import datetime


TARGET_DATE_TEMPLATE = "{{ dag_run.logical_date.strftime('%Y-%m-%d') if dag_run.logical_date else dag_run.run_after.strftime('%Y-%m-%d') }}"
RUN_ID_TEMPLATE = "{{ run_id }}"


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
    check_raw_freshness = BashOperator(
        task_id="check_raw_freshness",
        bash_command=(
            "cd /opt/airflow/project && "
            "python -m scripts.check_raw_freshness "
            "--max-age-hours ${RAW_FRESHNESS_MAX_HOURS:-168}"
        ),
    )

    load_raw_to_postgres = BashOperator(
        task_id="load_raw_to_postgres",
        bash_command="cd /opt/airflow/project && python -m scripts.load_raw.load_raw",
    )

    build_staging = BashOperator(
        task_id="build_staging",
        bash_command="cd /opt/airflow/project && python -m scripts.run_sql_dir --dir ${SQL_ROOT:-sql}/10_staging",
    )

    build_mart = BashOperator(
        task_id="build_mart",
        bash_command="cd /opt/airflow/project && python -m scripts.run_sql_dir --dir ${SQL_ROOT:-sql}/20_mart",
    )

    compute_kpi_daily = BashOperator(
        task_id="compute_kpi_daily",
        bash_command=(
            "cd /opt/airflow/project && "
            "python -m scripts.run_sql_dir "
            "--file ${SQL_ROOT:-sql}/30_kpi/001_mart_kpi_daily.sql "
            f"--target-date {TARGET_DATE_TEMPLATE}"
        ),
    )

    compute_kpi_weekly = BashOperator(
        task_id="compute_kpi_weekly",
        bash_command=(
            "cd /opt/airflow/project && "
            "python -m scripts.run_sql_dir "
            "--file ${SQL_ROOT:-sql}/30_kpi/002_mart_kpi_weekly.sql "
            f"--target-date {TARGET_DATE_TEMPLATE}"
        ),
    )

    compute_kpi_monthly = BashOperator(
        task_id="compute_kpi_monthly",
        bash_command=(
            "cd /opt/airflow/project && "
            "python -m scripts.run_sql_dir "
            "--file ${SQL_ROOT:-sql}/30_kpi/003_mart_kpi_monthly.sql "
            f"--target-date {TARGET_DATE_TEMPLATE}"
        ),
    )

    compute_kpi_segment_daily = BashOperator(
        task_id="compute_kpi_segment_daily",
        bash_command=(
            "cd /opt/airflow/project && "
            "python -m scripts.run_sql_dir "
            "--file ${SQL_ROOT:-sql}/30_kpi/004_mart_kpi_segment_daily.sql "
            f"--target-date {TARGET_DATE_TEMPLATE}"
        ),
    )

    run_quality_checks = BashOperator(
        task_id="run_quality_checks",
        bash_command=(
            "cd /opt/airflow/project && "
            "python -m scripts.run_quality_checks "
            "--dir ${SQL_ROOT:-sql}/90_quality "
            f"--target-date {TARGET_DATE_TEMPLATE} --run-id {RUN_ID_TEMPLATE}"
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

    export_kpi_dashboard = BashOperator(
        task_id="export_kpi_dashboard",
        bash_command=(
            "cd /opt/airflow/project && "
            f"python -m scripts.export_kpi_dashboard --target-date {TARGET_DATE_TEMPLATE} "
            f"--output-path logs/reports/dashboard_{TARGET_DATE_TEMPLATE}.html"
        ),
    )

    write_pipeline_summary = BashOperator(
        task_id="write_pipeline_summary",
        bash_command=(
            "cd /opt/airflow/project && "
            "python -m scripts.write_pipeline_summary "
            f"--target-date {TARGET_DATE_TEMPLATE} "
            f"--run-id {RUN_ID_TEMPLATE} "
            f"--output-path logs/reports/pipeline_summary_{TARGET_DATE_TEMPLATE}.txt"
        ),
    )

    (
        check_raw_freshness
        >> load_raw_to_postgres
        >> build_staging
        >> build_mart
        >> compute_kpi_daily
        >> compute_kpi_weekly
        >> compute_kpi_monthly
        >> compute_kpi_segment_daily
        >> run_quality_checks
        >> export_kpi_csv
        >> export_kpi_dashboard
        >> write_pipeline_summary
    )
