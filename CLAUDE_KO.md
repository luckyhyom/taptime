<!-- translated from: CLAUDE.md @ commit c197f75 (2026-03-17) -->

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
| `PROGRESS.md` | 완료된 일과 현재 상태 | 완료 로그, 현재 상태, 블로커, 다음 에이전트를 위한 노트 | 매 커밋 |

- **PLAN.md:** 단계별로 그룹화된 모든 태스크의 체크리스트. 태스크 완료 시 `[x]`로 표시. 여기에 상태나 로그를 넣지 마세요.
- **PROGRESS.md:** 완료된 작업의 시간순 로그, 현재 활성 단계, 블로커, 인수인계 노트. 여기에 미래 태스크를 넣지 마세요.

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
