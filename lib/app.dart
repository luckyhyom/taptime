import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'package:taptime/core/providers/app_providers.dart';
import 'package:taptime/core/router/app_router.dart';
import 'package:taptime/core/theme/app_theme.dart';
import 'package:taptime/features/location/data/geofence_manager.dart';
import 'package:taptime/shared/models/session.dart';

/// 앱의 루트 위젯.
///
/// ConsumerWidget을 사용하여 사용자 설정(테마 모드)을
/// 실시간으로 반영한다.
/// MaterialApp.router와 GoRouter를 연결하여 선언적 라우팅을 구성한다.
class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 앱 초기화 (기본 프리셋 시딩) 트리거
    ref.watch(appInitProvider);

    // 사용자 설정에서 테마 모드를 가져온다.
    // 로딩 중이거나 에러 시 system 모드를 기본값으로 사용한다.
    final themeMode = ref.watch(userSettingsStreamProvider).whenData((s) => s.themeMode).valueOrNull ??
        ThemeMode.system;

    return MaterialApp.router(
      title: 'Taptime',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      // GeofenceManager 이벤트를 받아 다이얼로그/네비게이션을 처리한다.
      builder: (context, child) => _GeofenceEventHandler(child: child ?? const SizedBox()),
    );
  }
}

// ── 지오펜스 이벤트 핸들러 ──────────────────────────────────────

/// GeofenceManager의 진입 이벤트를 수신하여 UI로 변환한다.
///
/// - autoStart=true → 타이머 화면으로 즉시 이동
/// - autoStart=false → 확인 다이얼로그 표시 후 이동
///
/// MaterialApp.builder 안에 위치하여 theme, overlay, navigation에 접근 가능하다.
class _GeofenceEventHandler extends ConsumerStatefulWidget {
  const _GeofenceEventHandler({required this.child});

  final Widget child;

  @override
  ConsumerState<_GeofenceEventHandler> createState() => _GeofenceEventHandlerState();
}

class _GeofenceEventHandlerState extends ConsumerState<_GeofenceEventHandler> {
  StreamSubscription<GeofenceAction>? _sub;

  @override
  void initState() {
    super.initState();
    // 첫 프레임 이후 현재 매니저에 구독
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _subscribe(ref.read(geofenceManagerProvider));
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void _subscribe(GeofenceManager? manager) {
    _sub?.cancel();
    _sub = manager?.actions.listen(_handleAction);
  }

  void _handleAction(GeofenceAction action) {
    if (!mounted) return;

    switch (action.type) {
      case GeofenceActionType.start:
        // 위치 진입 → 이미 같은 프리셋 타이머가 실행 중이면 중복 방지
        _autoStartIfNeeded(action);
      case GeofenceActionType.stop:
        // 위치 퇴장 → 실행 중인 타이머가 해당 프리셋이면 자동 정지
        _autoStopIfRunning(action);
    }
  }

  /// 해당 프리셋의 타이머가 이미 실행 중이 아닐 때만 타이머 화면으로 이동한다.
  /// 같은 프리셋의 타이머가 이미 실행 중이면 중복 push를 방지한다.
  /// 실제로 타이머 화면으로 이동한 경우에만 알림을 표시한다.
  Future<void> _autoStartIfNeeded(GeofenceAction action) async {
    final timer = await ref.read(activeTimerRepositoryProvider).getActiveTimer();
    if (!mounted) return;
    // 이미 같은 프리셋의 타이머가 실행 중이면 스킵 (알림도 표시하지 않음)
    if (timer != null && timer.presetId == action.presetId) return;

    unawaited(appRouter.push(AppRoutes.timerPath(action.presetId)));

    // 실제로 타이머 화면으로 이동했으므로 알림 표시
    unawaited(_showGeofenceNotification(
      regionId: action.presetId,
      body: '${action.presetName} 타이머가 시작되었습니다 (${action.placeName})',
    ));
  }

  /// 현재 실행 중인 타이머가 해당 프리셋이면 세션을 저장하고 정지한다.
  /// TimerNotifier를 거치지 않고 직접 DB를 조작하여
  /// 타이머 화면이 열려있지 않아도 안전하게 동작한다.
  /// 실제로 타이머가 정지된 경우에만 알림을 표시한다.
  Future<void> _autoStopIfRunning(GeofenceAction action) async {
    final activeTimerRepo = ref.read(activeTimerRepositoryProvider);
    final activeTimer = await activeTimerRepo.getActiveTimer();

    // 실행 중인 타이머가 없거나 다른 프리셋이면 스킵 (알림도 표시하지 않음)
    if (activeTimer == null || activeTimer.presetId != action.presetId) return;

    final preset = await ref.read(presetRepositoryProvider).getPresetById(action.presetId);
    if (preset == null) return;

    // 경과 시간 계산 (타임스탬프 기반)
    final now = DateTime.now();
    var totalPaused = activeTimer.pausedDurationSeconds;
    if (activeTimer.pausedAt != null) {
      totalPaused += now.difference(activeTimer.pausedAt!).inSeconds;
    }
    final elapsed = now.difference(activeTimer.startedAt).inSeconds - totalPaused;
    final totalSec = preset.durationMin * 60;
    final clamped = totalSec > 0 ? elapsed.clamp(0, totalSec) : elapsed.clamp(0, elapsed.abs());

    // 세션 저장
    await ref.read(sessionRepositoryProvider).createSession(
      Session(
        id: const Uuid().v4(),
        presetId: action.presetId,
        startedAt: activeTimer.startedAt,
        endedAt: now,
        durationSeconds: clamped,
        status: SessionStatus.stopped,
        createdAt: now,
      ),
    );

    // ActiveTimer 삭제
    await activeTimerRepo.deleteActiveTimer();

    // 실제로 타이머가 정지되었으므로 알림 표시
    unawaited(_showGeofenceNotification(
      regionId: action.presetId,
      body: '${action.presetName} 타이머가 종료되었습니다 (${action.placeName})',
    ));

    if (!mounted) return;

    // 타이머 화면이 열려있을 수 있으므로 홈으로 이동
    appRouter.go(AppRoutes.home);
  }

  /// 지오펜스 알림을 네이티브를 통해 표시한다.
  Future<void> _showGeofenceNotification({
    required String regionId,
    required String body,
  }) {
    return ref.read(geofenceServiceProvider).showNotification(
      regionId: regionId,
      title: 'Taptime',
      body: body,
    );
  }

  @override
  Widget build(BuildContext context) {
    // 매니저가 변경되면 (설정 토글 등) 스트림을 재구독한다
    ref.listen<GeofenceManager?>(geofenceManagerProvider, (prev, next) {
      _subscribe(next);
    });

    return widget.child;
  }
}
