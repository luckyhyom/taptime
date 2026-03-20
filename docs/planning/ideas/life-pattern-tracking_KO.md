<!-- translated from: docs/planning/ideas/life-pattern-tracking.md @ commit 7a1078f (2026-03-19) -->

# 아이디어: 생활 패턴 추적 (위치 + macOS 활동)

- **상태:** discussion (미확정)
- **작성일:** 2026-03-19
- **관련:** BACKLOG.md (v2.1, v2.2, v2.3)

## Original (User Input)

> 생활 패턴을 파악하기위해 시간을 기록하는 앱을 만들고싶습니다, IOS는 gps기능을
> 통해 자신이 등록한 장소 (헬스장)에 있을때 설정한 프리셋으로 시간을 기록하고,
> 맥북의 움직임을 감지해 실질적으로 시간을 어디에 소모했는지 파악하고싶어요.
> 어떤 방법이 있을까요? 활용할수있눈 api들과 기획을 같이 구체화해보아요.
> 필수기능 위주로요

> Macbook은 브라우저나 터미널 사용도 감지해서 무슨 사이트인지에 따라 시간을
> 분류하여 기록하는거에요. 사용자가 미리 사이트를 정해놓을수도 있고,
> 로컬ai를 활용하여 무엇과 관련된 것인지 분류하는거죠.. 그리고 분류한것중에서도
> 필터링을 통해 기록하지 않을것도 확인하구요.

> 그럼 ios는 gps 기반만 하고, 나머지 기능은 mac os만 하는걸로 하면 가능한거죠?
> Macbook을 사용할때 움직임이 없으면 기록을 멈추고, 움직임이 있는 브라우저에서
> 무슨 사이트인지에 따라 시간을 분류하여 기록하는거에요. 사용자가 미리 사이트를
> 정해놓을수도 있고, 로컬ai를 활용하여 무엇과 관련된 것인지 분류하는거죠..
> 그리고 분류한것중에서도 필터링을 통해 기록하지 않을것도 확인하구요.
> 이것들은 다 가능한거죠? flutter랑 swift 모두요. 그리고 taptime에 모두
> 통합가능한가요?

## 맥락

현재 Taptime은 시간을 기록하려면 수동으로 탭해서 시작해야 합니다. 이 기능은 두 가지 표면에서 **자동화되고 맥락을 인식하는 시간 추적**으로 제품 비전을 확장합니다.

1. **iOS** — GPS geofencing으로 등록된 장소 도착을 감지하고 타이머 시작을 제안
2. **macOS** — companion menu bar app이 앱 사용을 모니터링하고, 브라우저/터미널 활동을 사이트 기준으로 분류해 실제 시간 사용처를 기록

이 두 기능이 결합되면, Taptime은 수동 Pomodoro 타이머에서 "나는 실제로 어디에 시간을 쓰고 있는가?"를 답하는 **생활 패턴 분석 도구**로 바뀝니다.

Taptime은 **여러 컴포넌트로 구성된 하나의 제품**입니다. Flutter 모바일 앱과 native Swift macOS companion이 Supabase sync로 연결됩니다.

## 기술 분석

### Part 1: iOS 위치 기반 자동 추적 (v2.1)

- **영향 레이어:** data + presentation
- **영향 기능:** preset (location trigger), timer (auto-start)

#### API & Packages

| 구성요소 | 기술 | 메모 |
|-----------|-----------|-------|
| Geofencing | iOS Core Location `CLCircularRegion` | 최대 20개 region, 앱 종료 상태에서도 동작, 배터리 영향 적음 |
| Flutter bridge | Custom Platform Channel (~150-200 lines Swift) 또는 `flutter_background_geolocation` (유료, ~$299/년) | 무료 대안: `geofencing_api` (유지보수 상태 확인 필요) |
| 위치 권한 | `geolocator` package | 2단계: "When In Use" → "Always" |
| 로컬 알림 | `flutter_local_notifications` | 진입/이탈 알림 |

#### iOS 제약사항

| 제약 | 상세 | 대응 |
|-----------|--------|------------|
| 최대 20개 geofence | iOS 시스템 하드 제한 | 일반 사용자 기준 3-5개 장소면 충분 |
| 실용 반경 최소값 | 건물 단위로 약 150-200m | 기본값 200m 설정 |
| 이벤트 지연 | 배터리 절약을 위해 1-5분 배치 처리 | UX 문구를 "도착이 감지됨"으로 설계 |
| 실내 GPS 정확도 | 낮음 — Wi-Fi 보조 시 10-30m | 넉넉한 반경 사용 |
| "Always" 위치 권한 | App Store 심사 민감 | "등록된 장소에서 자동 타이머 시작"으로 방어 가능 |
| 백그라운드 실행 | 재실행 시 약 10초 | 상태 저장 + 알림 표시에는 충분 |

