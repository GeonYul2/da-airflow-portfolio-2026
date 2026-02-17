import os
from pathlib import Path
from typing import Dict, Iterable, Optional

import psycopg2


DEFAULT_DSN = "postgresql://airflow:airflow@localhost:5432/warehouse"


def get_connection():
    dsn = os.getenv("WAREHOUSE_DSN", DEFAULT_DSN)
    return psycopg2.connect(dsn)


def render_sql(sql: str, variables: Optional[Dict[str, str]] = None) -> str:
    rendered = sql
    for key, value in (variables or {}).items():
        rendered = rendered.replace(f"{{{{ {key} }}}}", value)
    return rendered


def list_sql_files(directory: str) -> Iterable[Path]:
    path = Path(directory)
    return sorted(path.glob("*.sql"))
