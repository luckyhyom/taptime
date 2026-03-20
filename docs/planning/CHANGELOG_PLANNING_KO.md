<!-- translated from: docs/planning/CHANGELOG_PLANNING.md @ commit 8740555 (2026-03-19) -->

# Taptime - 기획 변경 이력

> 모든 기획 변경 사항을 배경, 의도, 원본 사용자 입력과 함께 추적합니다.
> **규칙:** 사용자의 원본 입력은 "Original" 아래에 한국어로 기록합니다. 그 외 내용은 영어 원문을 기준으로 번역합니다.

---

## [2026-03-14] 초기 기획

### Original (User Input)

> 시간 관리 앱을 만들려고 합니다.
> 1. 시간을 기록하고 통계를 볼 수 있습니다.
> 2. 휴대폰에 프리셋을 만들어 시간을 간단하게 기록합니다.
> 3. 프리셋을 직접 만들 수 있습니다. (e.g. 운동 60분, 공부 25분)
> 4. 프리셋을 클릭하면 설정된 시간만큼 뽀모도로 타이머가 시작됩니다.
> 5. 시간이 완료되거나, 정지를 누르면 처음 시작한 시간부터 종료시점까지 분단위로 저장됩니다.
> 6. 나중에 이 데이터는 구글 캘린더에 연동되는 것을 목표로 합니다. 이를 위해 코드에 인프라 레이어를 두어 교체하기 용이하게 해도 좋습니다.
> 7. 추후 동기부여를 위해 프리셋 클릭 시 재밌는 이펙트를 추가하거나 목표 달성률을 표시합니다. (시간 기록과 별개로 하루 목표 시간도 설정할 수 있도록 합니다.)
>
> 디자인: 심플하고 2~3가지의 적은 색으로 이루어졌으면 좋겠습니다. 최근 트렌드인 디자인 서비스를 하나 정하여 작업하는 것이 좋겠습니다.

### Decisions Made

- **앱 이름:** Taptime — 탭 한 번으로 시작하는 UX 개념을 잘 담아 5개 후보 중 선택
- **플랫폼:** Flutter (iOS + Android)
- **저장소:** 로컬 우선 (Isar DB), 향후 클라우드 교체를 위한 repository 패턴 유지
- **Auth:** MVP에서는 인증 없음; 향후 인증 주입을 지원하도록 아키텍처 설계 (`AuthService` 인터페이스 + `LocalAuthService` pass-through)
- **디자인 시스템:** 최소 2-3색 팔레트, 다크 모드 지원, Flutter ThemeData 사용
- **Calendar 연동:** MVP 이후로 연기; `CalendarService` 인터페이스와 `NoOpCalendarService` placeholder 정의

### Documents Created

- `docs/PRD.md` — 전체 제품 요구사항
- `docs/MVP_SPEC.md` — MVP 범위, 데이터 모델, 아키텍처, 마일스톤

### Enhancements Added (from competitive research)

aTimeLogger, Forest, Session, Toggl Track, Clockify, Focus To-Do 조사 결과를 바탕으로 추가된 기능:

- 세션 후 메모 (Session 앱 참고)
- 연속 목표 달성 스트릭
- 장기 동기부여를 위한 누적 시각화 컨셉 (Forest 참고)
- 일일 목표 외 주간/월간 목표
- 과거 활동을 위한 수동 세션 입력
- Google Calendar 이전 단계로서의 데이터 내보내기 (CSV/JSON)

---

## [2026-03-14] 아키텍처 단순화 — 백엔드 제거

### Original (User Input)

> 백엔드 서버 없이 수파베이스나 파이어베이스를 활용해서도 가능한가요?
> 팀 기능, 랭킹은 우리의 기획에 포함되어있나요? 이건 필요 없습니다.
> 히트맵, 스트릭같은 동기부여를 위한 기능 기획이 좋을 것 같아요.
> 멀티 디바이스 동기화도 필요 없어보입니다.
> 오프라인 지원이 필요합니다. 만약 백엔드가 있다면 동기화하는 방식으로 업데이트하면 좋을것 같은데 더 나은 의견이 있다면 알려주세요.

### Background

논의 결과 NestJS + SQL 백엔드는 개인 시간 기록 앱에는 과도한 설계라는 결론이 났습니다. 데이터 규모(프리셋 약 20개, 세션 연 3,000개 수준)는 별도 서버를 정당화하지 못합니다. 오프라인 지원과 함께 백엔드를 넣으면 Flutter 복잡도(이중 저장소 + sync + conflict resolution)만 증가합니다. Supabase는 필요할 때 클라우드 백업 용도로 충분합니다.

### Changes

