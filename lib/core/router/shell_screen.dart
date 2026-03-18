import 'package:flutter/material.dart';

/// 하단 네비게이션 바가 있는 셸 화면.
///
/// GoRouter의 StatefulShellRoute와 함께 사용하여
/// 탭 네비게이션을 구현한다.
/// 탭 전환 시 각 탭의 상태(스크롤 위치 등)가 유지된다.
///
/// [navigationShell]은 GoRouter가 주입하는 현재 탭의 화면 위젯이다.
/// [onDestinationSelected]로 탭을 전환하면 GoRouter가
/// 해당 탭의 라우트로 네비게이션한다.
class ShellScreen extends StatelessWidget {
  const ShellScreen({
    super.key,
    required this.navigationShell,
    required this.currentIndex,
    required this.onDestinationSelected,
  });

  /// GoRouter가 주입하는 현재 탭의 화면
  final Widget navigationShell;

  /// 현재 선택된 탭 인덱스
  final int currentIndex;

  /// 탭 전환 콜백
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: onDestinationSelected,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: '홈'),
          NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart), label: '통계'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: '설정'),
        ],
      ),
    );
  }
}
