# Taptime - Backlog (Post-MVP)

> Features planned after MVP completion. Ordered by dependency and priority.
> For current MVP tasks, see [PLAN.md](PLAN.md).

## v1.1 — Motivation & Extended Stats

- [ ] Heatmap calendar (GitHub-style activity visualization)
- [ ] Streak tracking (consecutive days meeting goals)
- [ ] Break timer (5m short / 15m long)
- [ ] Weekly/monthly goals
- [ ] Monthly statistics view

## v1.2 — Google Calendar Statistics (Read-Only)

> View Google Calendar events inside Taptime for context — not sync or export.
> User continues to manage Google Calendar manually.

- [ ] Google Calendar read-only integration (OAuth, view events)
- [ ] Calendar context view alongside Taptime sessions

## v2.0 — Cloud Backup

> Prerequisite for v2.1+ features that require cross-device data sharing.

- [ ] Supabase integration
- [ ] Google/Apple social login (backup-only, no custom accounts)
- [ ] Cloud backup/restore

## v2.1 — Location-Based Auto Tracking (iOS)

> Auto-detect arrival at registered places and prompt to start a timer.
> Depends on: v2.0 (Supabase) for cross-device pattern analysis.

### Core Concept

Preset gets an optional **location trigger**. When iOS detects entry into the
geofenced area, the app shows a notification prompting the user to start the timer.

### Key Technical Details

- **iOS API:** Core Location geofencing (`CLCircularRegion`)
  - Max 20 monitored regions per app (sufficient — users typically register 3-5 places)
  - Works even when app is terminated (iOS relaunches in background)
  - Very low battery impact (no continuous GPS — uses cell/Wi-Fi positioning)
  - Minimum practical radius: ~150-200m for buildings
  - Event latency: 1-5 minutes (batched for power efficiency)
- **Permission:** "Always" location (`NSLocationAlwaysAndWhenInUseUsageDescription`)
  - iOS enforces two-step prompt: "When In Use" first, then "Always" later
  - App Store review: defensible with clear auto-timer justification
- **Flutter packages:**
  - `flutter_background_geolocation` (Transistor Software) — most mature, paid license (~$299/yr)
  - `geofencing_api` — free, verify maintenance status
  - Custom Platform Channel (~150-200 lines Swift) — free, full control
- **Indoor GPS accuracy is poor** — Wi-Fi helps (10-30m), recommend 150-200m radius

### UX Flow

```
User registers location on preset (map pin or current location)
  → iOS monitors geofence in background
  → Entry detected → timer auto-starts immediately
  → Local notification: "Arrived at [Gym]. Workout timer started. [Cancel]"
  → User ignores → session recorded as-is
  → User taps Cancel → session deleted
  → (Optional) Exit detected → timer stops, session saved
```

### Tasks

- [ ] Add `LocationTrigger` model (placeName, lat/lng, radius)
- [ ] Add optional location field to Preset
- [ ] Location registration UI (map or current location)
- [ ] Geofence monitoring service (Platform Channel or package)
- [ ] Entry/exit notification handling
- [ ] Auto-start option (skip confirmation)
- [ ] Settings: enable/disable location tracking globally

## v2.2 — macOS Activity Monitor (Companion App)

> Separate native Swift menu bar app that tracks application usage on Mac.
> Shares data with Taptime iOS via Supabase.
> Depends on: v2.0 (Supabase).

### Core Concept

A lightweight macOS menu bar daemon that monitors which application is in the
foreground, parses browser window titles to identify websites, classifies
activities using rules and local AI, and syncs results to the shared Supabase
backend for unified life-pattern analytics in Taptime.

### Why Native Swift (not Flutter Desktop)

- Menu bar daemon must be always-on: native ~10-20MB RAM vs Flutter ~80-150MB
- Minimal UI needed (menu bar dropdown + settings window)
- Direct macOS API access without Platform Channel overhead
- Estimated ~1,300 lines Swift total

### Key Technical Details

**Tracking (data collection):**

| API | Data | Permission | Role |
|-----|------|-----------|------|
| `NSWorkspace` notifications | App name, bundle ID, switch time | None | Core — app-level tracking |
| `CGEventSource` | Seconds since last input | None | Core — idle detection |
| AppleScript (`NSAppleScript`) | Browser active tab URL | None (Automation prompt) | Site tracking — recommended start |
| `CGWindowListCopyWindowInfo` | Window titles (page titles) | Screen Recording | Alternative site tracking |
| Accessibility API (`AXUIElement`) | URL bar value, UI elements | Accessibility | Precise URL (advanced) |

- **Recommended path:** AppleScript first (no permissions, Chrome/Safari only)
- AppleScript-only approach may allow **Mac App Store** distribution
- CGWindowList/Accessibility approach requires **notarized direct download**

**Classification (what is this activity?):**

Three-phase approach, implement in order:

| Phase | Method | How It Works |
|-------|--------|-------------|
| 1. Rule-based | Domain/keyword → category table | `github.com` → Dev, `youtube.com` → Entertainment. User-editable. Covers ~80% of cases |
| 2. Core ML | On-device text classifier | Trained on accumulated rule-based results. Apple Create ML + Natural Language framework. Model size: few MB |
| 3. Local LLM (experimental) | MLX (embedded in app) | Context-aware: "YouTube dev tutorial" → Learning vs Entertainment. No separate install. Memory: 1-4GB |

**Fallback chain:** User rules → Core ML → MLX (each step only if previous has no match)

> Classification rules can be synced via Supabase and managed from the Taptime
> mobile app — not only from the macOS settings window.

**Filtering (what NOT to record):**

- Blocklist: specific apps or domains to exclude (e.g., messaging, social media)
- Allowlist mode: only record registered apps/sites
- Minimum duration: ignore app switches under N seconds
- Private/incognito browsing: excluded by default
- User-configurable via settings UI

### Architecture

```
Tracker (NSWorkspace + CGEvent + AppleScript)
  → Classifier (rules → Core ML → MLX)
  → Filter (blocklist/allowlist)
  → SQLite (local buffer)
  → Supabase (periodic sync)
```

### Tasks

- [ ] Swift project setup (menu bar app, SPM)
- [ ] App switch tracker (NSWorkspace notifications)
- [ ] Browser URL tracker (AppleScript for Chrome/Safari)
- [ ] Idle detection (CGEventSource, 5-min threshold)
- [ ] Rule-based classifier with JSON config
- [ ] Filter engine (blocklist/allowlist)
- [ ] Local SQLite storage
- [ ] Supabase sync (periodic upload)
- [ ] Settings UI (SwiftUI): categories, rules, filters
- [ ] Launch at login (SMAppService)
- [ ] Core ML text classifier (after data accumulation)
- [ ] Local LLM integration (experimental, MLX embedded)

## v2.3 — Life Pattern Dashboard

> Unified analytics combining iOS manual/auto sessions + macOS activity data.
> Depends on: v2.1 + v2.2 data flowing into Supabase.

### Core Concept

A new analytics view in Taptime iOS app that combines all data sources to
reveal how the user actually spends their time across devices and locations.

### Features

- [ ] Daily timeline — hour-by-hour visualization (manual + auto + Mac data)
- [ ] Category time distribution — donut chart (Dev, Exercise, Learning, SNS...)
- [ ] Day-of-week patterns — "Mon/Wed/Fri: gym, Tue/Thu: cafe study"
- [ ] Device comparison — Mac vs Mobile time breakdown
- [ ] Location insights — time spent per registered place
- [ ] Productive vs unproductive ratio (based on category classification)

