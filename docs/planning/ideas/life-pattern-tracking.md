# Idea: Life Pattern Tracking (Location + macOS Activity)

- **Status:** discussion (not confirmed)
- **Created:** 2026-03-19
- **Related:** BACKLOG.md (v2.1, v2.2, v2.3)

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

## Context

Taptime currently requires manual tap-to-start for time recording. This feature
extends the vision to **automatic, context-aware time tracking** across two
surfaces:

1. **iOS** — GPS geofencing detects arrival at registered places and prompts
   timer start (zero-tap recording)
2. **macOS** — A companion menu bar app monitors application usage, classifies
   browser/terminal activity by site, and records where time is actually spent

Combined, these features transform Taptime from a manual Pomodoro timer into a
**life pattern analysis tool** that answers: "Where am I actually spending my
time?"

## Technical Analysis

### Part 1: iOS Location-Based Auto Tracking (v2.1)

- **Affected layer:** data + presentation
- **Affected feature:** preset (location trigger), timer (auto-start)

#### API & Packages

| Component | Technology | Notes |
|-----------|-----------|-------|
| Geofencing | iOS Core Location `CLCircularRegion` | Max 20 regions, works when app killed, very low battery |
| Flutter bridge | Custom Platform Channel (~150-200 lines Swift) or `flutter_background_geolocation` (paid ~$299/yr) | Free alternative: `geofencing_api` (verify maintenance) |
| Location permission | `geolocator` package | Two-step: "When In Use" → "Always" |
| Local notifications | `flutter_local_notifications` | Entry/exit alerts |

#### iOS Constraints

| Constraint | Detail | Mitigation |
|-----------|--------|------------|
| Max 20 geofences | iOS system hard limit | Sufficient — users register 3-5 places typically |
| Min practical radius | ~150-200m for buildings | Set default to 200m |
| Event latency | 1-5 minutes (batched for battery) | UX says "arrival detected", not "instant" |
| Indoor GPS accuracy | Poor — Wi-Fi helps (10-30m) | Use generous radius |
| "Always" location | App Store review scrutiny | Defensible: "auto-start timer at registered place" |
| Background execution | ~10 seconds when relaunched | Enough to save state + show notification |

#### UX Flow

```
User registers location on a preset (map pin or current location)
  → iOS monitors geofence in background
  → Entry detected (even if app is killed — iOS relaunches it)
  → Local notification: "Arrived at [Gym]. Start workout timer?"
  → User taps → app opens with preset ready → timer starts
  → (Optional) Exit detected → "Stop timer?" notification
```

#### Data Model Addition

```
Preset (existing)
  + locationTrigger: LocationTrigger? (optional)

LocationTrigger (new)
  - placeName: String         "Gym", "Library"
  - latitude: double
  - longitude: double
  - radiusMeters: int         default 200
  - notifyOnEntry: bool       default true
  - autoStart: bool           default false (requires explicit opt-in)
```

#### Required Permissions

```
Info.plist:
  NSLocationWhenInUseUsageDescription
  NSLocationAlwaysAndWhenInUseUsageDescription
  UIBackgroundModes: [location]
```

---

### Part 2: macOS Activity Monitor (v2.2)

- **Affected layer:** separate native Swift app
- **Affected feature:** new companion app, shares data via Supabase

#### Why a Separate Native Swift App

| Factor | Flutter macOS | Native Swift |
|--------|-------------|-------------|
| RAM usage | ~80-150MB | ~10-20MB |
| UI needed | Minimal (menu bar) | Menu bar is native paradigm |
| API access | Via Platform Channels | Direct |
| Always-on suitability | Overkill | Designed for this |
| Estimated code | ~1,500+ lines (Dart + Swift bridge) | ~1,300 lines Swift |

#### Tracking Layer (Data Collection)

| API | Data Collected | Permission | Priority |
|-----|---------------|-----------|----------|
| `NSWorkspace` notifications (`didActivateApplication`) | App name, bundle ID, switch timestamp | **None** | Core |
| `CGEventSource.secondsSinceLastEventType` | Idle time (seconds since last input) | **None** | Core |
| `CGWindowListCopyWindowInfo` | Window titles (browser tab titles, terminal paths) | **Screen Recording** | Required for site tracking |
| Accessibility API (`AXUIElement`) | URL bar values, document names | **Accessibility** | Optional (precise URL) |