- **제거:** NestJS 백엔드, Docker, PostgreSQL, 팀 기능, 랭킹, 멀티 디바이스 sync
- **추가:** Heatmap (GitHub 스타일 활동 캘린더), Streaks (연속 목표 달성), Data export/import (JSON)
- **변경:** 클라우드 백업 전략을 custom backend에서 Supabase (post-MVP)로 변경
- **변경:** Google Calendar 연동을 서버 중개 방식에서 client-side OAuth로 변경
- **업데이트:** PRD.md (v1.0 → v1.1), PLAN.md backlog, MVP_SPEC.md

### Impact

- 프로젝트 복잡도가 크게 감소 — Flutter 코드베이스 하나로 유지
- 관리할 인프라가 없음 (Docker, 서버 배포 불필요)
- MVP 출시 일정 단축
- 클라우드 백업 전 최소 안전망으로 data export/import 추가

---

## [2026-03-15] 데이터베이스 변경 — Isar에서 Drift로

### Original (User Input)

> Drift로 결정합시다

### Background

초기 기획 단계에서 Isar를 선택했지만, 이후 유지보수가 중단된 상태이고 `isar_generator`와 `build_runner`의 의존성 충돌로 코드 생성이 막히는 문제가 확인되었습니다. 그 대안으로 Drift (SQLite 기반)를 제안했고 사용자가 승인했습니다.

### Changes

- **변경:** 로컬 데이터베이스를 Isar에서 Drift로 교체 (ADR-0007)
- **업데이트:** `docs/references/drift_database.md` — Drift 설정 조사
- **업데이트 예정:** `pubspec.yaml` (isar 패키지 제거, drift 패키지 추가)
- **업데이트 예정:** `docs/references/tech_stack.md`, `docs/planning/MVP_SPEC.md` (Isar → Drift 참조 수정)

### Impact

- 아키텍처 자체는 변경 없음 — repository 패턴은 유지되고 data source 구현만 바뀜
- 코드 생성 워크플로우는 동일 (`build_runner` 계속 사용)
- SQLite 파일 포맷이라 디버깅과 데이터 확인이 더 쉬움

---

## [2026-03-19] 생활 패턴 추적 — 위치 + macOS 활동 모니터

### Original (User Input)

> 생활 패턴을 파악하기위해 시간을 기록하는 앱을 만들고싶습니다, IOS는 gps기능을
> 통해 자신이 등록한 장소 (헬스장)에 있을때 설정한 프리셋으로 시간을 기록하고,
> 맥북의 움직임을 감지해 실질적으로 시간을 어디에 소모했는지 파악하고싶어요.

> Macbook은 브라우저나 터미널 사용도 감지해서 무슨 사이트인지에 따라 시간을
> 분류하여 기록하는거에요. 사용자가 미리 사이트를 정해놓을수도 있고,
> 로컬ai를 활용하여 무엇과 관련된 것인지 분류하는거죠.. 그리고 분류한것중에서도
> 필터링을 통해 기록하지 않을것도 확인하구요.

### Background

사용자는 Taptime을 수동 타이머 앱에서 생활 패턴 분석 도구로 확장하고자 했습니다. 새로 추가된 두 기능은 (1) 등록된 장소 도착을 감지해 타이머 시작을 제안하는 iOS GPS geofencing, (2) 앱/브라우저 사용을 추적하고 사이트/도메인별 활동을 분류하여 통합 분석 데이터로 동기화하는 macOS companion menu bar 앱입니다.

### Changes

- **생성:** `BACKLOG.md` — PLAN.md에서 post-MVP 기능 분리
- **생성:** `docs/issues/FEAT-002_life-pattern-tracking.md` — 전체 기술 사양
- **업데이트:** `PLAN.md` — backlog 섹션 제거, `BACKLOG.md` 링크 추가
- **업데이트:** `docs/INDEX.md` — `BACKLOG.md` 항목 추가
- **백로그 추가:** v2.1 (위치 추적), v2.2 (macOS companion), v2.3 (패턴 대시보드)

### Impact

- 현재 MVP 개발에는 영향 없음 — 모든 기능은 post-v2.0 범위
- 교차 디바이스 데이터 공유를 위해 v2.0 (Supabase)가 선행 조건이 됨
- macOS companion은 Flutter 코드베이스 일부가 아니라 별도 native Swift 프로젝트
- 사이트 수준 추적에 필요한 Screen Recording 권한 때문에 Mac App Store 배포는 현실적이지 않음 — 공증된 직접 다운로드 방식 계획

---

<!-- TEMPLATE FOR NEW ENTRIES

## [YYYY-MM-DD] Change Title

### Original (User Input)

> (User's words in Korean, quoted as-is)

### Background

(Why was this change needed? What problem or insight triggered it?)

### Changes

(What was changed in which document, and how)

### Impact

(What other features or plans are affected by this change?)

-->
