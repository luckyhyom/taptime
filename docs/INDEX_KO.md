<!-- translated from: docs/INDEX.md @ commit c197f75 (2026-03-17) -->

# Taptime 문서 맵

> 모든 프로젝트 문서의 중앙 색인. 무엇이든 찾으려면 여기서 시작하세요.

## 프로젝트 관리

- [CLAUDE.md](../CLAUDE.md): Claude 전용 워크플로우 규칙 및 세션 시작 지침
- [AGENTS.md](../AGENTS.md): 크로스 에이전트 진입점 (CLAUDE.md 참조)
- [PLAN.md](../PLAN.md): 단계별 태스크 체크리스트 — 해야 할 일
- [PROGRESS.md](../PROGRESS.md): 완료 로그 및 현재 상태 — 한 일

## 기획 (제품 결정)

- [PRD](planning/PRD.md): 전체 제품 요구사항 및 기능 사양
- [MVP 스펙](planning/MVP_SPEC.md): MVP 범위, 데이터 모델, 아키텍처, 마일스톤
- [기획 변경 이력](planning/CHANGELOG_PLANNING.md): 사용자 입력(한국어) 포함 제품 결정 히스토리

## 엔지니어링 규칙

- [커밋 규칙](../.claude/rules/commit-rules.md): Conventional Commits 형식, 원자적 커밋 가이드라인
- [코드 스타일](../.claude/rules/code-style.md): Dart/Flutter 컨벤션, 린트, 네이밍, import 순서
- [아키텍처](../.claude/rules/architecture.md): 2레이어 MVVM + Repository, 기능 우선 폴더 구조
- [테스팅](../.claude/rules/testing.md): 유닛/위젯/통합 테스트 전략 및 컨벤션
- [주의사항](../.claude/rules/pitfalls.md): 알려진 실수와 방지 규칙 — 모든 에이전트 필독

## 아키텍처 결정 (ADR)

- [ADR-0001](adr/0001-flutter-local-first.md): Flutter 로컬 우선, 백엔드 서버 없음
- [ADR-0002](adr/0002-two-layer-mvvm-architecture.md): 풀 Clean Architecture 대신 2레이어 MVVM
- [ADR-0003](adr/0003-riverpod-state-management.md): 상태 관리에 Riverpod
- [ADR-0004](adr/0004-file-based-issue-tracking.md): docs/issues/에 파일 기반 이슈 추적
- [ADR-0005](adr/0005-conventional-commits.md): Conventional Commits 표준
- [ADR-0006](adr/0006-claude-skills-and-hooks.md): Claude Code Skills and Hooks
- [ADR-0007](adr/0007-drift-database.md): Drift를 로컬 데이터베이스로 (Isar 교체)

## 이슈 & 기능

- [이슈 템플릿](issues/TEMPLATE.md): BUG/FEAT 파일 템플릿
- 이슈 파일은 `docs/issues/`에 접두사 명명으로 저장:
  - `FEAT-NNN_short-name.md` — 새 기능 구현 기록
  - `BUG-NNN_short-name.md` — 버그 리포트 및 해결 기록

## 참고자료 (조사 자료)

- [경쟁 분석](references/competitive_analysis.md): 8개 경쟁 앱 비교 (aTimeLogger, Forest, Session, Toggl 등)
- [기술 스택](references/tech_stack.md): Flutter 패키지, DB 비교, 의존성 목록
- [디자인 시스템](references/design_system.md): Material 3, 컬러 팔레트, 타이포그래피, 아이콘
- [커밋 컨벤션](references/commit_conventions.md): Conventional Commits 조사 및 대안
- [아키텍처 패턴](references/architecture_patterns.md): Flutter에서의 Clean Architecture, MVVM, DDD, SOLID
- [프로젝트 스캐폴딩](references/project_scaffolding.md): 스캐폴딩 도구, Documentation-as-Code, ADR 표준, Claude Code 플러그인
- [Drift 데이터베이스](references/drift_database.md): Drift 설정, 의존성, Flutter 베스트 프랙티스

## 스킬 (슬래시 커맨드)

Claude Code 세션에서 `/커맨드명`으로 사용 가능한 커스텀 스킬:

- `/new-feature <name>` — FEAT 이슈 파일 생성 및 PLAN.md 업데이트
- `/bug-report <name>` — BUG 이슈 파일 생성
- `/research <topic>` — 기존 참고자료 확인 후 필요 시 웹 검색
- `/update-docs` — 작업 완료 후 PLAN.md와 PROGRESS.md 동기화
- `/review-architecture [target]` — 아키텍처 규칙 준수 여부 검증

스킬은 `.claude/skills/` (프로젝트별)와 `~/.claude/skills/` (범용)에 정의되어 있습니다.
범용 스킬 (`/init-project`)은 모든 프로젝트에서 사용 가능합니다.

## 가이드

- [온보딩](guides/ONBOARDING.md): 신규 참여자 읽기 순서
- [설정](guides/SETUP.md): 개발 환경 설정 (Flutter, Xcode, Android)

## 팁

- [토큰 효율](tips/token-efficiency.md): AI 토큰 최적화를 위한 문서 배치 및 언어 팁
- [컨텍스트 윈도우](tips/context-window.md): /context 명령어 해석 가이드
- [Claude Code 플러그인](tips/claude-code-plugins.md): 플러그인 추천 및 선택 가이드
- [CocoaPods](tips/cocoapods.md): CocoaPods가 하는 일과 Flutter iOS에 필요한 이유
- [인덱싱과 메모리](tips/indexing-and-memory.md): INDEX.md와 MEMORY.md 작동 방식, 에이전트 문서 검색
- [서브에이전트 & 플랜 모드](tips/subagents-and-plan-mode.md): 서브에이전트와 플랜 모드 사용 시점 및 주의사항

## 개인

- [대화 로그](conversations/LOG.md): 토론 기록 (사용자 요청 시에만 작성)

---

## 작업별 참조

| 작업 | 먼저 읽을 것 |
|------|-----------|
| 새 기능 | 아키텍처 규칙 → MVP 스펙 → issues/에 `FEAT-NNN` 생성 |
| 버그 수정 | 관련 기능 코드 → issues/에 `BUG-NNN` 생성 |
| 기획 변경 | PRD → PRD 업데이트 → Planning Changelog에 기록 |
| 기술 결정 | 기존 ADR 확인 → adr/에 새 ADR 생성 |
| 조사 | references/ 먼저 확인 → 새 조사 결과 추가 |
| 세션 시작 | PLAN.md → PROGRESS.md (모든 에이전트 필수) |
