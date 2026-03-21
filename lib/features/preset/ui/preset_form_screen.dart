import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taptime/core/constants/app_constants.dart';
import 'package:taptime/core/theme/app_colors.dart';
import 'package:taptime/core/theme/app_spacing.dart';
import 'package:taptime/core/utils/color_utils.dart';
import 'package:taptime/features/preset/ui/preset_form_notifier.dart';

/// 프리셋 생성/수정 화면.
///
/// presetId가 null이면 새 프리셋 생성, 값이 있으면 기존 프리셋 수정.
/// 폼 상태는 PresetFormNotifier가 관리하며, 화면을 벗어나면 자동 해제된다.
class PresetFormScreen extends ConsumerStatefulWidget {
  const PresetFormScreen({super.key, this.presetId});

  final String? presetId;

  bool get isEditing => presetId != null;

  @override
  ConsumerState<PresetFormScreen> createState() => _PresetFormScreenState();
}

class _PresetFormScreenState extends ConsumerState<PresetFormScreen> {
  // 이름 필드는 TextEditingController로 관리한다.
  // 수정 모드에서 DB 로딩 완료 후 controller.text를 동기화해야 하므로 필요하다.
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = presetFormProvider(widget.presetId);
    final state = ref.watch(provider);
    final notifier = ref.read(provider.notifier);

    // 상태 변화 감지: 프리셋 로딩 완료 시 이름 컨트롤러 동기화 + 오류 스낵바
    ref.listen<PresetFormState>(provider, (prev, next) {
      // 로딩 완료 시점에 컨트롤러 텍스트를 DB에서 불러온 이름으로 갱신한다.
      if ((prev?.isLoading ?? false) && !next.isLoading) {
        _nameController.text = next.name;
        _nameController.selection = TextSelection.collapsed(offset: next.name.length);
      }

      // 저장/삭제 오류가 새로 생기면 스낵바로 알린다.
      if (next.error != null && next.error != prev?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    if (state.isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.isEditing ? '프리셋 수정' : '새 프리셋')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? '프리셋 수정' : '새 프리셋'),
        actions: [
          TextButton(
            onPressed: state.isSubmitting || !state.isValid ? null : () => _save(notifier),
            child: state.isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('저장'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 이름 ──────────────────────────────────────────
            const _SectionLabel('이름'),
            const SizedBox(height: AppSpacing.gap),
            TextField(
              controller: _nameController,
              maxLength: AppConstants.presetNameMaxLength,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: '활동 이름 (예: 공부, 운동)',
                border: OutlineInputBorder(),
              ),
              onChanged: notifier.setName,
            ),

            const SizedBox(height: AppSpacing.sectionGap),

            // ── 타이머 시간 ───────────────────────────────────
            const _SectionLabel('타이머 시간'),
            const SizedBox(height: AppSpacing.gap),
            _StepperRow(
              value: state.durationMin,
              unit: '분',
              min: AppConstants.timerMinMinutes,
              max: AppConstants.timerMaxMinutes,
              step: 5,
              zeroLabel: '무제한',
              onChanged: notifier.setDuration,
            ),

            const SizedBox(height: AppSpacing.sectionGap),

            // ── 아이콘 ────────────────────────────────────────
            const _SectionLabel('아이콘'),
            const SizedBox(height: AppSpacing.gap),
            _IconPicker(
              selected: state.icon,
              accentColor: ColorUtils.fromHex(state.color),
              onSelected: notifier.setIcon,
            ),

            const SizedBox(height: AppSpacing.sectionGap),

            // ── 색상 ──────────────────────────────────────────
            const _SectionLabel('색상'),
            const SizedBox(height: AppSpacing.gap),
            _ColorPicker(
              selected: state.color,
              onSelected: notifier.setColor,
            ),

            const SizedBox(height: AppSpacing.sectionGap),

            // ── 일일 목표 ─────────────────────────────────────
            const _SectionLabel('일일 목표'),
            const SizedBox(height: 4),
            Text(
              '오늘 이 활동에 얼마나 시간을 쓸지 설정합니다.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: AppSpacing.gap),
            _DailyGoalStepper(
              value: state.dailyGoalMin,
              onChanged: notifier.setDailyGoal,
            ),

            // ── 삭제 버튼 (수정 모드) ─────────────────────────
            if (widget.isEditing) ...[
              const SizedBox(height: AppSpacing.sectionGap * 2),
              _DeleteButton(
                isSubmitting: state.isSubmitting,
                onDelete: () => _confirmDelete(notifier),
              ),
            ],

            const SizedBox(height: AppSpacing.sectionGap),
          ],
        ),
      ),
    );
  }

  Future<void> _save(PresetFormNotifier notifier) async {
    final success = await notifier.save();
    if (success && mounted) context.pop();
  }

  Future<void> _confirmDelete(PresetFormNotifier notifier) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('프리셋 삭제'),
        content: const Text('이 프리셋을 삭제하시겠습니까?\n관련된 세션 기록도 함께 삭제됩니다.'),
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

