<!-- translated from: PROGRESS.md @ commit c197f75 (2026-03-17) -->

# Taptime - 진행 상황

> **완료된 작업과 현재 상태.** 에이전트가 현재 상태를 파악하기 위한 상태 로그.
> 에이전트: PLAN.md를 먼저 읽은 후 이 파일을 읽어 이미 완료된 작업을 확인하세요.

## 현재 상태

- **활성 단계:** Phase 1 (기반 구축) — 진행 중
- **최종 업데이트:** 2026-03-15
- **블로커:** 없음 (Android SDK는 후순위, iOS 개발 가능)

## 완료된 작업

### 2026-03-14 — 프로젝트 초기화 & 기획

- 프로젝트 디렉터리 구조 생성 (`taptime/`)
- 전체 기능 사양이 포함된 PRD 작성 (`docs/PRD.md`)
- 데이터 모델, 아키텍처, 마일스톤이 포함된 MVP 범위 정의 (`docs/MVP_SPEC.md`)
- 8개 경쟁 앱 조사, 결과 문서화 (`docs/references/competitive_analysis.md`)
- 기술 스택 선정: Flutter + Riverpod + Isar + GoRouter (`docs/references/tech_stack.md`)
- 색상 팔레트 및 UI 시스템 설계 (`docs/references/design_system.md`)
- 기획 변경 이력 수립 (`docs/CHANGELOG_PLANNING.md`)
- CLAUDE.md, PLAN.md, PROGRESS.md 워크플로우 설정

### 2026-03-14 — 아키텍처 간소화 & 문서 재구조화

- 범위에서 제거: NestJS 백엔드, Docker, 팀 기능, 랭킹, 멀티 디바이스 동기화
- 로드맵에 추가: 히트맵, 스트릭, 데이터 내보내기/가져오기
- 문서 재구조화: `docs/planning/` (제품 문서), `docs/adr/` (기술 결정)
- `.claude/rules/` 모듈식 개발 규칙 설정
- CLAUDE.md + AGENTS.md 관계 수립 (AGENTS.md가 CLAUDE.md를 참조)

### 2026-03-14 — 개발 규칙 설정

- 커밋 규칙 수립: Conventional Commits 형식 (`.claude/rules/commit-rules.md`)
- 이슈 추적 수립: `docs/issues/`에 파일 기반, 기술/보안/테스트 섹션 포함 템플릿
- 코드 스타일 규칙 수립: `very_good_analysis` 린트, Dart 컨벤션 (`.claude/rules/code-style.md`)
- 아키텍처 수립: 2레이어 MVVM + Repository, 기능 우선 폴더 구조 (`.claude/rules/architecture.md`)
- 테스팅 규칙 수립: 유닛/위젯/통합 테스트 전략 (`.claude/rules/testing.md`)
- ADR 5개 기록: 로컬 우선 아키텍처, 2레이어 MVVM, Riverpod, 파일 기반 이슈, Conventional Commits
- `docs/INDEX.md` 중앙 문서 맵 생성
- `docs/guides/ONBOARDING.md` 신규 참여자 읽기 순서 추가
- `docs/tips/` 실용 지식 추가 (토큰 효율, 컨텍스트 윈도우)
- `.claude/rules/pitfalls.md` 실수 방지 추가
- `README.md` 생성
- 누락된 조사 자료를 `docs/references/`에 저장 (커밋 컨벤션, 아키텍처 패턴)
- `docs/learning/`을 `docs/tips/`로 교체

### 2026-03-15 — 스킬, 훅 & 문서 수정

- `.claude/skills/`에 5개 커스텀 스킬 생성:
  - `new-feature` — FEAT 파일 생성 + PLAN.md 업데이트
  - `bug-report` — BUG 파일 생성
  - `research` — 웹 검색 전 참고자료 확인
  - `update-docs` — PLAN.md + PROGRESS.md 동기화
  - `review-architecture` — 아키텍처 준수 검사
- `.claude/settings.json`에 PostToolUse 훅 생성 (.dart 파일 자동 `dart format`)
- ADR-0006 기록: Claude Code Skills and Hooks
- `docs/planning/MVP_SPEC.md` 수정: Section 4를 3레이어 Clean Architecture에서 2레이어 MVVM + 기능 우선으로 업데이트 (ADR-0002 이후 오래된 내용이었음)
- `docs/issues/TEMPLATE.md` 수정: FEAT/BUG 접두사 명명 규칙 추가
- `docs/INDEX.md`에 Skills 섹션 업데이트
- `CLAUDE.md`에 Skills 참조 업데이트
- Phase 0 (기획 & 디자인) 완료

### 2026-03-15 — 재사용성 & 플러그인 패키징

- `~/.claude/skills/`에 사용자 수준 범용 스킬 생성:
  - `init-project` — 새 프로젝트 부트스트랩 (문서 구조 및 규칙 포함)
  - `new-feature`, `bug-report`, `research`, `update-docs` (범용 버전)
- `~/.claude/rules/`에 사용자 수준 범용 규칙 생성:
  - `commit-rules.md` (프로젝트별 스코프 없는 Conventional Commits)
- 프로젝트 수준 `commit-rules.md`를 프로젝트별 스코프만 포함하도록 리팩터링
- `~/workspace/claude-project-starter/`에 Claude Code 플러그인 생성:
  - `.claude-plugin/plugin.json`, 스킬, 훅, 설정, README
  - 다국어 자동 포맷 훅 (dart, js/ts, python, go, rust)
