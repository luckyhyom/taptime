import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taptime/core/constants/app_constants.dart';
import 'package:taptime/core/providers/app_providers.dart';
import 'package:taptime/core/theme/app_spacing.dart';
import 'package:taptime/core/utils/color_utils.dart';
import 'package:taptime/features/history/ui/manual_session_form_notifier.dart';
import 'package:taptime/shared/models/preset.dart';

/// 수동 세션 입력 화면.
///
/// 타이머를 사용하지 않고 과거 활동을 직접 기록한다.
/// PresetFormScreen과 동일한 패턴을 따른다.
class ManualSessionFormScreen extends ConsumerStatefulWidget {
  const ManualSessionFormScreen({super.key});

  @override
  ConsumerState<ManualSessionFormScreen> createState() => _ManualSessionFormScreenState();
}

class _ManualSessionFormScreenState extends ConsumerState<ManualSessionFormScreen> {
  late final TextEditingController _memoController;

  @override
  void initState() {
    super.initState();
    _memoController = TextEditingController();
  }

  @override
  void dispose() {
    _memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(manualSessionFormProvider);
    final notifier = ref.read(manualSessionFormProvider.notifier);

    // 에러 발생 시 스낵바 표시
    ref.listen<ManualSessionFormState>(manualSessionFormProvider, (prev, next) {
      if (next.error != null && next.error != prev?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!), backgroundColor: Colors.red),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('세션 기록'),
        actions: [
          TextButton(
            onPressed: state.isSubmitting || !state.isValid ? null : () => _save(notifier),
            child: state.isSubmitting
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('저장'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 프리셋 선택 ──────────────────────────────────────
            _SectionLabel('프리셋'),
            const SizedBox(height: AppSpacing.grid),
            _PresetSelector(
              selectedPreset: state.selectedPreset,
              onTap: () => _showPresetPicker(context, notifier),
            ),

            const SizedBox(height: AppSpacing.sectionGap),

            // ── 날짜 ────────────────────────────────────────────
            _SectionLabel('날짜'),
            const SizedBox(height: AppSpacing.grid),
            _DateSelector(
              date: state.date,
              onTap: () => _pickDate(context, notifier, state),
            ),

            const SizedBox(height: AppSpacing.sectionGap),

            // ── 시간 ────────────────────────────────────────────
            _SectionLabel('시간'),
            const SizedBox(height: AppSpacing.grid),
            Row(
              children: [
                Expanded(
                  child: _TimeSelector(
                    label: '시작',
                    time: state.startTime,
                    onTap: () => _pickTime(context, notifier, isStart: true, current: state.startTime),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.grid),
                  child: Icon(Icons.arrow_forward, size: 20),
                ),
                Expanded(
                  child: _TimeSelector(
                    label: '종료',
                    time: state.endTime,
                    onTap: () => _pickTime(context, notifier, isStart: false, current: state.endTime),
                  ),
                ),
              ],
            ),

            // 소요 시간 표시
            if (state.durationSeconds != null) ...[
              const SizedBox(height: AppSpacing.gap),
              _DurationDisplay(durationSeconds: state.durationSeconds!),
            ],

            const SizedBox(height: AppSpacing.sectionGap),

            // ── 메모 ────────────────────────────────────────────
            _SectionLabel('메모 (선택)'),
            const SizedBox(height: AppSpacing.grid),
            TextField(
              controller: _memoController,
              maxLines: 3,
              maxLength: AppConstants.sessionMemoMaxLength,
              decoration: const InputDecoration(
                hintText: '활동에 대한 메모를 남겨보세요',
                border: OutlineInputBorder(),
              ),
              onChanged: notifier.setMemo,
            ),
          ],
        ),
      ),
    );
  }

  // ── 액션 ───────────────────────────────────────────────────

  Future<void> _save(ManualSessionFormNotifier notifier) async {
    final success = await notifier.save();
    if (success && mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _pickDate(BuildContext context, ManualSessionFormNotifier notifier, ManualSessionFormState state) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: state.date ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      notifier.setDate(picked);
    }
  }

