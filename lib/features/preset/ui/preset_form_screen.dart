import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 프리셋 생성/수정 화면.
///
/// presetId가 null이면 새 프리셋 생성, 값이 있으면 기존 프리셋 수정.
/// Phase 2에서 폼 필드(이름, 시간, 아이콘, 색상, 목표)를 구현할 예정.
class PresetFormScreen extends ConsumerWidget {
  const PresetFormScreen({super.key, this.presetId});

  final String? presetId;

  bool get isEditing => presetId != null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? '프리셋 수정' : '새 프리셋')),
      body: Center(child: Text(isEditing ? '프리셋 수정 폼 (id: $presetId)' : '새 프리셋 생성 폼')),
    );
  }
}
