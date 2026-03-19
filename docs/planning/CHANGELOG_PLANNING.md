# Taptime - Planning Changelog

> Tracks all planning changes with background, intent, and original user input.
> **Rule:** User's original input is recorded in Korean under "Original". All other content in English.

---

## [2026-03-14] Initial Planning

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

- **App name:** Taptime — chosen from 5 candidates for its tap-to-start UX concept
- **Platform:** Flutter (iOS + Android)
- **Storage:** Local-first (Isar DB), with repository pattern for future cloud swap
- **Auth:** No auth in MVP; architecture supports future auth injection (`AuthService` interface with `LocalAuthService` pass-through)
- **Design system:** Minimal 2-3 color palette, dark mode support, Flutter ThemeData
- **Calendar integration:** Deferred to post-MVP; `CalendarService` interface defined with `NoOpCalendarService` placeholder

### Documents Created

- `docs/PRD.md` — Full product requirements
- `docs/MVP_SPEC.md` — MVP scope, data model, architecture, milestones

### Enhancements Added (from competitive research)

Features suggested based on research of aTimeLogger, Forest, Session, Toggl Track, Clockify, Focus To-Do:

- Post-session memo (one-line reflection, inspired by Session app)
- Streak tracking for consecutive goal completions
- Cumulative visualization concept for long-term motivation (inspired by Forest)
- Weekly/monthly goals in addition to daily goals
- Manual session entry for past activities
- Data export (CSV/JSON) as pre-step to Google Calendar

---

## [2026-03-14] Architecture Simplification — Remove Backend

### Original (User Input)

> 백엔드 서버 없이 수파베이스나 파이어베이스를 활용해서도 가능한가요?
> 팀 기능, 랭킹은 우리의 기획에 포함되어있나요? 이건 필요 없습니다.
> 히트맵, 스트릭같은 동기부여를 위한 기능 기획이 좋을 것 같아요.
> 멀티 디바이스 동기화도 필요 없어보입니다.
> 오프라인 지원이 필요합니다. 만약 백엔드가 있다면 동기화하는 방식으로 업데이트하면 좋을것 같은데 더 나은 의견이 있다면 알려주세요.

### Background

Discussion revealed that NestJS + SQL backend is over-engineering for a personal time tracking app. The data volume (presets ~20, sessions ~3,000/year) doesn't justify a separate server. Adding a backend with offline support would actually increase Flutter complexity (dual storage + sync + conflict resolution). Supabase can serve as cloud backup when needed, without a custom backend.

### Changes

- **Removed:** NestJS backend, Docker, PostgreSQL, team features, rankings, multi-device sync
- **Added:** Heatmap (GitHub-style activity calendar), Streaks (consecutive goal days), Data export/import (JSON)
- **Changed:** Cloud backup strategy from custom backend → Supabase (post-MVP)
- **Changed:** Google Calendar integration from server-mediated → client-side OAuth
- **Updated:** PRD.md (v1.0 → v1.1), PLAN.md backlog, MVP_SPEC.md

### Impact

- Project complexity significantly reduced — single Flutter codebase only
- No infrastructure to manage (no Docker, no server deployment)
- MVP delivery timeline shortened
- Data export/import added to MVP as minimal backup safety net

---

## [2026-03-15] Database Change — Isar to Drift

### Original (User Input)

> Drift로 결정합시다

### Background

Isar was selected in the initial planning phase but turned out to be abandoned with no active maintenance. During Phase 1, dependency conflicts between `isar_generator` and `build_runner` blocked code generation. Drift (SQLite-based) was recommended as the alternative and approved by the user.

### Changes

- **Changed:** Local database from Isar to Drift (ADR-0007)
- **Updated:** `docs/references/drift_database.md` — Drift setup research
- **To update:** `pubspec.yaml` (replace isar packages with drift packages)
- **To update:** `docs/references/tech_stack.md`, `docs/planning/MVP_SPEC.md` (Isar → Drift references)

### Impact

- No architectural change — repository pattern remains the same, only data source implementation changes
- Code generation workflow unchanged (`build_runner` still used)
- SQLite file format makes debugging and data inspection easier

---

## [2026-03-19] Life Pattern Tracking — Location + macOS Activity Monitor

### Original (User Input)

> 생활 패턴을 파악하기위해 시간을 기록하는 앱을 만들고싶습니다, IOS는 gps기능을
> 통해 자신이 등록한 장소 (헬스장)에 있을때 설정한 프리셋으로 시간을 기록하고,
> 맥북의 움직임을 감지해 실질적으로 시간을 어디에 소모했는지 파악하고싶어요.

> Macbook은 브라우저나 터미널 사용도 감지해서 무슨 사이트인지에 따라 시간을
> 분류하여 기록하는거에요. 사용자가 미리 사이트를 정해놓을수도 있고,
> 로컬ai를 활용하여 무엇과 관련된 것인지 분류하는거죠.. 그리고 분류한것중에서도
> 필터링을 통해 기록하지 않을것도 확인하구요.

### Background

User wants to evolve Taptime from a manual timer app into a life-pattern
analysis tool. Two new capabilities: (1) iOS GPS geofencing to auto-detect
arrival at registered places and prompt timer start, (2) a macOS companion
menu bar app that tracks application and browser usage, classifies activities
by site/domain, and syncs data for unified analytics.

### Changes

- **Created:** `BACKLOG.md` — separated post-MVP features from PLAN.md
- **Created:** `docs/issues/FEAT-002_life-pattern-tracking.md` — full technical spec
- **Updated:** `PLAN.md` — removed backlog section, added link to BACKLOG.md
- **Updated:** `docs/INDEX.md` — added BACKLOG.md entry
- **Added to backlog:** v2.1 (Location tracking), v2.2 (macOS companion), v2.3 (Pattern dashboard)

### Impact

- No impact on current MVP development — all features are post-v2.0
- v2.0 (Supabase) becomes a prerequisite for cross-device data sharing
- macOS companion is a separate native Swift project, not part of the Flutter codebase
- Mac App Store distribution not viable for site-level tracking (Screen Recording permission) — plan for notarized direct download

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