  Future<void> _pickTime(
    BuildContext context,
    ManualSessionFormNotifier notifier, {
    required bool isStart,
    TimeOfDay? current,
  }) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: current ?? TimeOfDay.now(),
    );
    if (picked != null) {
      if (isStart) {
        notifier.setStartTime(picked);
      } else {
        notifier.setEndTime(picked);
      }
    }
  }

  void _showPresetPicker(BuildContext context, ManualSessionFormNotifier notifier) {
    final presetMapAsync = ref.read(presetMapProvider);
    final presets = presetMapAsync.valueOrNull?.values.toList() ?? [];

    if (presets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('프리셋이 없습니다. 먼저 프리셋을 만들어주세요.')),
      );
      return;
    }

    // sortOrder 기준 정렬 (홈 화면과 동일한 순서)
    presets.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.padding, AppSpacing.padding, AppSpacing.padding, 0),
              child: Text('프리셋 선택', style: Theme.of(context).textTheme.titleLarge),
            ),
            const SizedBox(height: AppSpacing.grid),
            // 프리셋 목록이 길 수 있으므로 스크롤 가능하도록 제한
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: presets.length,
                itemBuilder: (context, index) {
                  final preset = presets[index];
                  final color = ColorUtils.fromHex(preset.color);
                  final icon = AppConstants.presetIcons[preset.icon] ?? Icons.timer;

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
                    subtitle: preset.durationMin > 0 ? Text('${preset.durationMin}분') : const Text('스톱워치'),
                    onTap: () {
                      notifier.setPreset(preset);
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.grid),
          ],
        ),
      ),
    );
  }
}

// ── 섹션 라벨 ──────────────────────────────────────────────────

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

// ── 프리셋 선택기 ──────────────────────────────────────────────

class _PresetSelector extends StatelessWidget {
  const _PresetSelector({required this.selectedPreset, required this.onTap});

  final Preset? selectedPreset;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (selectedPreset == null) {
      return _SelectableTile(
        leading: Icon(Icons.add_circle_outline, color: theme.colorScheme.outline),
        title: '프리셋을 선택하세요',
        titleStyle: TextStyle(color: theme.colorScheme.outline),
        onTap: onTap,
      );
    }

    final preset = selectedPreset!;
    final color = ColorUtils.fromHex(preset.color);
    final icon = AppConstants.presetIcons[preset.icon] ?? Icons.timer;

    return _SelectableTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppSpacing.grid),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: preset.name,
      onTap: onTap,
    );
  }
}

// ── 날짜 선택기 ────────────────────────────────────────────────

class _DateSelector extends StatelessWidget {
  const _DateSelector({required this.date, required this.onTap});

  final DateTime? date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = date != null ? '${date!.year}년 ${date!.month}월 ${date!.day}일' : '날짜를 선택하세요';

    return _SelectableTile(
      leading: Icon(Icons.calendar_today, color: date != null ? theme.colorScheme.primary : theme.colorScheme.outline),
      title: label,
      titleStyle: date == null ? TextStyle(color: theme.colorScheme.outline) : null,
      onTap: onTap,
    );
  }
}

// ── 시간 선택기 ────────────────────────────────────────────────

class _TimeSelector extends StatelessWidget {
  const _TimeSelector({required this.label, required this.time, required this.onTap});

  final String label;
  final TimeOfDay? time;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeText = time != null
        ? '${time!.hour.toString().padLeft(2, '0')}:${time!.minute.toString().padLeft(2, '0')}'
        : label;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.gap, horizontal: AppSpacing.padding),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        ),
        child: Column(
          children: [
            Text(label, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline)),
            const SizedBox(height: 4),
            Text(
              timeText,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: time != null ? null : theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 소요 시간 표시 ──────────────────────────────────────────────

class _DurationDisplay extends StatelessWidget {
  const _DurationDisplay({required this.durationSeconds});

  final int durationSeconds;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hours = durationSeconds ~/ 3600;
    final minutes = (durationSeconds % 3600) ~/ 60;

    String text;
    if (hours > 0 && minutes > 0) {
      text = '$hours시간 $minutes분';
    } else if (hours > 0) {
      text = '$hours시간';
    } else {
      text = '$minutes분';
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.timer_outlined, size: 18, color: theme.colorScheme.primary),
        const SizedBox(width: 6),
        Text('소요 시간: $text', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.primary)),
      ],
    );
  }
}

// ── 공통 선택 타일 ──────────────────────────────────────────────

class _SelectableTile extends StatelessWidget {
  const _SelectableTile({
    required this.leading,
    required this.title,
    required this.onTap,
    this.titleStyle,
  });

  final Widget leading;
  final String title;
  final VoidCallback onTap;
  final TextStyle? titleStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.gap, horizontal: AppSpacing.padding),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        ),
        child: Row(
          children: [
            leading,
            const SizedBox(width: AppSpacing.gap),
            Expanded(child: Text(title, style: titleStyle ?? theme.textTheme.bodyLarge)),
            Icon(Icons.chevron_right, color: theme.colorScheme.outline),
          ],
        ),
      ),
    );
  }
}