    final success = await notifier.delete();
    if (success && mounted) context.pop();
  }
}

// ── 서브 위젯 ─────────────────────────────────────────────────

/// 폼 섹션 라벨.
class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
    );
  }
}

/// + / - 버튼으로 정수값을 조절하는 스테퍼.
class _StepperRow extends StatelessWidget {
  const _StepperRow({
    required this.value,
    required this.unit,
    required this.min,
    required this.max,
    required this.step,
    required this.onChanged,
    this.zeroLabel,
  });

  final int value;
  final String unit;
  final int min;
  final int max;
  final int step;
  final ValueChanged<int> onChanged;

  /// value가 0일 때 표시할 텍스트 (null이면 '0 $unit')
  final String? zeroLabel;

  @override
  Widget build(BuildContext context) {
    final displayText = value == 0 && zeroLabel != null ? zeroLabel! : '$value $unit';

    return Row(
      children: [
        IconButton.outlined(
          icon: const Icon(Icons.remove),
          onPressed: value <= min ? null : () => onChanged((value - step).clamp(min, max)),
        ),
        const SizedBox(width: AppSpacing.gap),
        SizedBox(
          width: 80,
          child: Text(
            displayText,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(width: AppSpacing.gap),
        IconButton.outlined(
          icon: const Icon(Icons.add),
          onPressed: value >= max ? null : () => onChanged((value + step).clamp(min, max)),
        ),
      ],
    );
  }
}

/// 아이콘 목록에서 하나를 선택하는 피커.
class _IconPicker extends StatelessWidget {
  const _IconPicker({
    required this.selected,
    required this.accentColor,
    required this.onSelected,
  });

  final String selected;
  final Color accentColor;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.gap,
      runSpacing: AppSpacing.gap,
      children: AppConstants.presetIcons.entries.map((entry) {
        final isSelected = selected == entry.key;

        return GestureDetector(
          onTap: () => onSelected(entry.key),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: isSelected ? accentColor.withValues(alpha: 0.15) : Colors.transparent,
              border: Border.all(
                color: isSelected ? accentColor : Theme.of(context).colorScheme.outline,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            ),
            child: Icon(
              entry.value,
              color: isSelected ? accentColor : Theme.of(context).colorScheme.onSurfaceVariant,
              size: 26,
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// 색상 팔레트에서 하나를 선택하는 피커.
class _ColorPicker extends StatelessWidget {
  const _ColorPicker({
    required this.selected,
    required this.onSelected,
  });

  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.gap,
      runSpacing: AppSpacing.gap,
      children: AppConstants.presetColorHexes.map((hex) {
        final color = ColorUtils.fromHex(hex);
        final isSelected = selected == hex;

        return GestureDetector(
          onTap: () => onSelected(hex),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                // 선택된 색상은 흰색 테두리 + 그림자로 강조한다.
                color: isSelected ? Colors.white : Colors.transparent,
                width: 2.5,
              ),
              boxShadow: isSelected
                  ? [BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 8, spreadRadius: 1)]
                  : null,
            ),
            child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
          ),
        );
      }).toList(),
    );
  }
}

/// 일일 목표 시간을 5분 단위로 조절하는 스테퍼.
///
/// 0은 "목표 없음"을 의미하며, 별도 텍스트로 표시한다.
class _DailyGoalStepper extends StatelessWidget {
  const _DailyGoalStepper({
    required this.value,
    required this.onChanged,
  });

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton.outlined(
          icon: const Icon(Icons.remove),
          onPressed: value <= 0 ? null : () => onChanged((value - 5).clamp(0, 480)),
        ),
        const SizedBox(width: AppSpacing.gap),
        SizedBox(
          width: 80,
          child: Text(
            value == 0 ? '없음' : '$value분',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: value == 0 ? Theme.of(context).colorScheme.onSurfaceVariant : null,
                ),
          ),
        ),
        const SizedBox(width: AppSpacing.gap),
        IconButton.outlined(
          icon: const Icon(Icons.add),
          onPressed: value >= 480 ? null : () => onChanged((value + 5).clamp(0, 480)),
        ),
        if (value > 0) ...[
          const SizedBox(width: AppSpacing.gap),
          TextButton(
            onPressed: () => onChanged(0),
            child: const Text('없음으로'),
          ),
        ],
      ],
    );
  }
}

/// 프리셋 삭제 버튼 (수정 모드에서만 표시).
class _DeleteButton extends StatelessWidget {
  const _DeleteButton({
    required this.isSubmitting,
    required this.onDelete,
  });

  final bool isSubmitting;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: isSubmitting ? null : onDelete,
        icon: const Icon(Icons.delete_outline, color: AppColors.coral),
        label: const Text('프리셋 삭제', style: TextStyle(color: AppColors.coral)),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.coral),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}