#### UX 플로우

```text
사용자가 프리셋에 위치를 등록 (지도 핀 또는 현재 위치)
  → iOS가 백그라운드에서 지오펜스 모니터링
  → 진입 감지 (앱이 종료돼 있어도 iOS가 다시 깨움)
  → 로컬 알림: "헬스장에 도착했습니다. 운동 타이머를 시작할까요?"
  → 사용자가 탭 → 앱이 열리고 프리셋 준비 → 타이머 시작
  → (선택) 이탈 감지 → "타이머를 종료할까요?" 알림
```

#### 데이터 모델 추가

```text
Preset (existing)
  + locationTrigger: LocationTrigger? (optional)

LocationTrigger (new)
  - placeName: String         "Gym", "Library"
  - latitude: double
  - longitude: double
  - radiusMeters: int         default 200
  - notifyOnEntry: bool       default true
  - autoStart: bool           default false (명시적 opt-in 필요)
```

#### 필요한 권한

```text
Info.plist:
  NSLocationWhenInUseUsageDescription
  NSLocationAlwaysAndWhenInUseUsageDescription
  UIBackgroundModes: [location]
```

---

### Part 2: macOS 활동 모니터 (v2.2)

- **영향 레이어:** 별도 native Swift app
- **영향 기능:** 새로운 companion app, Supabase를 통한 데이터 공유

#### 왜 별도 Native Swift App인가

| 요소 | Flutter macOS | Native Swift |
|--------|-------------|-------------|
| RAM 사용량 | 약 80-150MB | 약 10-20MB |
| 필요한 UI | 최소 수준 (menu bar) | menu bar가 native 패러다임 |
| API 접근 | Platform Channel 경유 | 직접 접근 |
| 항상 실행되는 용도 적합성 | 과함 | 목적에 맞음 |
| 예상 코드 규모 | ~1,500+ lines (Dart + Swift bridge) | ~1,300 lines Swift |

#### Tracking Layer (데이터 수집)

| API | 수집 데이터 | 권한 | 우선순위 |
|-----|---------------|-----------|----------|
| `NSWorkspace` notifications (`didActivateApplication`) | 앱 이름, bundle ID, 전환 시각 | **없음** | 핵심 |
| `CGEventSource.secondsSinceLastEventType` | idle time (마지막 입력 이후 초) | **없음** | 핵심 |
| `CGWindowListCopyWindowInfo` | 창 제목 (브라우저 탭 제목, 터미널 경로) | **Screen Recording** | 사이트 추적 (옵션 A) |
| AppleScript (`NSAppleScript`) | 브라우저 활성 탭 URL 직접 조회 | **없음** (최초 사용 시 Automation permission) | 사이트 추적 (옵션 B, 시작점 권장) |
| Accessibility API (`AXUIElement`) | URL bar 값, document 이름 | **Accessibility** | 정밀 URL (옵션 C) |

> **AppleScript 제한:** Chrome과 Safari에서만 안정적으로 동작합니다. Arc, Firefox 등은 지원이 불확실하거나 없습니다. Apple은 점차 Shortcuts/Intents를 선호하므로 장기적인 안정성은 보장되지 않습니다. AppleScript는 지속 polling보다는 **event-driven** 조회에 더 적합합니다.

**창 제목 예시:**

```text
"Taptime PRD - Google Docs - Google Chrome"     → site: Google Docs, category: Productivity
"Stack Overflow - How to use CoreML - Safari"   → site: Stack Overflow, category: Development
"hyomin@mac: ~/workspace/taptime — zsh"         → project: taptime, category: Development
"YouTube - 10 hour rain sounds - Arc"           → site: YouTube, category: Entertainment
```

#### Browser URL 추적 — 접근법 비교

| 접근법 | 정확도 | 복잡도 | 권한 | 메모 |
|----------|---------|-----------|-----------|-------|
| **AppleScript** | 중간 | 낮음 | Automation (자동 프롬프트) | 가장 단순. `tell app "Chrome" to get URL of active tab` |
| **CGWindowList** | 낮음 | 낮음 | Screen Recording | 창 제목만 읽고, 전체 URL은 알 수 없음 |
| **Accessibility API** | 중간 | 중간 | Accessibility | AXUIElement로 URL bar 읽기 |

