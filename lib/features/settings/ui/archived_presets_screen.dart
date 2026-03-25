import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taptime/core/constants/app_constants.dart';
import 'package:taptime/core/providers/app_providers.dart';
import 'package:taptime/core/theme/app_colors.dart';
import 'package:taptime/core/theme/app_spacing.dart';
import 'package:taptime/core/utils/color_utils.dart';
import 'package:taptime/shared/models/preset.dart';

/// 보관된 프리셋 목록 화면.
///
/// 설정에서 진입하며, 보관된 프리셋을 복원하거나 완전 삭제할 수 있다.
class ArchivedPresetsScreen extends ConsumerStatefulWidget {
  const ArchivedPresetsScreen({super.key});

  @override
  ConsumerState<ArchivedPresetsScreen> createState() => _ArchivedPresetsScreenState();
}

class _ArchivedPresetsScreenState extends ConsumerState<ArchivedPresetsScreen> {
  List<Preset> _archivedPresets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadArchivedPresets();
  }

  Future<void> _loadArchivedPresets() async {
    final presets = await ref.read(presetRepositoryProvider).getArchivedPresets();
    if (mounted) {
      setState(() {
        _archivedPresets = presets;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('보관된 프리셋')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _archivedPresets.isEmpty
              ? const Center(child: Text('보관된 프리셋이 없습니다.'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.gap),
                  itemCount: _archivedPresets.length,
                  itemBuilder: (context, index) {
                    final preset = _archivedPresets[index];
                    return _ArchivedPresetTile(
                      preset: preset,
                      onUnarchive: () => _unarchive(preset),
                      onDelete: () => _confirmDelete(preset),
                    );
                  },
                ),
    );
  }

  Future<void> _unarchive(Preset preset) async {
    await ref.read(presetRepositoryProvider).unarchivePreset(preset.id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${preset.name}이(가) 복원되었습니다.')),
      );
      _loadArchivedPresets();
    }
  }

  Future<void> _confirmDelete(Preset preset) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('프리셋 삭제'),
        content: Text('${preset.name}을(를) 완전히 삭제하시겠습니까?\n관련된 세션 기록도 함께 삭제됩니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await ref.read(presetRepositoryProvider).deletePreset(preset.id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${preset.name}이(가) 삭제되었습니다.')),
      );
      _loadArchivedPresets();
    }
  }
}

// ── 보관된 프리셋 타일 ───────────────────────────────────────────

class _ArchivedPresetTile extends StatelessWidget {
  const _ArchivedPresetTile({
    required this.preset,
    required this.onUnarchive,
    required this.onDelete,
  });

  final Preset preset;
  final VoidCallback onUnarchive;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final color = ColorUtils.fromHex(preset.color);
    final icon = AppConstants.presetIcons[preset.icon] ?? Icons.timer;
    final archivedDate = preset.archivedAt;
    final dateText = archivedDate != null ? '${archivedDate.month}월 ${archivedDate.day}일 보관' : '';

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppSpacing.grid),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(preset.name),
      subtitle: Text(dateText),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.unarchive_outlined),
            tooltip: '복원',
            onPressed: onUnarchive,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.coral),
            tooltip: '삭제',
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
