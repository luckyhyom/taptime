import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taptime/core/router/app_router.dart';
import 'package:taptime/core/theme/app_colors.dart';
import 'package:taptime/core/theme/app_spacing.dart';
import 'package:taptime/features/home/ui/preset_providers.dart';
import 'package:taptime/features/home/ui/widgets/preset_card.dart';

/// 홈 화면 — 프리셋 그리드를 2열로 표시한다.
///
/// presetListProvider(StreamProvider)를 watch하여
/// 프리셋이 추가/수정/삭제되면 그리드가 자동으로 갱신된다.
/// FAB를 눌러 새 프리셋을 만들 수 있다.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presetsAsync = ref.watch(presetListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Taptime')),
      // AsyncValue의 when 패턴:
      // StreamProvider/FutureProvider는 loading/error/data 3가지 상태를 가진다.
      // when()으로 각 상태별 UI를 선언적으로 분기한다.
      body: presetsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('오류가 발생했습니다: $error')),
        data: (presets) {
          if (presets.isEmpty) {
            return const Center(
              child: Text('프리셋이 없습니다.\n+ 버튼을 눌러 추가하세요.', textAlign: TextAlign.center),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(AppSpacing.padding),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppSpacing.gap,
              mainAxisSpacing: AppSpacing.gap,
              // 카드의 가로:세로 비율. 1.0이면 정사각형.
              // 진행률 바 포함 시 세로가 더 길어야 하므로 0.85로 설정.
              childAspectRatio: 0.85,
            ),
            itemCount: presets.length,
            itemBuilder: (context, index) {
              final preset = presets[index];
              return PresetCard(
                preset: preset,
                onTap: () => context.push(AppRoutes.timerPath(preset.id)),
                onLongPress: () => context.push(AppRoutes.presetEditPath(preset.id)),
              );
            },
          );
        },
      ),
      // FloatingActionButton — 화면 우하단의 둥근 버튼.
      // 새 프리셋 생성 화면으로 이동한다.
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.coral,
        foregroundColor: Colors.white,
        onPressed: () => context.push(AppRoutes.presetNew),
        child: const Icon(Icons.add),
      ),
    );
  }
}
