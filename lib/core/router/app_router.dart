import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:taptime/core/router/shell_screen.dart';
import 'package:taptime/features/history/ui/history_screen.dart';
import 'package:taptime/features/home/ui/home_screen.dart';
import 'package:taptime/features/preset/ui/preset_form_screen.dart';
import 'package:taptime/features/settings/ui/settings_screen.dart';
import 'package:taptime/features/stats/ui/stats_screen.dart';
import 'package:taptime/features/timer/ui/timer_screen.dart';

/// 라우트 경로 상수.
///
/// 라우트 경로를 문자열로 직접 쓰면 오타 시 런타임에서야 발견된다.
/// 상수로 관리하면 컴파일 타임에 잡을 수 있고, 변경 시 한 곳만 수정하면 된다.
///
/// `:presetId`는 GoRouter의 경로 파라미터 문법이다.
/// REST API의 `/users/:id`와 동일한 개념으로,
/// 실제 네비게이션 시 `context.push('/timer/abc-123')`처럼 값이 치환된다.
abstract final class AppRoutes {
  static const home = '/home';
  static const stats = '/stats';
  static const settings = '/settings';
  static const history = '/history';
  static const timer = '/timer/:presetId';
  static const presetNew = '/preset/new';
  static const presetEdit = '/preset/edit/:presetId';

  /// 타이머 라우트에 presetId를 삽입한다.
  /// 사용 예: `context.push(AppRoutes.timerPath('abc-123'))`
  static String timerPath(String presetId) => '/timer/$presetId';

  /// 프리셋 수정 라우트에 presetId를 삽입한다.
  static String presetEditPath(String presetId) => '/preset/edit/$presetId';
}

// ── Navigator 키 ──────────────────────────────────────────────

/// 앱 전체를 감싸는 루트 네비게이터 키.
///
/// GoRouter에서 네비게이터 키는 "어떤 네비게이션 스택에 화면을 push할지"를 결정한다.
/// 루트 키에 push하면 하단 바 위에 풀스크린으로 열리고,
/// 탭 키에 push하면 하단 바가 유지된 채 탭 내부에서 열린다.
final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

/// 각 탭의 네비게이터 키.
///
/// 탭마다 고유 키를 부여하면 탭별 독립적인 네비게이션 스택이 만들어진다.
/// 홈 탭에서 상세 화면으로 이동해도 통계 탭의 상태는 그대로 유지된다.
final _homeNavKey = GlobalKey<NavigatorState>(debugLabel: 'home');
final _statsNavKey = GlobalKey<NavigatorState>(debugLabel: 'stats');
final _settingsNavKey = GlobalKey<NavigatorState>(debugLabel: 'settings');

// ── Router ────────────────────────────────────────────────────

/// 앱의 GoRouter 인스턴스.
///
/// StatefulShellRoute.indexedStack를 사용하여 탭 네비게이션을 구현한다.
/// indexedStack은 IndexedStack 위젯으로 각 탭의 상태를 보존한다.
/// 탭을 전환해도 이전 탭의 스크롤 위치, 입력 상태 등이 유지된다.
///
/// parentNavigatorKey가 _rootNavigatorKey인 라우트는
/// 셸(하단 네비게이션) 위에 풀스크린으로 표시된다.
final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: AppRoutes.home,
  routes: [
    // ── 탭 네비게이션 (하단 바 유지) ─────────────────────────
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ShellScreen(
          navigationShell: navigationShell,
          currentIndex: navigationShell.currentIndex,
          onDestinationSelected: (index) {
            // 현재 탭을 다시 누르면 해당 탭의 첫 화면으로 돌아간다.
            // 다른 탭을 누르면 마지막으로 보던 화면을 유지한다.
            navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            );
          },
        );
      },
      branches: [
        StatefulShellBranch(
          navigatorKey: _homeNavKey,
          routes: [
            GoRoute(
              path: AppRoutes.home,
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _statsNavKey,
          routes: [
            GoRoute(
              path: AppRoutes.stats,
              builder: (context, state) => const StatsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _settingsNavKey,
          routes: [
            GoRoute(
              path: AppRoutes.settings,
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    ),

    // ── 풀스크린 라우트 (하단 바 숨김) ───────────────────────

    GoRoute(
      path: AppRoutes.timer,
      /// 루트 키를 지정하면 셸 바깥(하단 바 위)에 풀스크린으로 표시된다.
      /// 생략하면 가장 가까운 셸 내부에서 열려 하단 바가 유지된다.
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        /// URL의 `:presetId` 부분을 추출한다.
        /// `!`는 null이 아님을 단언 — 이 라우트는 항상 presetId가 있어야 한다.
        final presetId = state.pathParameters['presetId']!;
        return TimerScreen(presetId: presetId);
      },
    ),
    GoRoute(
      path: AppRoutes.presetNew,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const PresetFormScreen(),
    ),
    GoRoute(
      path: AppRoutes.presetEdit,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final presetId = state.pathParameters['presetId']!;
        return PresetFormScreen(presetId: presetId);
      },
    ),
    GoRoute(
      path: AppRoutes.history,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const HistoryScreen(),
    ),
  ],
);
