import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taptime/core/providers/app_providers.dart';
import 'package:taptime/core/theme/app_spacing.dart';
import 'package:taptime/shared/models/user_settings.dart';

/// 설정 화면 — 테마, 알림, 데이터 초기화 등을 관리한다.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(userSettingsStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('오류: $e')),
        data: (settings) => ListView(
          children: [
            const SizedBox(height: AppSpacing.grid),

            // ── 테마 ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.padding),
              child: Text('테마', style: Theme.of(context).textTheme.titleMedium),
            ),
            const SizedBox(height: AppSpacing.grid),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.padding),
              child: SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(value: ThemeMode.system, label: Text('시스템')),
                  ButtonSegment(value: ThemeMode.light, label: Text('라이트')),
                  ButtonSegment(value: ThemeMode.dark, label: Text('다크')),
                ],
                selected: {settings.themeMode},
                onSelectionChanged: (selected) => _updateSettings(
                  ref,
                  settings.copyWith(themeMode: selected.first),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.sectionGap),

            // ── 알림 ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.padding),
              child: Text('알림', style: Theme.of(context).textTheme.titleMedium),
            ),
            SwitchListTile(
              title: const Text('사운드'),
              subtitle: const Text('타이머 완료 시 알림음'),
              value: settings.soundEnabled,
              onChanged: (value) => _updateSettings(
                ref,
                settings.copyWith(soundEnabled: value),
              ),
            ),
            SwitchListTile(
              title: const Text('진동'),
              subtitle: const Text('타이머 완료 시 진동'),
              value: settings.vibrationEnabled,
              onChanged: (value) => _updateSettings(
                ref,
                settings.copyWith(vibrationEnabled: value),
              ),
            ),

            const Divider(height: AppSpacing.sectionGap * 2),

            // ── 데이터 ────────────────────────────────────────
            ListTile(
              leading: Icon(Icons.delete_forever, color: Theme.of(context).colorScheme.error),
              title: const Text('모든 데이터 초기화'),
              subtitle: const Text('프리셋, 기록, 설정을 모두 삭제합니다'),
              onTap: () => _confirmReset(context, ref),
            ),

            const Divider(height: AppSpacing.sectionGap * 2),

            // ── 앱 정보 ───────────────────────────────────────
            const ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('앱 버전'),
              subtitle: Text('v1.0.0'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateSettings(WidgetRef ref, UserSettings settings) async {
    await ref.read(userSettingsRepositoryProvider).updateSettings(settings);
  }

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('모든 데이터 초기화'),
        content: const Text('모든 프리셋, 기록, 설정이 삭제됩니다.\n이 작업은 되돌릴 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('초기화'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // 프리셋 삭제 (CASCADE로 세션, 활성 타이머도 함께 삭제됨)
    await ref.read(presetRepositoryProvider).deleteAllPresets();
    // 설정을 기본값으로 복원
    await ref.read(userSettingsRepositoryProvider).updateSettings(UserSettings.defaults());
    // 기본 프리셋 재생성 (앱 초기화 로직 재실행 후 완료 대기)
    ref.invalidate(appInitProvider);
    await ref.read(appInitProvider.future);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('모든 데이터가 초기화되었습니다.')),
      );
    }
  }
}