**권장 경로:** 먼저 AppleScript로 시작 (가장 단순, 특수 권한 부담 적음). 나중에 다중 브라우저 지원이나 더 높은 정확도가 필요하면 Browser Extension (Chrome/Safari, Native Messaging)으로 확장할 수 있습니다.

**AppleScript 예시 (`NSAppleScript`로 Swift에서 호출):**

```applescript
-- Chrome
tell application "Google Chrome"
    get URL of active tab of front window
end tell

-- Safari
tell application "Safari"
    get URL of current tab of front window
end tell
```

#### Classification Layer (이 활동이 무엇인가?)

점진적으로 적용하는 3단계 접근:

**Phase 1 — Rule-based (먼저 구현):**

사용자가 수정 가능한 domain/keyword → category 매핑:

```json
{
  "rules": [
    { "match": "github.com",        "category": "Development" },
    { "match": "stackoverflow.com", "category": "Development" },
    { "match": "Xcode",             "category": "Development" },
    { "match": "Terminal",          "category": "Development" },
    { "match": "youtube.com",       "category": "Entertainment" },
    { "match": "notion.so",         "category": "Productivity" },
    { "match": "instagram.com",     "category": "Social Media" }
  ]
}
```

전체 분류 수요의 약 80%를 커버합니다. 사용자는 settings UI에서 규칙을 추가/편집합니다.

**Phase 2 — Apple Core ML text classifier (데이터가 쌓인 후):**

```text
Input:  window title text
        "How to implement geofencing in Flutter - Stack Overflow - Chrome"
  → Core ML text classification model (on-device, few MB)
  → Output: { Development: 0.92, Learning: 0.85, Entertainment: 0.02 }
```

- 누적된 rule-based 분류 결과를 이용해 Create ML로 학습
- Apple Natural Language framework를 사용한 텍스트 분류
- 완전히 로컬 동작 — 데이터가 기기를 벗어나지 않음

**Phase 3 — MLX 기반 Local LLM (실험, 장기):**

```text
Input:  window title + context (previous 30min activity)
        "YouTube - Flutter geofencing tutorial" + prior: Xcode 40min
  → MLX model (embedded in Swift app)
  → Output: "Flutter development tutorial → Category: Development/Learning"
```

- **MLX** (Apple Silicon용 ML framework)로 작은 LLM을 Swift 앱 내부에서 직접 실행
- "YouTube 개발 튜토리얼"과 "YouTube 음악 영상"을 문맥으로 구분 가능
- Ollama처럼 별도 설치/서버 실행 없이 앱 바이너리에 내장
- 메모리 오버헤드: 1-4GB (고급 opt-in 기능으로만 적합)

#### Classification Pipeline (Fallback Chain)

```text
URL / window title input
  → Step 1: user-defined rules 확인 (domain/keyword match)
  → 매치 발견? → 그 category 사용
  → 매치 없음?
    → Step 2: Core ML text classifier (학습된 model이 있으면)
    → confidence > threshold? → 그 category 사용
    → confidence 낮음?
      → Step 3: MLX local LLM (활성화된 경우)
      → 결과 저장 + 새 rule로 추가할지 제안
```

#### Filter Layer (무엇을 기록하지 않을 것인가)

```text
Settings:
  Blocklist:
    ☑ Messaging apps (KakaoTalk, Slack DM)
    ☑ Specific sites: instagram.com, tiktok.com
    ☑ Ignore app switches under 5 seconds
    ☑ Exclude private/incognito browsing (default)

  Allowlist mode (alternative):
    ☐ Only record registered apps/sites
```

#### Distribution

AppleScript-only 접근이라면: **Mac App Store 가능성 있음** (Screen Recording이나 Accessibility 없이 Automation permission만 필요).

CGWindowList 또는 Accessibility를 쓰면: **Mac App Store는 현실적이지 않음** → **공증된 직접 다운로드**로 배포 (RescueTime, Timing과 유사).

> **참고:** Classification rules (domain → category 매핑)은 Supabase로 sync하여 macOS SwiftUI settings window뿐 아니라 Taptime 모바일 앱에서도 관리할 수 있습니다.

#### 아키텍처

