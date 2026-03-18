import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taptime/core/database/app_database.dart';
import 'package:taptime/core/database/preset_seeder.dart';
import 'package:taptime/features/history/data/session_repository_impl.dart';
import 'package:taptime/features/preset/data/preset_repository_impl.dart';
import 'package:taptime/features/settings/data/user_settings_repository_impl.dart';
import 'package:taptime/features/timer/data/active_timer_repository_impl.dart';
import 'package:taptime/shared/models/user_settings.dart';
import 'package:taptime/shared/repositories/active_timer_repository.dart';
import 'package:taptime/shared/repositories/preset_repository.dart';
import 'package:taptime/shared/repositories/session_repository.dart';
import 'package:taptime/shared/repositories/user_settings_repository.dart';

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

// ── 리포지토리 ────────────────────────────────────────────────

/// 프리셋 리포지토리 프로바이더.
///
/// 인터페이스 타입(PresetRepository)으로 노출하여
/// UI 레이어가 구현체(PresetRepositoryImpl)에 의존하지 않게 한다.
/// 나중에 클라우드 구현으로 교체할 때 이 프로바이더만 수정하면 된다.
///
/// `ref.watch`는 다른 프로바이더의 값을 가져오면서 의존 관계를 등록한다.
/// databaseProvider의 값이 바뀌면 이 프로바이더도 자동으로 재생성된다.
/// `ref.read`는 값만 한 번 읽고 의존 관계를 등록하지 않는다.
final presetRepositoryProvider = Provider<PresetRepository>((ref) {
  return PresetRepositoryImpl(ref.watch(databaseProvider));
});

/// 세션 리포지토리 프로바이더.
final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  return SessionRepositoryImpl(ref.watch(databaseProvider));
});

/// 활성 타이머 리포지토리 프로바이더.
final activeTimerRepositoryProvider = Provider<ActiveTimerRepository>((ref) {
  return ActiveTimerRepositoryImpl(ref.watch(databaseProvider));
});

/// 사용자 설정 리포지토리 프로바이더.
final userSettingsRepositoryProvider = Provider<UserSettingsRepository>((ref) {
  return UserSettingsRepositoryImpl(ref.watch(databaseProvider));
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
