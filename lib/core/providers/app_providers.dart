import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Session;

import 'package:taptime/core/config/supabase_config.dart';
import 'package:taptime/core/database/app_database.dart';
import 'package:taptime/core/database/preset_seeder.dart';
import 'package:taptime/core/providers/auth_providers.dart';
import 'package:taptime/features/history/data/session_repository_impl.dart';
import 'package:taptime/features/location/data/geofence_manager.dart';
import 'package:taptime/features/location/data/geofence_service_impl.dart';
import 'package:taptime/features/location/data/location_trigger_repository_impl.dart';
import 'package:taptime/features/location/data/noop_geofence_service.dart';
import 'package:taptime/features/preset/data/preset_repository_impl.dart';
import 'package:taptime/features/settings/data/user_settings_repository_impl.dart';
import 'package:taptime/features/sync/data/supabase_remote_data_source.dart';
import 'package:taptime/features/sync/data/supabase_sync_service.dart';
import 'package:taptime/features/sync/data/sync_aware_location_trigger_repository.dart';
import 'package:taptime/features/sync/data/sync_aware_preset_repository.dart';
import 'package:taptime/features/sync/data/sync_aware_session_repository.dart';
import 'package:taptime/features/sync/data/sync_metadata.dart';
import 'package:taptime/features/timer/data/active_timer_repository_impl.dart';
import 'package:taptime/shared/models/preset.dart';
import 'package:taptime/shared/models/user_settings.dart';
import 'package:taptime/shared/repositories/active_timer_repository.dart';
import 'package:taptime/shared/repositories/location_trigger_repository.dart';
import 'package:taptime/shared/repositories/preset_repository.dart';
import 'package:taptime/shared/repositories/session_repository.dart';
import 'package:taptime/shared/repositories/user_settings_repository.dart';
import 'package:taptime/shared/services/geofence_service.dart';
import 'package:taptime/shared/services/sync_service.dart';

// ── 데이터베이스 ──────────────────────────────────────────────

/// AppDatabase 싱글턴 프로바이더.
///
/// Riverpod의 `Provider`는 값을 생성하고 캐싱하는 컨테이너이다.
/// 한 번 생성된 값은 앱이 살아있는 동안 재사용된다 (싱글턴처럼 동작).
/// 앱 전체에서 하나의 DB 연결을 공유한다.
///
/// `ref.onDispose`는 프로바이더가 파괴될 때 호출되는 정리(cleanup) 콜백이다.
/// DB 연결 닫기, 스트림 구독 취소 등 리소스 해제에 사용한다.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

// ── 동기화 ─────────────────────────────────────────────────

/// 동기화 서비스 프로바이더.
///
/// 로그인 상태에서만 동기화 서비스를 생성하고 시작한다.
/// 로그아웃 시 자동으로 중단 및 해제된다.
final syncServiceProvider = Provider<SyncService?>((ref) {
  if (!SupabaseConfig.isConfigured) return null;

  final isLoggedIn = ref.watch(isLoggedInProvider);
  if (!isLoggedIn) return null;

  final db = ref.watch(databaseProvider);
  final remote = SupabaseRemoteDataSource(Supabase.instance.client);
  final service = SupabaseSyncService(
    db: db,
    remoteDataSource: remote,
  )..start();

  ref.onDispose(service.stop);

  return service;
});

/// 동기화 상태 스트림 프로바이더.
final syncStatusProvider = StreamProvider<SyncStatus>((ref) {
  final syncService = ref.watch(syncServiceProvider);
  if (syncService == null) return Stream.value(SyncStatus.idle);
  return syncService.watchSyncStatus();
});

/// 마지막 동기화 완료 시각 프로바이더.
///
/// syncStatus가 변할 때마다 자동으로 다시 조회한다.
final lastSyncTimeProvider = FutureProvider<DateTime?>((ref) async {
  ref.watch(syncStatusProvider);
  return SyncMetadata.getLastSyncTime();
});

// ── 지오펜스 ──────────────────────────────────────────────────

/// 지오펜스 서비스 프로바이더 (iOS 전용 플랫폼 채널).
///
/// iOS에서는 CLLocationManager 기반 GeofenceServiceImpl을 사용하고,
/// 그 외 플랫폼에서는 NoopGeofenceService를 반환한다.
/// Phase D에서 GeofenceManager가 이 서비스를 사용하여 영역 모니터링을 관리한다.
final geofenceServiceProvider = Provider<GeofenceService>((ref) {
  if (Platform.isIOS) {
    final service = GeofenceServiceImpl();
    ref.onDispose(service.dispose);
    return service;
  }
  return NoopGeofenceService();
});

/// 지오펜스 매니저 프로바이더.
///
/// locationTrackingEnabled가 true이고 iOS일 때만 활성화된다.
/// 설정이 꺼지면 Riverpod이 이전 매니저를 dispose → stop()을 호출하여
/// 모든 영역 모니터링을 중단한다.
final geofenceManagerProvider = Provider<GeofenceManager?>((ref) {
  if (!Platform.isIOS) return null;

  final settings = ref.watch(userSettingsStreamProvider).valueOrNull;
  if (settings == null || !settings.locationTrackingEnabled) return null;

  final manager = GeofenceManager(
    geofenceService: ref.read(geofenceServiceProvider),
    triggerRepo: ref.read(locationTriggerRepositoryProvider),
    presetRepo: ref.read(presetRepositoryProvider),
  )..start();

  ref.onDispose(manager.stop);

  return manager;
});

