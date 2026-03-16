import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 설정 화면 — 테마, 알림, 데이터 초기화 등을 관리한다.
///
/// Phase 6에서 테마 토글, 사운드/진동 설정, 데이터 초기화 등을 구현할 예정.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: const Center(child: Text('설정이 여기에 표시됩니다')),
    );
  }
}
