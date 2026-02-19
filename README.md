# DA KPI Pipeline (Portfolio)

Airflow + SQL + Python으로 구축한 **재무 KPI 자동화 데이터 파이프라인 포트폴리오**입니다.

---

## 0) 문제 정의

재무/매출 지표를 수작업(엑셀/수동 쿼리)으로 집계하면,
- 집계 기준이 매번 달라지고
- 정합성 오류를 늦게 발견하며
- 반복 리포팅에 시간이 많이 소모됩니다.

이 프로젝트는 이를 해결하기 위해 KPI 집계와 품질검사를 일배치로 자동화했습니다.

---

## 1) 프로젝트 한 줄 요약

`raw → staging → mart → KPI → quality checks → report export`를 일배치로 자동화하고,  
Daily/Weekly/Monthly + Region/Channel 세그먼트 KPI를 제공합니다.

---

## 2) 아키텍처 (Flow)

```mermaid
flowchart LR
    A[data/raw CSV] --> B[load_raw.py]
    B --> C[staging SQL]
    C --> D[mart SQL]
    D --> E[kpi SQL]
    E --> F[quality checks]
    F --> G{PASS?}
    G -- Yes --> H[CSV/HTML/Summary export]
    G -- No --> I[DAG fail + quality_check_runs]
```

Airflow DAG: `dags/da_kpi_daily.py`

---

## 3) 주요 구현 내용

- KPI 자동화: 매출/환불/순매출/마진 지표 일·주·월 집계
- 데이터 정합성 검증: null/중복/참조무결성/row count/kpi sanity 검사
- 운영 추적성: `quality_check_runs`에 검사 이력 저장
- 산출물 자동 생성:
  - `logs/reports/kpi_daily_YYYY-MM-DD.csv`
  - `logs/reports/dashboard_YYYY-MM-DD.html`
  - `logs/reports/pipeline_summary_YYYY-MM-DD.txt`
- 듀얼 DB 지원:
  - Postgres (`sql/*`)
  - MySQL/MariaDB (`sql/mysql/*`)

---

## 4) 실행 방법

### A. Postgres 모드 (기본)

```bash
cp .env.example .env
make up
make init
make run-linux
make check
```

### B. MySQL/MariaDB 모드

`.env`에 아래 값 설정:

```bash
WAREHOUSE_DSN=mysql+pymysql://airflow:airflow@mariadb:3306/warehouse
SQL_ROOT=sql/mysql
```

실행:

```bash
make up
make init-mysql
make run-linux-mysql
make check-mysql
```

---

## 5) Airflow UI

- URL: `http://localhost:8080`
- ID: `admin`
- 비밀번호 확인:

```bash
docker compose exec airflow-apiserver \
  python -c "import json;print(json.load(open('/opt/airflow/simple_auth_manager_passwords.json.generated'))['admin'])"
```

---

## 6) 결과 확인

```bash
cat logs/reports/kpi_daily_2026-02-17.csv
cat logs/reports/pipeline_summary_2026-02-17.txt
```

핵심 확인 포인트:
- KPI 값이 기대치와 일치하는지
- 품질검사 5종이 PASS인지

---

## 7) 시각화(대시보드) 관련 한계/확장

- 현재 저장소는 **HTML 리포트 자동 생성**까지 포함합니다.
- Tableau Public은 자동 refresh 제약이 있어, 본 포트폴리오는 수동/예시 시각화 기준으로 설명합니다.
- 실무(Tableau Server/Cloud) 환경에서는 Airflow 마지막 태스크에서 Tableau REST API refresh 연계가 가능합니다.

---

## 8) 문서

- [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md)
- [`docs/METRICS.md`](docs/METRICS.md)
- [`docs/DATA_MODEL.md`](docs/DATA_MODEL.md)
- [`docs/RUNBOOK.md`](docs/RUNBOOK.md)

---

## 9) 공개 제출 전 점검

```bash
make audit-public
```