- 프로젝트 스캐폴딩 베스트 프랙티스 조사, `docs/references/project_scaffolding.md`에 저장
- `docs/INDEX.md`에 ADR-0006, 새 참고자료, 컨텍스트 윈도우 팁 업데이트

### 2026-03-15 — Phase 1 시작: 환경 & 프로젝트 설정

- Homebrew를 통해 Flutter SDK 3.41.4 (stable) 설치
- Xcode 26.3, CocoaPods 1.16.2 설치
- GitHub 레포 생성: https://github.com/luckyhyom/taptime (공개)
- 모든 커밋을 remote `origin/main`에 푸시
- `flutter create .` 완료 (org: com.taptime, platforms: ios + android)
- pubspec.yaml에 핵심 의존성 추가 (riverpod, go_router, isar, uuid)
- Claude Code용 Context7 플러그인 설치
- commit-rules.md에 커밋 타이밍 및 의존성 변경 규칙 추가

### 2026-03-15 — DB 결정: Isar → Drift

- Isar가 방치되고 build_runner 충돌이 있어 Drift(SQLite 기반)로 교체 결정
- Drift 설정 조사, `docs/references/drift_database.md`에 저장
- ADR-0007 기록: Drift를 로컬 데이터베이스로
- 사용자 결정으로 Planning Changelog 업데이트
- INDEX.md에 새 ADR 및 참고자료 업데이트
- Context7 플러그인이 설치되었으나 현재 세션에서 로드 안 됨 (블로커 아님)

### 2026-03-15 — Isar → Drift 마이그레이션

- `pubspec.yaml`에서 Isar를 Drift로 교체: `isar`, `isar_flutter_libs`, `isar_generator` 제거; `drift`, `drift_flutter`, `drift_dev` 추가
- `docs/references/tech_stack.md` 업데이트: DB 비교 테이블 및 선정 스택
- `docs/planning/MVP_SPEC.md` 업데이트: 아키텍처 테이블, 의존성 테이블, repository 주석
- `CLAUDE.md` 업데이트: 프로젝트 개요 DB 참조
- `.claude/rules/architecture.md` 업데이트: 로컬 DB 필드
- `PLAN.md` 업데이트: Phase 1 태스크 이름에서 Isar → Drift
- `flutter pub get` 실행 — 모든 의존성 해결됨

### 2026-03-15 — Phase 1 기반: 커밋 1–7 / 8

- `very_good_analysis` strict 모드로 `analysis_options.yaml` 설정
- 테마 시스템 추가: 색상 (네이비/코랄), 타이포그래피 (3 사이즈), 간격 (8px 그리드), 라이트/다크 ThemeData
- 앱 상수 추가: 기본 프리셋, 아이콘 맵 (20개), 컬러 팔레트, 타이머 범위
- 유틸리티 헬퍼 추가: DateTime 확장 (startOfDay, endOfDay, isSameDay), 시간 포매터 (MM:SS, 인간화)
- 공유 모델 정의: Preset, Session (SessionStatus 열거형 포함), UserSettings — 모두 불변, Drift 독립적
- Repository 인터페이스 정의: PresetRepository, SessionRepository, UserSettingsRepository
- 서비스 인터페이스 정의: CalendarService + NoopCalendarService (MVP 플레이스홀더)
- Drift DB 스키마 생성: Presets, Sessions, UserSettingsTable 테이블 (인덱스 및 외래 키 포함)
- build_runner로 Drift 코드 생성
- Repository 클래스 구현: PresetRepositoryImpl, SessionRepositoryImpl, UserSettingsRepositoryImpl
- 플레이스홀더 화면 생성: Home, PresetForm, Timer, History, Stats, Settings
- ShellScreen에 하단 네비게이션 바 생성 (부분 — 아직 라우터에 연결 안 됨)
- `path_provider` 의존성 추가

## 다음 에이전트를 위한 노트

### 즉시 다음 태스크

Phase 1 커밋 8/8 남음. **다음:**
1. GoRouter 설정 (`lib/core/router/app_router.dart`) — StatefulShellRoute + 하단 내비 + push 라우트
2. Riverpod 프로바이더 (`lib/core/providers/app_providers.dart`) — DB, repository, settings
3. 앱 진입점 (`lib/app.dart`, `lib/main.dart`) — MaterialApp.router + 테마 + 라우터
4. `flutter analyze`와 `flutter run`으로 모든 것이 작동하는지 확인

참고: GoRouter StatefulShellRoute API 구현 전 Context7 확인.

### 환경 상태

- Flutter 3.41.4 ✓, Xcode 26.3 ✓, CocoaPods ✓, Chrome ✓
- Android SDK: 후순위 (SDK 36 + BuildTools 28.0.3 나중에 필요)
- Claude Code 플러그인: Context7 설치 및 작동 중

### 주요 컨텍스트

- 모든 문서는 `docs/INDEX.md`에 색인됨
- 개발 규칙: `.claude/rules/` (프로젝트) + `~/.claude/rules/` (범용)
- 스킬: `.claude/skills/` (프로젝트) + `~/.claude/skills/` (범용, `/init-project` 포함)
- 조사 자료는 `docs/references/`에 있음 (필요 시 읽기)
- 대화 로그는 사용자의 말만 기록 — 에이전트 요약 추가 금지
- 사용자는 코드에 초보자 친화적 주석을 선호, 백엔드 비유 사용 금지
