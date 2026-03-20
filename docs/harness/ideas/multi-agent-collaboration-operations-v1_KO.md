<!-- translated from: docs/harness/ideas/multi-agent-collaboration-operations-v1.md @ working tree (2026-03-20) -->

# 멀티 에이전트 협업 운영안 v1

- **상태:** 초안
- **작성일:** 2026-03-20
- **범위:** 이 저장소를 위한 크로스 에이전트 협업 워크플로우

## 목적

이 문서는 특정 에이전트 런타임 하나에만 의존하지 않고, 여러 에이전트가 같은 저장소에서 작업할 때 사용할 수 있는 공통 운영 모델을 제안합니다.

줄이고자 하는 문제는 다음과 같습니다.

- 중복 작업
- 파일 소유권 충돌
- 코드 상태와 추적 문서 사이의 불일치
- Claude 전용 스킬 안에만 존재하는 프로세스 지식

이 문서는 초안 제안이며, 아직 필수 정책은 아닙니다.

## 운영 모델

### 1. 세션 진입점

모든 에이전트는 같은 source-of-truth 순서로 시작해야 합니다.

1. `AGENTS.md`
2. `CLAUDE.md`
3. `PLAN.md`
4. `PROGRESS.md`

이렇게 하면 에이전트 런타임이 달라도 온보딩이 안정적이고, 숨은 프로세스 지식을 줄일 수 있습니다.

### 2. 작업 선점

코드를 수정하기 전에, 에이전트는 하나의 구체적인 work unit과 예상 file scope를 식별해야 합니다.

권장 claim 형식:

- **Task:** 짧은 작업 이름
- **Owner:** agent/session 식별자
- **Files:** 예상 file scope
- **Status:** in progress / blocked / ready for review
- **Blockers:** 없음 또는 짧은 blocker 메모

현재 진행 중인 작업은 `PROGRESS.md`에 기록하는 것을 권장합니다. 더 큰 기능의 세부 내용은 `docs/issues/FEAT-*.md` 또는 `docs/issues/BUG-*.md`에 둡니다.

### 3. 소유권

하나의 active task는 한 시점에 한 명의 owner만 가져야 합니다.

규칙:

- 하나의 agent는 하나의 work unit을 소유
- 하나의 work unit은 하나의 선언된 file scope를 가짐
- review-only가 아닌 한, 같은 파일을 여러 agent에게 동시에 할당하지 않음
- scope가 확장되면 새 파일을 수정하기 전에 ownership note를 갱신

### 4. 인수인계

작업을 멈출 때는 `PROGRESS.md`에 짧은 handoff를 남겨야 합니다.

- 무엇이 바뀌었는지
- 무엇이 미완성인지
- 정확한 다음 작업
- blocker 또는 risk (있다면)

### 5. 종료 처리

코드가 존재한다고 해서 작업이 완료된 것은 아닙니다. 동작 상태가 검증 가능하고, 추적 문서가 현실과 일치할 때 완료입니다.

최소 종료 단계:

1. 구현 완료
2. 관련 테스트 추가 또는 갱신
3. `flutter analyze` 실행
4. `flutter test` 실행
5. `PLAN.md` 업데이트
6. `PROGRESS.md` 업데이트

## Work Unit 설계

작업은 기능 이름만이 아니라 책임 단위로 나눠야 합니다.

좋은 예:

- preset form UI layout
- preset form validation and state handling
- preset repository tests
- timer state persistence

나쁜 예:

- presets
- timer
- app polish

선호 규칙:

- 각 work unit은 한 세션 안에 끝낼 수 있을 만큼 작게 유지
- 파일 겹침을 최소화
- 필요하면 구현과 검증을 분리
- 병렬 작업 중일 때는 광범위한 리팩터보다 additive change를 선호

하나의 기능에 여러 agent가 필요하면, layer나 file set으로 ownership을 나눕니다.

예:

- Agent A: `lib/features/preset/ui/`
- Agent B: `lib/features/preset/data/`와 tests
- Agent C: widget tests only

## Source Of Truth

저장소 협업은 특정 도구 벤더 하나에 의존하면 안 됩니다.

역할을 이렇게 고정합니다.

- `PLAN.md`: backlog와 completion checklist만
- `PROGRESS.md`: current active state, handoff, blockers, next task
- `docs/issues/FEAT-*.md`, `docs/issues/BUG-*.md`: feature/bug 수준 세부 내용
- `docs/INDEX.md`: 문서 탐색용 map
- `.claude/rules/`: 프로젝트 엔지니어링 규칙

규칙:

- `PROGRESS.md`를 backlog처럼 사용하지 않음
- `PLAN.md`를 session log처럼 사용하지 않음
- 중요한 프로세스 지식을 skill 안에만 두지 않음
- 모든 런타임에 `.claude/` 자동화가 있다고 가정하지 않음

## 호환성 규칙

### 모든 에이전트 공통

다음은 Claude 전용 기능 없이도 읽고 사용할 수 있어야 합니다.

- `AGENTS.md`
- `CLAUDE.md`
- `PLAN.md`
- `PROGRESS.md`
- `docs/issues/`
- 저장소 테스트와 검증 명령

### Claude 전용 가속 장치

다음은 유용하지만, 저장소 governance의 유일한 기반이 되어서는 안 됩니다.

- `.claude/skills/`
- `.claude/settings.json`
- Dart 자동 포맷팅 같은 Claude hooks

Claude 전용 자동화는 작업을 가속해야지, 유일한 유효 워크플로우를 정의해서는 안 됩니다.

## Definition Of Done

하나의 work unit은 아래 조건이 모두 만족될 때만 done입니다.

- 합의된 scope의 구현이 완료됨
- 관련 테스트가 추가되거나 갱신됨
- `flutter analyze` 통과
- `flutter test` 통과
- `PLAN.md`가 완료 상태를 반영함
- `PROGRESS.md`가 현재 저장소 상태와 다음 작업을 반영함

## 도입 경로

이 v1 제안은 의도적으로 가볍게 설계되었습니다.

나중에 채택한다면, 안정된 부분을 다음으로 승격합니다.

- `AGENTS.md` — 범용 entrypoint
- `CLAUDE.md` — 필수 workflow 규칙
- `docs/INDEX.md` — 탐색 가능성 보장

이후 가능한 확장:

- `PROGRESS.md`에 active ownership 전용 섹션 추가
- 여러 세션에 걸친 구현에는 feature issue file을 필수화
- `pre-commit`, `pre-push` 같은 git-level verification 추가
- 도구별 습관 대신 runtime-neutral verification script 추가

## 이 v1 제안에서 선택한 기본값

- 협업 규칙은 root-only 폴더가 아니라 `docs/` 아래에 둠
- `docs/harness/ideas/`는 cross-agent operations 제안의 초안 영역
- active ownership은 `PROGRESS.md`에 기록
- feature detail은 `docs/issues/`에 유지
- Claude skills는 전역 필수 조건이 아니라 선택적 accelerator로 취급
