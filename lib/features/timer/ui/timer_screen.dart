import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 타이머 화면 — 카운트다운과 컨트롤을 표시한다.
///
/// presetId를 받아 해당 프리셋의 설정(시간, 이름, 아이콘)으로 타이머를 실행한다.
/// Phase 3에서 카운트다운 로직, 프로그레스 링, 컨트롤 버튼을 구현할 예정.
class TimerScreen extends ConsumerWidget {
  const TimerScreen({super.key, required this.presetId});

  final String presetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('타이머')),
      body: Center(child: Text('타이머 화면 (presetId: $presetId)')),
    );
  }
}
