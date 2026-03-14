# Technology Stack Research

> **Researched:** 2026-03-14
> **Purpose:** Evaluate and select technologies for Taptime

## Selected Stack

| Layer | Choice | Rationale |
|-------|--------|-----------|
| Platform | **Flutter** | Cross-platform (iOS + Android), single codebase, rich UI customization |
| State Management | **Riverpod** | Type-safe, testable, no BuildContext dependency, modern Flutter standard |
| Local Database | **Isar** | Flutter-native, fast, supports complex queries, no SQL boilerplate |
| Routing | **GoRouter** | Declarative, deep link ready, official Flutter team recommendation |
| Charts | **fl_chart** | Lightweight, highly customizable, good for bar/pie/line charts |
| Architecture | **Clean Architecture** | Domain/infra/presentation separation, swappable infrastructure layer |

## State Management Comparison

| Library | Pros | Cons | Verdict |
|---------|------|------|---------|
| **Riverpod** | Type-safe, compile-time checks, no context needed, great testing | Steeper learning curve | **Selected** |
| Bloc | Mature, predictable, good for large teams | Boilerplate heavy, overkill for this scale | Considered |
| Provider | Simple, official Flutter recommendation | Less type-safe, context-dependent | Too basic |
| GetX | Minimal boilerplate, fast to prototype | Poor testability, implicit magic | Not recommended |

## Database Comparison

| Database | Pros | Cons | Verdict |
|----------|------|------|---------|
| **Isar** | Flutter-native, fast, no SQL, strong typing | Relatively newer | **Selected** |
| Hive | Simple key-value, fast | Limited querying, no relations | Too simple |
| sqflite | Mature, SQL-based | Verbose, manual mapping | More maintenance |
| Drift | Type-safe SQL, code gen | SQL knowledge required, heavier setup | Overkill |
| ObjectBox | Fast, Dart-native | License restrictions for commercial use | License concern |

## Flutter Packages (MVP)

| Package | Version Strategy | Purpose | Notes |
|---------|-----------------|---------|-------|
| `flutter_riverpod` | Latest stable | State management | Core dependency |
| `isar` + `isar_flutter_libs` | Latest stable | Local DB | Needs build_runner for code gen |
| `go_router` | Latest stable | Navigation | Supports nested routes |
| `fl_chart` | Latest stable | Statistics charts | Bar, pie, line chart support |
| `uuid` | Latest stable | ID generation | For Preset/Session IDs |
| `flutter_local_notifications` | Latest stable | Timer alerts | iOS/Android notification channels |
| `vibration` | Latest stable | Haptic feedback | Timer start/stop feedback |
| `audioplayers` | Latest stable | Completion sound | Play system/custom sounds |

## Packages for Future Phases

| Package | Phase | Purpose |
|---------|-------|---------|
| `googleapis` / `google_sign_in` | v1.2 | Google Calendar integration |
| `supabase_flutter` | v2.0 | Cloud sync backend |
| `firebase_auth` | v2.0 | Authentication (alternative) |
| `lottie` | v1.2 | Motivational animations |
| `home_widget` | v3.0 | Home screen widgets |