**Window title examples:**
```
"Taptime PRD - Google Docs - Google Chrome"     → site: Google Docs, category: Productivity
"Stack Overflow - How to use CoreML - Safari"    → site: Stack Overflow, category: Development
"hyomin@mac: ~/workspace/taptime — zsh"          → project: taptime, category: Development
"YouTube - 10 hour rain sounds - Arc"            → site: YouTube, category: Entertainment
```

#### Classification Layer (What Is This Activity?)

Three-phase approach, implemented incrementally:

**Phase 1 — Rule-based (implement first):**

User-editable domain/keyword → category mapping:

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

Covers ~80% of classification needs. Users add/edit rules via settings UI.

**Phase 2 — Apple Core ML text classifier (after data accumulation):**

```
Input:  window title text
        "How to implement geofencing in Flutter - Stack Overflow - Chrome"
  → Core ML text classification model (on-device, few MB)
  → Output: { Development: 0.92, Learning: 0.85, Entertainment: 0.02 }
```

- Trained on accumulated rule-based classification results using Create ML
- Apple Natural Language framework for text classification
- Fully local — no data leaves the device

**Phase 3 — Local LLM (experimental, long-term):**

```
Input:  window title + context (previous 30min activity)
        "YouTube - Flutter geofencing tutorial" + prior: Xcode 40min
  → MLX-based small LLM (Apple Silicon optimized)
  → Output: "Flutter development tutorial → Category: Development/Learning"
```

- Can distinguish context: "YouTube dev tutorial" vs "YouTube music video"
- MLX framework optimized for Apple Silicon Neural Engine
- Memory overhead: 1-4GB (only suitable as opt-in advanced feature)

#### Filter Layer (What NOT to Record)

```
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

Screen Recording and/or Accessibility permissions required for site-level
tracking → **Mac App Store distribution is not practical.**

Distribute via **notarized direct download** (same approach as RescueTime,
Timing, and other time-tracking apps).

#### Architecture

```
┌──────────────────────────────────────────────┐
│  Swift Menu Bar App                          │
│                                              │
│  Tracker ─→ Classifier ─→ Filter ─→ SQLite  │
│  (NSWorkspace  (Rules →      (Block/  (local │
│   CGWindow      CoreML →     Allow)   buffer)│
│   CGEvent)      LLM)                    │    │
│                                         ↓    │
│                                    Supabase  │
│                                    (sync)    │
└──────────────────────────────────────────────┘
```

---

### Part 3: Life Pattern Dashboard (v2.3)

- **Affected layer:** presentation (new screen in Taptime iOS app)
- **Affected feature:** stats (extended analytics)

#### Data Flow

```
iOS manual timer sessions ────────┐
iOS location-auto sessions ───────┤
macOS app activity data ──────────┘
            ↓
      Supabase (unified DB)
            ↓
      Taptime iOS app → Pattern Dashboard
```

#### Features

| Feature | Description |
|---------|------------|
| Daily timeline | Hour-by-hour visualization combining all data sources |
| Category distribution | Donut chart: Development 40%, Exercise 15%, SNS 10%... |
| Day-of-week patterns | "Mon/Wed/Fri: gym, Tue/Thu: cafe study" |
| Device comparison | Mac vs Mobile time breakdown |
| Location insights | Time per registered place |
| Productive ratio | Productive vs unproductive based on categories |

---

## Dependencies

```
MVP (current) → v2.0 (Supabase) → v2.1 (Location) ──┐
                                 → v2.2 (macOS app) ──┤→ v2.3 (Dashboard)
```

v2.1 and v2.2 can be developed in parallel once Supabase (v2.0) is ready.
v2.3 requires data from both v2.1 and v2.2.

## Solution

Implementation plan is recorded in [BACKLOG.md](../../BACKLOG.md) under
v2.1, v2.2, v2.3, and v2.4 sections with detailed task checklists.

## Takeaway

- iOS geofencing is a mature, battery-efficient API — the main risk is App
  Store review for "Always" location permission
- macOS activity monitoring needs no special permissions for basic app tracking;
  site-level tracking needs Screen Recording (forces non-App Store distribution)
- Rule-based classification covers ~80% of use cases — defer AI until data
  accumulates
- Supabase is the natural sync layer (already planned for v2.0)
- The macOS companion app is a separate Swift project (~1,300 lines), not a
  Flutter desktop app
