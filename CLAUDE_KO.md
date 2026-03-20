<!-- translated from: CLAUDE.md @ commit e0c1316 (2026-03-18) -->

# Taptime - Claude Code 규칙

> 전체 문서 맵은 `docs/INDEX.md`를 참조하세요.
> 코딩 표준은 `.claude/rules/`를 참조하세요.

## 세션 시작 (필수)

**모든 에이전트 세션은 반드시 다음 파일을 순서대로 읽어야 합니다:**

1. **PLAN.md** — 어떤 작업이 있는지, 무엇이 완료되었고 다음은 무엇인지 파악
2. **PROGRESS.md** — 현재 상태, 블로커, 이전 에이전트의 노트 파악

두 파일을 읽기 전에 구현 작업을 시작하지 마세요.

## 프로젝트 개요

- **앱:** Taptime — 프리셋 기반 뽀모도로 타이머를 가진 시간 관리 앱
- **플랫폼:** Flutter (iOS + Android), 로컬 우선 (Drift/SQLite)
- **아키텍처:** 2레이어 MVVM + Repository 패턴, 기능 우선 폴더 구조
- **상태 관리:** Riverpod

## 문서 규칙

### 언어

- 모든 `.md` 문서는 **영어**로 작성해야 합니다
- 예외: 사용자의 원본 입력은 "Original" 섹션에 **한국어**로 기록
- `*_KO.md` 파일은 사람 독자를 위한 한국어 번역본이며, 에이전트는 이를 무시해야 합니다
- 번역 관리 규칙은 `docs/tips/multilingual-docs.md`를 참조하세요

### 문서 맵

- **`docs/INDEX.md`**는 모든 프로젝트 문서의 중앙 색인입니다
- 새 문서를 만들기 전에 먼저 확인하세요 — 중복 방지
- 새 문서를 추가할 때 업데이트하세요

### 기획 변경

- 기획 변경이 발생하면, `docs/planning/CHANGELOG_PLANNING.md`를 다음 항목으로 업데이트하세요:
  - **Original (사용자 입력):** 사용자의 정확한 한국어 원문, 인용
  - **Background:** 변경이 필요했던 이유 (영어로)
  - **Changes:** 무엇이 수정되었고 어디인지 (영어로)
  - **Impact:** 다른 기능/계획에 대한 하위 영향 (영어로)
- 또한 관련 원본 문서(`PRD.md` 또는 `MVP_SPEC.md`)도 업데이트하세요

### PLAN.md vs PROGRESS.md

| 파일 | 목적 | 내용 | 업데이트 시점 |
|------|------|------|-------------|
| `PLAN.md` | 해야 할 일 | 단계, 태스크, 우선순위, 백로그 | 태스크 추가/제거/완료(`[x]`) 시 |
| `PROGRESS.md` | 현재 상태 & 인수인계 | 상태, 다음 에이전트 노트, 최근 2-3개 세션만 | 매 커밋 |

- **PLAN.md:** 단계별로 그룹화된 모든 태스크의 체크리스트. 태스크 완료 시 `[x]`로 표시. 여기에 상태나 로그를 넣지 마세요.
- **PROGRESS.md:** 다음 에이전트를 위한 현재 상태 + 인수인계 노트. 최근 2-3개 세션만 유지하고, 더 오래된 이력은 git log에 남깁니다. 여기에 미래 태스크를 넣지 마세요.

### 커밋 규칙

- 매 커밋마다 `PROGRESS.md`를 업데이트하세요
- 완료된 태스크를 `PLAN.md`에서 `[x]`로 표시하세요

### 이슈 및 기능 추적

- 모든 이슈와 기능 기록은 `docs/issues/`에 저장합니다
- 템플릿 사용: `docs/issues/TEMPLATE.md`
- 명명 규칙: 기능은 `FEAT-NNN_short-name.md`, 버그는 `BUG-NNN_short-name.md`
- 기능을 구현하거나 버그를 수정할 때 해당 파일을 생성하세요

### 대화 로그

- `docs/conversations/LOG.md` — **사용자가 명시적으로 요청할 때만** 기록

### 참고자료

- 조사 자료는 `docs/references/`에 저장
- 웹 검색 전에 기존 참고자료를 먼저 확인하세요

### 스킬 (슬래시 커맨드)

- 커스텀 스킬은 `.claude/skills/`에 있습니다 — 일관된 워크플로우를 위해 사용
- `/new-feature`, `/bug-report`, `/research`, `/update-docs`, `/review-architecture`
- 자세한 설명은 `docs/INDEX.md`를 참조하세요

### 아키텍처 결정

- 기술 선택이 이루어지거나 변경될 때 `docs/adr/NNNN-title.md`에 기록하세요

## 서브에이전트 워크플로우

메인 컨텍스트를 코드 작성에 집중시키기 위해 서브에이전트를 사용하세요.

| 작업 | 에이전트 | 이유 |
|------|---------|------|
| API/라이브러리 문서 조회 | `context7-plugin:docs-researcher` | 문서가 길어서 요약만 메인 컨텍스트로 가져오기 위함 |
| 코드베이스 탐색 (재사용, 패턴) | `Explore` agent | 메인 컨텍스트에서 수십 개 파일 읽기를 막기 위함 |
| 구현 계획 수립 | `Plan` agent | 설계 결정을 코딩 컨텍스트와 분리하기 위함 |
| 빌드 검증 (`analyze` + `test`) | `/flutter-verify` 또는 백그라운드 `general-purpose` agent | 빌드 출력이 가장 큰 컨텍스트 오염원이기 때문 |

규칙:

- 코드를 작성한 뒤 커밋 전에 `/flutter-verify`를 실행하세요
- GoRouter, Riverpod, Drift 또는 패키지 API를 볼 때는 `docs-researcher`를 사용하고, 메인 컨텍스트에서 문서를 직접 가져오지 마세요
- 여러 파일에서 재사용 가능한 코드를 찾을 때는 `Explore` agent를 사용하세요
- Drift 스키마를 수정한 뒤에는 `dart run build_runner build --delete-conflicting-outputs`를 실행하세요

## 코드 재사용

새 코드를 작성하기 전에 **기존 코드를 먼저 검색하세요:**

- Utility 함수 → `lib/core/utils/`
- Shared 모델 → `lib/shared/models/`
- Repository 인터페이스 → `lib/shared/repositories/`
- Constants → `lib/core/constants/`
- Widgets → `lib/features/*/ui/widgets/`

규칙:

- 새 쿼리를 추가하기 전에 기존 repository 메서드를 재사용할 수 있는지 확인하세요
- 구현체 내부에서도 기존 helper (예: `_queryByDateRange`, `_toModel`)를 재사용하세요
- 2개 이상 기능에서 같은 로직이 필요하면 `core/utils/`로 추출하세요
- 구현 후에는 `/simplify`를 실행해 놓친 재사용 기회를 점검하세요
