# PUBLIC SUBMISSION GUIDE

## 0) 핵심 답변
GitHub URL을 제출하면, **public 저장소의 파일/커밋/브랜치 내용은 모두 열람 가능**합니다.

---

## 1) 권장 전략 (가장 안전)

### 전략 A (권장): 제출용 별도 public repo 생성
- 실사용/실험 히스토리는 private 유지
- 제출용은 꼭 필요한 코드/문서만 담아 별도 공개

장점:
- 과거 커밋/실수 노출 위험 최소화
- 채용 담당자가 보기 쉬운 형태로 정리 가능

---

## 2) 공개 전 체크리스트

1. 민감정보 없는지 검사
```bash
make audit-public
```

2. `.env`, 로그, 캐시, 개인키 파일이 추적되지 않았는지 확인
```bash
git ls-files | grep -E '(^\\.env$|\\.pem$|\\.key$|id_rsa|logs/)'
```

3. 실행 재현성 확인
```bash
make up
make init
make run-linux
make check
```

4. 문서 확인
- `README.md`
- `docs/ARCHITECTURE.md`
- `docs/INTERVIEW_STORYLINE.md`

---

## 3) 제출용 브랜치/리포지토리 운영 예시

### 3-1) 로컬에서 제출용 브랜치 생성
```bash
git checkout -b portfolio-public-2026
```

### 3-2) (권장) 제출용 새 remote 연결 후 push
```bash
git remote add public-origin <YOUR_PUBLIC_REPO_URL>
git push -u public-origin portfolio-public-2026:main
```

> 이 방식이면 기존 `origin`의 private 운영 흐름과 분리됩니다.

---

## 4) 면접에서 이렇게 설명하면 좋음

“제출용 저장소는 보안과 가독성을 위해 별도로 분리했습니다.  
코드 실행 재현성을 검증했고, 데이터 정합성 검사와 리포트 자동화를 포함해 실무형 분석 파이프라인 관점으로 구성했습니다.”
