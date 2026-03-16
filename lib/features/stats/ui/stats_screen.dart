import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 통계 화면 — 오늘/주간 통계를 표시한다.
///
/// Phase 5에서 차트, 목표 진행률, 날짜 네비게이션 등을 구현할 예정.
class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('통계')),
      body: const Center(child: Text('통계가 여기에 표시됩니다')),
    );
  }
}
