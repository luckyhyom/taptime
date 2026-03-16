import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 홈 화면 — 프리셋 그리드를 표시한다.
///
/// ConsumerWidget은 Riverpod의 위젯으로,
/// 일반 StatelessWidget에 ref(프로바이더 접근)를 추가한 것이다.
/// Phase 2에서 프리셋 그리드와 FAB를 구현할 예정.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Taptime')),
      body: const Center(child: Text('Home — 프리셋 그리드가 여기에 표시됩니다')),
    );
  }
}
