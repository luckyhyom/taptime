import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taptime/core/providers/app_providers.dart';
import 'package:taptime/core/router/app_router.dart';
import 'package:taptime/core/theme/app_theme.dart';

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
    );
  }
}
