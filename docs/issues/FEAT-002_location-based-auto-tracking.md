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

(To be filled during implementation)

## Test

- **Test added:** (pending)
- **Test type:** unit, widget, manual (iOS simulator)
- **How to verify:** (pending)

## Takeaway

(To be filled after implementation)
