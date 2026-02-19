# DA KPI Pipeline (Portfolio)

신입 데이터 분석가 포지션(재무/매출 분석, SQL/Python/Airflow) 기준으로 만든 **실무형 자동화 포트폴리오**입니다.

## 한 줄 소개
Airflow로 `raw → staging → mart → KPI → 품질검사 → 리포트`를 자동화하고,  
**Daily/Weekly/Monthly 재무 KPI + 세그먼트 분석**을 제공하는 데이터 파이프라인입니다.

---

## 핵심 성과
- KPI 자동화: 매출/환불/순매출/마진 지표 일배치
- 정합성 보장: null/중복/참조무결성/이상치 검사 + 실패 시 DAG 중단
- 운영 가시성: `quality_check_runs` 테이블에 검사 이력 저장
- 리포팅 자동화: CSV + HTML 대시보드 + 파이프라인 요약 리포트
- 환경 적응성: **Postgres / MariaDB(MySQL) 듀얼 실행**

---

## 기술 스택
- SQL (계층형 모델링: staging/mart/KPI)
- Python (로더, 품질검사, 리포트 자동화)
- Airflow 3.1.x (오케스트레이션)
- Docker Compose / Linux
- Postgres, MariaDB

---

## 아키텍처
- 문서: [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md)
- DAG: `dags/da_kpi_daily.py`
- SQL 레이어:
  - Postgres: `sql/*`
  - MySQL/MariaDB: `sql/mysql/*`

### Flow Chart
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

---

## 실행 방법
### 1) Postgres 모드
```bash
cp .env.example .env
make up
make init
make run-linux
make check
```

### 2) MySQL/MariaDB 모드
`.env`에:
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

## 채용공고 역량 매핑
- 사업 KPI 분석: `mart_kpi_daily/weekly/monthly`
- 재무/매출 데이터 관리: fact/mart 모델 + 재실행 가능한 파이프라인
- 리포트/대시보드: CSV/HTML 자동 생성
- 데이터 정합성 검증: 다중 품질검사 + 이력 관리
- 협업/운영: RUNBOOK, METRICS, DATA_MODEL 문서화

---

## 공개 제출 전 점검
```bash
make audit-public
```

## 문서
- [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md)
- [`docs/METRICS.md`](docs/METRICS.md)
- [`docs/DATA_MODEL.md`](docs/DATA_MODEL.md)
- [`docs/RUNBOOK.md`](docs/RUNBOOK.md)