// ── 리포지토리 ────────────────────────────────────────────────

/// 프리셋 리포지토리 프로바이더.
///
/// 로그인 상태에서는 SyncAwarePresetRepository로 감싸서
/// 로컬 쓰기 후 자동으로 동기화를 트리거한다.
final presetRepositoryProvider = Provider<PresetRepository>((ref) {
  final base = PresetRepositoryImpl(ref.watch(databaseProvider));
  final syncService = ref.watch(syncServiceProvider);
  if (syncService != null) {
    return SyncAwarePresetRepository(base, syncService);
  }
  return base;
});

/// 세션 리포지토리 프로바이더.
///
/// 로그인 상태에서는 SyncAwareSessionRepository로 감싸서
/// 로컬 쓰기 후 자동으로 동기화를 트리거한다.
final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  final base = SessionRepositoryImpl(ref.watch(databaseProvider));
  final syncService = ref.watch(syncServiceProvider);
  if (syncService != null) {
    return SyncAwareSessionRepository(base, syncService);
  }
  return base;
});

/// 위치 트리거 리포지토리 프로바이더.
///
/// 로그인 상태에서는 SyncAwareLocationTriggerRepository로 감싸서
/// 로컬 쓰기 후 자동으로 동기화를 트리거한다.
final locationTriggerRepositoryProvider = Provider<LocationTriggerRepository>((ref) {
  final base = LocationTriggerRepositoryImpl(ref.watch(databaseProvider));
  final syncService = ref.watch(syncServiceProvider);
  if (syncService != null) {
    return SyncAwareLocationTriggerRepository(base, syncService);
  }
  return base;
});

/// 활성 타이머 리포지토리 프로바이더.
final activeTimerRepositoryProvider = Provider<ActiveTimerRepository>((ref) {
  return ActiveTimerRepositoryImpl(ref.watch(databaseProvider));
});

/// 사용자 설정 리포지토리 프로바이더.
final userSettingsRepositoryProvider = Provider<UserSettingsRepository>((ref) {
  return UserSettingsRepositoryImpl(ref.watch(databaseProvider));
});

// ── 프리셋 맵 ────────────────────────────────────────────────

/// 프리셋 ID → Preset 매핑.
///
/// 여러 feature(history, stats 등)에서 세션의 프리셋 정보를
/// 조회할 때 공유한다. 프리셋이 변경되면 자동으로 맵이 갱신된다.
/// 보관된 프리셋도 포함하는 프리셋 맵.
/// 히스토리/통계에서 보관된 프리셋의 이름/아이콘을 표시해야 하므로
/// watchAllPresetsIncludingArchived()를 사용한다.
final presetMapProvider = StreamProvider<Map<String, Preset>>((ref) {
  return ref.watch(presetRepositoryProvider).watchAllPresetsIncludingArchived().map(
        (presets) => {for (final p in presets) p.id: p},
      );
});

// ── 설정 스트림 ───────────────────────────────────────────────

/// 사용자 설정을 실시간으로 관찰하는 스트림 프로바이더.
///
/// `StreamProvider`는 Stream을 구독하고, 새 값이 방출될 때마다
/// 이 프로바이더를 watch하는 위젯을 자동으로 리빌드한다.
/// `Provider`(동기)와 달리 로딩/에러/데이터 3가지 상태를 가진다.
///
/// 테마 변경 등 설정이 바뀌면 이 스트림을 통해 App 위젯이 즉시 리빌드된다.
final userSettingsStreamProvider = StreamProvider<UserSettings>((ref) {
  final repo = ref.watch(userSettingsRepositoryProvider);
  return repo.watchSettings();
});

// ── 앱 초기화 ─────────────────────────────────────────────────

/// 앱 시작 시 필요한 초기화 작업을 수행하는 프로바이더.
///
/// `FutureProvider`는 비동기 작업을 실행하고 결과를 캐싱한다.
/// StreamProvider처럼 로딩/에러/데이터 3가지 상태를 가진다.
/// 위젯에서 `ref.watch(appInitProvider)`하면 Future가 완료될 때까지
/// loading 상태였다가 완료 후 data 상태로 전환된다.
///
/// 현재는 기본 프리셋 시딩만 수행한다.
/// 향후 초기화 작업이 추가되면 이 프로바이더에 모은다.
final appInitProvider = FutureProvider<void>((ref) async {
  // ref.read: 값을 한 번만 읽고 의존 관계를 맺지 않는다.
  // 초기화는 한 번만 실행하면 되므로 watch 대신 read를 사용한다.
  final repo = ref.read(presetRepositoryProvider);
  final seeder = PresetSeeder(repo);
  await seeder.seedIfEmpty();
});
