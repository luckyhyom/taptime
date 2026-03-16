import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 세션 기록 화면 — 날짜별 타이머 기록을 표시한다.
///
/// Phase 4에서 날짜별 그룹핑, 세션 목록, 메모 편집 등을 구현할 예정.
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('기록')),
      body: const Center(child: Text('세션 기록이 여기에 표시됩니다')),
    );
  }
}
