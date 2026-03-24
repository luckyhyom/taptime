import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taptime/core/providers/app_providers.dart';
import 'package:taptime/core/router/app_router.dart';
import 'package:taptime/core/theme/app_theme.dart';
import 'package:taptime/features/location/data/geofence_manager.dart';

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

    if (action.autoStart) {
      appRouter.push(AppRoutes.timerPath(action.presetId));
    } else {
      _showConfirmDialog(action);
    }
  }

  Future<void> _showConfirmDialog(GeofenceAction action) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${action.placeName} 도착'),
        content: Text('${action.presetName} 타이머를 시작하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('나중에'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('시작'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      unawaited(appRouter.push(AppRoutes.timerPath(action.presetId)));
    }
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
