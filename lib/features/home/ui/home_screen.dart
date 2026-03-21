import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taptime/core/constants/app_constants.dart';
import 'package:taptime/core/providers/app_providers.dart';
import 'package:taptime/core/router/app_router.dart';
import 'package:taptime/core/theme/app_colors.dart';
import 'package:taptime/core/theme/app_spacing.dart';
import 'package:taptime/core/utils/color_utils.dart';
import 'package:taptime/features/home/ui/preset_providers.dart';
import 'package:taptime/features/home/ui/widgets/preset_card.dart';
import 'package:taptime/shared/models/preset.dart';

/// 홈 화면.
///
/// 기본 모드: 프리셋을 2열 그리드로 표시한다.
/// 편집 모드: ReorderableListView로 전환하여 드래그 앤 드롭 순서 변경을 지원한다.
///
/// StatefulWidget을 사용하는 이유: _isReordering 로컬 상태가 필요하기 때문.
/// Riverpod 상태(presetList)는 ref.watch로 별도 관리한다.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _isReordering = false;

  @override
  Widget build(BuildContext context) {
    final presetsAsync = ref.watch(presetListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Taptime'),
        actions: [
          // 히스토리 화면 진입 버튼
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: '기록',
            onPressed: () => context.push(AppRoutes.history),
          ),
          // 편집/완료 버튼: 프리셋이 2개 이상일 때만 표시한다.
          // 1개 이하면 순서 변경의 의미가 없으므로 숨긴다.
          presetsAsync.maybeWhen(
            data: (presets) => presets.length > 1
                ? TextButton(
                    onPressed: () => setState(() => _isReordering = !_isReordering),
                    child: Text(_isReordering ? '완료' : '편집'),
                  )
                : const SizedBox.shrink(),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: presetsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('오류가 발생했습니다: $error')),
        data: (presets) {
          if (presets.isEmpty) {
            return const Center(
              child: Text(
                '프리셋이 없습니다.\n+ 버튼을 눌러 추가하세요.',
                textAlign: TextAlign.center,
              ),
            );
          }

          // 편집 모드: 드래그 앤 드롭 리스트
          if (_isReordering) {
            return _buildReorderList(presets);
          }

          // 기본 모드: 2열 그리드
          return _buildGrid(presets);
        },
      ),
      // 편집 모드에서는 FAB를 숨긴다.
      floatingActionButton: _isReordering
          ? null
          : FloatingActionButton(
              backgroundColor: AppColors.coral,
              foregroundColor: Colors.white,
              tooltip: '새 프리셋',
              onPressed: () => context.push(AppRoutes.presetNew),
              child: const Icon(Icons.add),
            ),
    );
  }

  Widget _buildGrid(List<Preset> presets) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.padding),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.gap,
        mainAxisSpacing: AppSpacing.gap,
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
  }

  Widget _buildReorderList(List<Preset> presets) {
    return ReorderableListView.builder(
      padding: const EdgeInsets.all(AppSpacing.padding),
      itemCount: presets.length,
      // 드래그 후 onReorder가 호출되면 DB에 새 순서를 저장한다.
      onReorder: (oldIndex, newIndex) => _saveReorder(presets, oldIndex, newIndex),
      itemBuilder: (context, index) {
        final preset = presets[index];
        return _PresetReorderTile(
          key: ValueKey(preset.id),
          preset: preset,
        );
      },
    );
  }

  Future<void> _saveReorder(List<Preset> presets, int oldIndex, int newIndex) async {
    // Flutter의 ReorderableListView는 newIndex를 아이템 제거 전 기준으로 계산한다.
    // 아래로 이동할 때 1을 빼야 실제 삽입 위치가 된다.
    final adjustedIndex = oldIndex < newIndex ? newIndex - 1 : newIndex;

    final mutable = List<Preset>.from(presets);
    final moved = mutable.removeAt(oldIndex);
    mutable.insert(adjustedIndex, moved);

    // 새 배열 인덱스를 sortOrder로 사용한다.
    final idToSortOrder = {
      for (var i = 0; i < mutable.length; i++) mutable[i].id: i,
    };

    await ref.read(presetRepositoryProvider).updateSortOrder(idToSortOrder);
  }
}

// ── 편집 모드 리스트 타일 ─────────────────────────────────────

/// 편집(순서 변경) 모드에서 표시되는 가로형 프리셋 타일.
///
/// 그리드의 카드 대신 리스트 형태로 표시하여
/// 드래그 앤 드롭 인터랙션을 직관적으로 만든다.
class _PresetReorderTile extends StatelessWidget {
  const _PresetReorderTile({required this.preset, super.key});

  final Preset preset;

  @override
  Widget build(BuildContext context) {
    final color = ColorUtils.fromHex(preset.color);
    final icon = AppConstants.presetIcons[preset.icon] ?? Icons.timer;

    return Card(
      // ReorderableListView 내에서 각 아이템은 고유 Key를 가져야 한다.
      // key는 상위에서 ValueKey(preset.id)로 전달된다.
      margin: const EdgeInsets.only(bottom: AppSpacing.gap),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.padding,
          vertical: AppSpacing.gap / 2,
        ),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(preset.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('${preset.durationMin}분'),
        // 드래그 핸들 아이콘: 사용자가 이 아이콘을 잡고 드래그한다.
        // ReorderableListView의 기본 핸들과 동일하게 동작한다.
        trailing: Icon(
          Icons.drag_handle,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
