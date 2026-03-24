# ADR-0009: iOS Geofence via Platform Channel

- **Status:** Accepted
- **Date:** 2026-03-23

## Context

v2.1 adds location-based auto tracking: detect user arrival at registered places and prompt to start a timer. This requires iOS geofence monitoring (CLLocationManager + CLCircularRegion) which has no Dart-native equivalent.

## Options Considered

| Option | Pros | Cons |
|--------|------|------|
| Third-party Flutter plugin (e.g., geofencing_flutter) | Quick integration, cross-platform | Extra dependency, lags behind iOS SDK, limited customization |
| Raw MethodChannel + native Swift | Full control, no transitive deps, iOS-only scope matches v2.1 | More native code to maintain |
| Pigeon (code-gen platform channel) | Type-safe, generated boilerplate | Extra tooling for a relatively small API surface |

## Decision

Raw MethodChannel (`com.taptime.taptime/geofence`) with a custom `GeofencePlugin` in Swift.

### Rationale

- The geofence API surface is small (add/remove region, start/stop, permission) — Pigeon overhead is not justified.
- v2.1 is iOS-only; no Android implementation needed yet, so cross-platform plugins add unused complexity.
- Native notification posting (UNUserNotificationCenter) from Swift ensures notifications work even when the Flutter engine is not initialized (app terminated by OS).

## Key Design Decisions

1. **Notifications from Swift, not Flutter:** Geofence events fire when the app may be suspended. Posting UNNotification from native ensures delivery without Flutter engine dependency.
2. **GeofenceService interface in shared/services/:** Follows existing AuthService/SyncService pattern. NoopGeofenceService for non-iOS platforms.
3. **20-region limit:** CLLocationManager enforces max 20 monitored CLCircularRegion. Limit management deferred to Phase D (GeofenceManager orchestration).
4. **Permission strategy:** Request WhenInUse first, then upgrade to Always. iOS requires this two-step flow since iOS 13.

## Consequences

- Native Swift code in `ios/Runner/GeofencePlugin.swift` must be maintained alongside Dart code.
- Cannot unit-test native Swift from Flutter tests; iOS simulator does not fire geofence events. Requires real device for full verification.
- If Android support is added later, a parallel Kotlin implementation would be needed (or switch to a cross-platform approach at that point).
