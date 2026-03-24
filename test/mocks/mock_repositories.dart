import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;

import 'package:taptime/features/sync/data/connectivity_monitor.dart';
import 'package:taptime/features/sync/data/sync_remote_data_source.dart';
import 'package:taptime/shared/repositories/active_timer_repository.dart';
import 'package:taptime/shared/repositories/preset_repository.dart';
import 'package:taptime/shared/repositories/session_repository.dart';
import 'package:taptime/shared/repositories/user_settings_repository.dart';
import 'package:taptime/shared/repositories/location_trigger_repository.dart';
import 'package:taptime/shared/services/geofence_service.dart';
import 'package:taptime/shared/services/sync_service.dart';

// ── 리포지토리 ────────────────────────────────────────────────

class MockPresetRepository extends Mock implements PresetRepository {}

class MockSessionRepository extends Mock implements SessionRepository {}

class MockActiveTimerRepository extends Mock implements ActiveTimerRepository {}

class MockUserSettingsRepository extends Mock implements UserSettingsRepository {}

class MockLocationTriggerRepository extends Mock implements LocationTriggerRepository {}

// ── 지오펜스 ──────────────────────────────────────────────────

class MockGeofenceService extends Mock implements GeofenceService {}

// ── 동기화 ────────────────────────────────────────────────────

class MockSyncService extends Mock implements SyncService {}

class MockSyncRemoteDataSource extends Mock implements SyncRemoteDataSource {}

class MockConnectivityMonitor extends Mock implements ConnectivityMonitor {}

class MockConnectivity extends Mock implements Connectivity {}

// ── 인증 ──────────────────────────────────────────────────────

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockGoogleSignIn extends Mock implements GoogleSignIn {}

class MockGoogleSignInAccount extends Mock implements GoogleSignInAccount {}

class MockGoogleSignInAuthentication extends Mock implements GoogleSignInAuthentication {}

class MockUser extends Mock implements User {}
