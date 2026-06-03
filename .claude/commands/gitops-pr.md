keeper-gitops 레포지토리에 환경변수를 추가하고 dev/qa/prod 환경별로 PR을 생성해줘:

**중요**: TodoWrite 사용 금지 — 진행 상황은 최종 결과 테이블로만 표시
**중요**: 1단계 정보 수집 이후 모든 git 작업은 사용자 확인 없이 자동 진행
**중요**: 모든 git 명령은 keeper-gitops 레포지토리 경로에서 실행

## 1단계: 정보 수집 (한 번에 모두 질문)

아래 항목을 한꺼번에 질문한다:

1. **keeper-gitops 레포지토리 절대 경로** (예: /Users/john/projects/keeper-gitops)
2. **Jira ticket 번호** (예: KP-123)
3. **backend service 이름** (예: commerce-service)
4. **추가할 환경변수 목록** (KEY=VALUE 형식, 여러 개는 줄바꿈으로 구분)
5. **PR 제목용 설명** (추가된 환경변수에 대한 한 줄 설명, 예: 결제 서비스 외부 API 키 추가)
6. **작업할 환경** (기본값: dev, qa, prod 전체 / 특정 환경만 할 경우 명시)

## 2단계: 환경별 작업 (dev → qa → prod 순서로 순차 실행)

선택된 각 환경({env})에 대해 아래 단계를 순서대로 실행한다.

### 2-1. release branch 최신화 및 환경별 branch 생성

```bash
cd {keeper-gitops-path}
git checkout release
git pull origin release
git checkout -b feat/{jira-ticket}-{env}
```

브랜치명 예시: `feat/KP-123-dev`, `feat/KP-123-qa`, `feat/KP-123-prod`

### 2-2. set_env.yaml 파일에 환경변수 추가

- **파일 경로**: `{service-name}/env/{env}/set_env.yaml`
- 파일이 존재하면 Read 도구로 읽어 기존 내용 확인 후 `env:` 배열 아래에 항목 추가
- 파일이 존재하지 않으면 아래 기본 구조로 새로 생성

추가 형식 (env 배열):
```yaml
env:
  - name: EXISTING_KEY
    value: "existing-value"
  - name: NEW_KEY        # 새로 추가하는 항목
    value: "new-value"
```

입력받은 KEY=VALUE를 각각 `- name: KEY` / `  value: "VALUE"` 형태로 변환하여 추가한다.

### 2-3. 커밋 및 push

```bash
git add {service-name}/env/{env}/set_env.yaml
git commit -m "feat: {jira-ticket} {env} 환경변수 추가"
git push -u origin feat/{jira-ticket}-{env}
```

### 2-4. Pull Request 생성

PR 제목 형식: `[{ENV}]feat: {jira-ticket} ({설명})`

| 환경 | ENV 태그 | PR 제목 예시 |
|------|----------|-------------|
| dev  | DEV      | `[DEV]feat: KP-123 (결제 서비스 외부 API 키 추가)` |
| qa   | QA       | `[QA]feat: KP-123 (결제 서비스 외부 API 키 추가)` |
| prod | PROD     | `[PROD]feat: KP-123 (결제 서비스 외부 API 키 추가)` |

```bash
gh pr create \
  --title "[{ENV}]feat: {jira-ticket} ({설명})" \
  --body "## 추가된 환경변수

\`\`\`
{KEY=VALUE 목록}
\`\`\`

## 관련 Jira
- {jira-ticket}

## 대상 서비스
- {service-name} / {env}" \
  --base release
```

## 3단계: 완료 후 결과 테이블 출력

모든 환경 작업 완료 후 아래 형식으로 요약 출력:

| 환경 | 브랜치 | PR URL | 상태 |
|------|--------|--------|------|
| DEV  | feat/{jira-ticket}-dev  | {pr-url} | ✅ 완료 |
| QA   | feat/{jira-ticket}-qa   | {pr-url} | ✅ 완료 |
| PROD | feat/{jira-ticket}-prod | {pr-url} | ✅ 완료 |