```text
┌──────────────────────────────────────────────────────┐
│  Swift Menu Bar App                                  │
│                                                      │
│  Tracker ──────→ Classifier ─→ Filter ─→ SQLite     │
│  (NSWorkspace     (Rules →      (Block/  (local      │
│   CGEvent          Core ML →    Allow)   buffer)     │
│   AppleScript)     MLX)             │                │
│                                     ↓                │
│                                Supabase (sync)       │
└──────────────────────────────────────────────────────┘
```

---

### Part 3: 생활 패턴 대시보드 (v2.3)

- **영향 레이어:** presentation (Taptime iOS app의 새 화면)
- **영향 기능:** stats (확장 분석)

#### 데이터 흐름

```text
iOS 수동 타이머 세션 ─────────────┐
iOS 위치 기반 자동 세션 ──────────┤
macOS 앱 활동 데이터 ─────────────┘
            ↓
      Supabase (통합 DB)
            ↓
      Taptime iOS app → Pattern Dashboard
```

#### 기능

| 기능 | 설명 |
|---------|------------|
| Daily timeline | 모든 데이터 소스를 결합한 시간대별 시각화 |
| Category distribution | 도넛 차트: Development 40%, Exercise 15%, SNS 10%... |
| Day-of-week patterns | "월/수/금: gym, 화/목: cafe study" |
| Device comparison | Mac vs Mobile 시간 분해 |
| Location insights | 등록된 장소별 시간 |
| Productive ratio | 카테고리 기반 생산적/비생산적 비율 |

---

## 의존성

```text
MVP (current) → v2.0 (Supabase) → v2.1 (Location) ──┐
                                 → v2.2 (macOS app) ──┤→ v2.3 (Dashboard)
```

v2.1과 v2.2는 Supabase (v2.0)가 준비되면 병렬 개발할 수 있습니다.
v2.3은 v2.1과 v2.2 양쪽 데이터가 모두 필요합니다.

## 해결안

구현 계획은 [BACKLOG.md](../../BACKLOG.md)의 v2.1, v2.2, v2.3, v2.4 섹션에 상세 task checklist로 기록되어 있습니다.

## 열린 질문

- **Supabase sync 시 raw URL을 올릴지, category만 올릴지?** macOS 앱은 분류를 위해 browsing URL을 수집합니다. Supabase로 sync할 때 raw URL까지 올릴지 (재분류와 더 풍부한 분석 가능) 아니면 결과 category + domain만 올릴지 (privacy 노출 최소화) 결정해야 합니다. 이는 data model과 user trust에 모두 영향을 줍니다.
- **AppleScript의 장기 지속성:** Apple은 Shortcuts/Intents 쪽으로 이동하고 있습니다. 향후 macOS에서 AppleScript 지원이 약해지면, 대안은 CGWindowList (Screen Recording permission 필요) 또는 Browser Extension입니다.
- **Browser Extension을 업그레이드 경로로 둘 것인가:** 핵심 구성요소는 아니지만, 나중에 Chrome/Safari extension을 추가하면 모든 브라우저에서 가장 정확한 URL 추적이 가능합니다. 대신 사용자 설치 부담이 생깁니다.

## Takeaway

- **플랫폼 분리:** iOS는 GPS만 담당하고, macOS는 모든 활동 모니터링을 담당
- **두 컴포넌트:** Flutter 모바일 앱 + native Swift macOS menu bar app
- iOS geofencing은 성숙하고 배터리 효율적인 API이며, 주요 리스크는 "Always" 위치 권한에 대한 App Store 심사
- **브라우저 URL 추적:** AppleScript부터 시작 (권한 부담 적고 가장 단순, Chrome/Safari 한정). 다중 브라우저 정확도가 필요해지면 Browser Extension으로 확장 가능
- **분류:** Rule-based로 약 80% 커버. 이후 Core ML이 중간 단계. MLX는 앱 내장 Local LLM 용도 (별도 설치 없음).
  Fallback chain: rules → Core ML → MLX
- AppleScript만 사용하는 macOS 앱은 App Store 배포 가능성이 있지만, CGWindowList/Accessibility 접근은 공증된 직접 다운로드가 필요
- Supabase는 자연스러운 sync layer이며 (이미 v2.0에 계획됨), mobile app에서 classification rules를 관리하는 기반도 됨
- macOS companion app은 Flutter desktop app이 아니라 별도 Swift 프로젝트 (~1,300줄 규모)
