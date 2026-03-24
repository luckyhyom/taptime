# FEAT-002: Location-Based Auto Tracking

- **Type:** feature
- **Priority:** high
- **Status:** open
- **Created:** 2026-03-22
- **Resolved:**
- **Related:** v2.1 in PLAN.md

## Context

Users want to automatically start timers when they arrive at specific locations (gym, library, cafe, etc.). This feature adds geofence-based monitoring using iOS CLLocationManager, allowing the app to detect when the user enters a registered area and either notify them or auto-start the linked preset's timer — even when the app is in the background.

## Technical Analysis

- **Affected layer:** data, presentation, infra (iOS native)
- **Affected feature:** location (new), preset, settings
- **Root cause:** N/A (new feature)
- **Affected files:**
  - New: LocationTrigger model/repo/table, GeofenceService interface, iOS Platform Channel, Map Picker UI
  - Modified: Preset model (FK), tables.dart, app_database.dart (migration v3), sync service, settings

## Security Consideration

- **Data exposure risk:** medium
- **Attack vector:** Location data is sensitive PII
- **Mitigation:** Location data stored locally in Drift + synced via Supabase RLS (user_id scoped). No third-party location services. iOS system permissions gate all access.

## Solution

### Phase A (Complete): Data Layer Foundation

- LocationTrigger model + Drift table + repository interface/impl
- Preset FK (locationTriggerId), DB migration v2→v3
- Supabase sync: mappers, push/pull/merge, SyncAware decorator
- SQL migration `002_location_triggers.sql` + RLS

### Phase B (Complete): iOS Platform Channel

- **Architecture:** MethodChannel (`com.taptime.taptime/geofence`) — see ADR-0009
- **Dart interface:** `GeofenceService` in `shared/services/` with event types, permission enum
- **Dart impl:** `GeofenceServiceImpl` (MethodChannel) + `NoopGeofenceService` (non-iOS)
- **Swift native:** `GeofencePlugin` — CLLocationManager geofence monitoring + UNUserNotificationCenter local notifications
- **iOS config:** Info.plist (location permissions + background mode), AppDelegate plugin registration
- **Provider:** `geofenceServiceProvider` in app_providers.dart (platform-conditional)
- **Key constraints:** Max 20 CLCircularRegion, Always authorization required for background monitoring

### Phase C–E: Pending

## Test

- **Test added:** 18 new tests (total 155, all passing)
- **Test type:** unit (MethodChannel mock via TestDefaultBinaryMessengerBinding)
- **How to verify:**
  - Dart→Native: verify method names and argument maps forwarded to channel
  - Native→Dart: simulate native callbacks, verify GeofenceEvent stream emission
  - Permission parsing: all 5 CLAuthorizationStatus values correctly mapped
  - Native Swift: manual testing on iOS device (simulator cannot trigger geofence events)

## Takeaway

(To be filled after full feature implementation)
