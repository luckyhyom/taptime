<!-- translated from: docs/adr/0006-claude-skills-and-hooks.md @ commit c197f75 (2026-03-17) -->

# ADR-0006: Claude Code Skills and Hooks

- **상태:** 승인됨
- **날짜:** 2026-03-15
- **결정자:** 사용자, Claude

## 맥락

프로젝트에서 여러 에이전트 세션에 걸쳐 일관된 워크플로우가 필요했습니다: 기능/버그 파일 생성, 추적 문서 업데이트, 아키텍처 준수 검사, 조사 참고자료 관리. 수동 프로세스는 오류가 발생하기 쉽고 비일관적이었습니다.

## 결정

Claude Code의 **Skills** (`.claude/skills/`)를 재사용 가능한 워크플로우 자동화에, **Hooks** (`.claude/settings.json`)를 자동 코드 포맷팅에 사용.

### 생성된 스킬

| 스킬 | 목적 |
|------|------|
| `/new-feature` | FEAT 이슈 파일 생성 + PLAN.md 업데이트 |
| `/bug-report` | BUG 이슈 파일 생성 |
| `/research` | 웹 검색 전 기존 참고자료 확인 |
| `/update-docs` | PLAN.md + PROGRESS.md 동기화 |
| `/review-architecture` | 레이어 경계 및 네이밍 컨벤션 검증 |

### 생성된 훅

| 이벤트 | 트리거 | 동작 |
|--------|--------|------|
| PostToolUse | `.dart` 파일 Edit/Write | 자동 `dart format -l 120` 실행 |

### 검토한 대안

- **Commands** (`.claude/commands/`): 레거시 형식, 보조 파일 및 서브에이전트 지원 부족. Skills가 권장 대체.
- **MCP Servers**: 현재 요구에 과잉. 향후 Supabase 연동 (v2.0) 시 고려.
- **자동화 없음**: 에이전트가 모든 컨벤션을 기억하는 것에 의존 — 과거 실수에서 보듯 오류 발생 가능.

## 결과

- 에이전트가 수동 파일 생성 대신 `/new-feature timer-pause` 사용 가능
- Dart 파일이 수동 개입 없이 항상 일관되게 포맷됨
- 기존 참고자료를 먼저 확인하여 조사 중복 방지
- 스킬은 세션 시작 시 Claude Code가 자동 검색 (설명만 — 요청 시 로드)
