# DA Airflow KPI Pipeline

Data Analyst 포트폴리오용 MVP.

- Raw CSV 적재
- Staging/Mart/KPI 변환
- 데이터 품질검사 후 실패 처리
- Airflow 일배치 자동화
- 품질검사 통과 시 KPI CSV 자동 export
- 주/월 KPI 자동 롤업
- region/channel 세그먼트 KPI 계산
- 품질검사 결과 이력(`quality_check_runs`) 적재
- KPI HTML 대시보드 + 파이프라인 요약 리포트 자동 생성

## 포트폴리오 제출용 요약 (1분 버전)
- 문제: 재무/매출 지표를 수작업 집계하면 느리고 오류가 발생
- 해결: Airflow + SQL + Python으로 **일별 자동 KPI 파이프라인** 구축
- 결과:
  - `raw → staging → mart → KPI → quality checks → report export` 자동화
  - 품질검사 실패 시 DAG 실패 처리 + 검사 이력 저장
  - Daily/Weekly/Monthly + Region/Channel 세그먼트 KPI 제공
  - Postgres/MySQL(MariaDB) **듀얼 실행** 가능

## 채용공고 역량 매핑 (케어네이션 DA)
- KPI 분석/리포트: `mart_kpi_daily/weekly/monthly`, HTML/CSV 요약 리포트
- 데이터 정합성 검증: null/dup/ref integrity/row count/kpi sanity + 이력 테이블
- SQL/DB 활용: Postgres + MariaDB 모두 지원, 계층형 SQL 모델링
- 자동화/운영: Airflow DAG 운영, Linux 실행 스크립트, 재실행 가능한 idempotent 구조

## Stack
- Airflow 3.1.x (LocalExecutor)
- Postgres
- MariaDB (optional warehouse mode)
- Python + SQL

## Quickstart
```bash
cp .env.example .env
make up
make init
make run-dag
```

## MySQL/MariaDB 모드 실행
```bash
# .env에 아래 2줄 추가(또는 export)
# WAREHOUSE_DSN=mysql+pymysql://airflow:airflow@mariadb:3306/warehouse
# SQL_ROOT=sql/mysql

make up
make init-mysql
make run-linux-mysql
make check-mysql
```
- DSN: `mysql+pymysql://airflow:airflow@mariadb:3306/warehouse`
- SQL 레이어: `sql/mysql/*`

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

## HTML 대시보드 결과물
- 경로: `logs/reports/dashboard_YYYY-MM-DD.html`
- `mart_kpi_daily/weekly/monthly`, `mart_kpi_segment_daily`를 포함

## 파이프라인 요약 결과물
- 경로: `logs/reports/pipeline_summary_YYYY-MM-DD.txt`
- 해당 run의 KPI 값 + 품질검사 상태 요약

## 품질검사 수동 실행
```bash
make check
```

## Linux형 수동 파이프라인 실행 (컨테이너 내부)
```bash
make run-linux
```
- 기본 target_date는 `data/raw/payments.csv`의 최신 `paid_ts` 날짜를 자동 사용
- SQL 경로는 `SQL_ROOT` 환경변수로 전환 가능 (`sql` / `sql/mysql`)

## 포트폴리오 시연 스크립트 (면접 10분)
1. 아키텍처 설명 (2분): `docs/ARCHITECTURE.md`
2. DAG 실행/모니터링 (2분): Airflow `da_kpi_daily`
3. 결과 확인 (3분): `mart_kpi_daily`, `dashboard_YYYY-MM-DD.html`
4. 장애 데모 (2분): 품질검사 실패 시 DAG fail + `quality_check_runs` 확인
5. 회고 (1분): 왜 듀얼 DB/품질 이력/자동 리포팅을 넣었는지 설명

## 면접 답변 스토리라인
- `docs/INTERVIEW_STORYLINE.md` 참고 (60초 자기소개, STAR 사례, 예상질문 포함)

## 공개 제출 전 안전 점검
```bash
make audit-public
```
- 가이드는 `docs/PUBLIC_SUBMISSION_GUIDE.md` 참고
- Public 저장소는 커밋/브랜치/파일이 모두 공개됨

## 문서
- [PRD](docs/PRD.md)
- [METRICS](docs/METRICS.md)
- [DATA_MODEL](docs/DATA_MODEL.md)
- [RUNBOOK](docs/RUNBOOK.md)
- [ARCHITECTURE](docs/ARCHITECTURE.md)
- [INTERVIEW_STORYLINE](docs/INTERVIEW_STORYLINE.md)
- [PUBLIC_SUBMISSION_GUIDE](docs/PUBLIC_SUBMISSION_GUIDE.md)
