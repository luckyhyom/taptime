<!-- translated from: PROGRESS.md @ commit a99674a (2026-03-19) -->

# Taptime - 진행 상황

> **다음 에이전트를 위한 현재 상태와 인수인계 맥락.**
> 에이전트: 먼저 PLAN.md를 읽고, 그 다음 이 파일을 읽으세요.
> 더 오래된 이력은 git log에 있고, 이 파일에는 최근 작업만 유지합니다.

## 현재 상태

- **활성 단계:** Phase 2 (Presets) — 시작 준비 완료
- **최종 업데이트:** 2026-03-19
- **블로커:** 없음

## 다음 에이전트를 위한 노트

### 즉시 다음 태스크

Phase 2: Presets UI. 다음부터 시작:
1. 홈 화면 프리셋 그리드 (2열)
2. 프리셋 카드 위젯 (아이콘, 이름, 시간, 일일 진행률)
3. 첫 실행 시 기본 프리셋 표시

### 환경

- Flutter 3.41.4, Xcode 26.3, CocoaPods 1.16.2
- Android SDK: 후순위 (나중에 SDK 36 + BuildTools 28.0.3 필요)
- Claude Code plugin: Context7 설치 및 작동 중

### 주요 컨텍스트

- 모든 문서는 `docs/INDEX.md`에 색인되어 있음
- 개발 규칙: `.claude/rules/` (프로젝트) + `~/.claude/rules/` (범용)
- 조사 자료는 `docs/references/`에 있음 (필요 시 읽기)
- ADR-0008 확정: 상호작용 상태(forms, timer)는 `Notifier`, 읽기 전용 reactive data는 `StreamProvider` 사용
- 4개 모델 모두 constructor assertions, `toMap()`/`fromMap()`, safe enum parsing 적용 완료
- 테스트 56개 통과 (model validation, repository CRUD, cascade delete, enum fallback)

## 최근 작업

### 2026-03-19 — 설계 완성도 리뷰

- **커밋 1**: Safe enum parsing utility (`safeEnumByName`) + 모델 constructor assertions (Preset, Session, ActiveTimer)
- **커밋 2**: `AppException` sealed hierarchy + 4개 모델 모두 `toMap()`/`fromMap()` 추가; repository impl이 `fromMap` 사용하도록 리팩터링
- **커밋 3**: DB migration scaffold (`onCreate`/`onUpgrade`/`beforeOpen`) + `architecture.md`에 5개 섹션 추가 (error handling, state management patterns, cross-feature data flow, migration, model conventions)
- **커밋 4**: ADR-0008 Notifier pattern + testing rules 업데이트 (mock convention, model testing, repository testing)
- **커밋 5**: 새 테스트 55개 — model validation (3 files), mock repositories, PresetRepositoryImpl CRUD/sort/watch, SessionRepositoryImpl CRUD/date range/aggregation/cascade/enum fallback

### 2026-03-18 — Phase 1 완료

- StatefulShellRoute 기반 GoRouter 설정 (3개 탭: home/stats/settings)
- timer, preset form, history용 풀스크린 push route 추가
- Riverpod providers: DB, 4개 repository, settings stream, app init
- PresetSeeder를 FutureProvider로 연결
- 앱 진입점에 light/dark theme + MaterialApp.router 적용
- `/flutter-verify` 스킬과 서브에이전트 워크플로우 가이드라인을 CLAUDE.md에 추가
- iOS 빌드 검증 완료

### 2026-03-17 — 데이터 레이어 설계 리뷰 + 규칙 정비

- 데이터 레이어 설계 리뷰: 3개 커밋에서 8개 gap 발견 및 수정 (`docs/issues/FEAT-001_data-layer-review.md`)
  - ActiveTimer model/table/repository (crash recovery)
  - Sessions composite index, aggregate queries, reactive stream
  - Session.clearMemo(), PresetRepository.deleteAllPresets(), PresetSeeder
- `code-style.md`에 주석 규칙 추가 (세부 수준, doc vs inline, section dividers)
- `CLAUDE.md`에 코드 재사용 규칙 추가 + 조사 내용을 `docs/references/code_reuse_strategy.md`에 저장
- PROGRESS.md를 슬림 포맷으로 재구성하고 PLAN.md 용어 정리
