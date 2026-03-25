import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taptime/core/providers/app_providers.dart';
import 'package:taptime/core/providers/auth_providers.dart';
import 'package:taptime/core/router/app_router.dart';
import 'package:taptime/core/theme/app_spacing.dart';
import 'package:taptime/core/utils/date_utils.dart';
import 'package:taptime/shared/models/user_settings.dart';
import 'package:taptime/shared/services/geofence_service.dart';
import 'package:taptime/shared/services/sync_service.dart';

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

            // ── 계정 ──────────────────────────────────────────
            const _AccountSection(),
            const Divider(height: AppSpacing.sectionGap * 2),

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

            // ── 위치 (iOS 전용) ────────────────────────────────
            if (Platform.isIOS) ...[
              const Divider(height: AppSpacing.sectionGap * 2),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.padding),
                child: Text('위치', style: Theme.of(context).textTheme.titleMedium),
              ),
              SwitchListTile(
                title: const Text('위치 기반 자동 트래킹'),
                subtitle: const Text('등록된 장소에 도착 시 타이머 시작 알림'),
                value: settings.locationTrackingEnabled,
                onChanged: (value) => _toggleLocationTracking(context, ref, settings, value),
              ),
              // 권한 상태 표시 (트래킹 활성화 시)
              if (settings.locationTrackingEnabled) _PermissionStatusTile(ref: ref),
            ],

            const Divider(height: AppSpacing.sectionGap * 2),

            // ── 데이터 ────────────────────────────────────────
            ListTile(
              leading: const Icon(Icons.archive_outlined),
              title: const Text('보관된 프리셋'),
              subtitle: const Text('보관한 프리셋을 복원하거나 삭제합니다'),
              onTap: () => context.push(AppRoutes.archivedPresets),
            ),
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

  /// 위치 트래킹 토글 처리.
  ///
  /// 켤 때: 위치 권한을 요청하고, "항상 허용"이 아니면 안내 후 취소.
  /// 끌 때: 즉시 설정 저장 (GeofenceManager가 자동으로 중지됨).
  Future<void> _toggleLocationTracking(
    BuildContext context,
    WidgetRef ref,
    UserSettings settings,
    bool value,
  ) async {
    if (!value) {
      await _updateSettings(ref, settings.copyWith(locationTrackingEnabled: false));
      return;
    }

    // 권한 요청
    final geofenceService = ref.read(geofenceServiceProvider);
    var status = await geofenceService.requestPermission();

    // WhenInUse → Always 업그레이드 시도
    if (status == GeofencePermissionStatus.authorizedWhenInUse) {
      status = await geofenceService.requestPermission();
    }

    if (status == GeofencePermissionStatus.authorizedAlways) {
      await _updateSettings(ref, settings.copyWith(locationTrackingEnabled: true));
    } else if (context.mounted) {
      // 권한 부족 — 설정 안내
      final message = switch (status) {
        GeofencePermissionStatus.denied => '위치 권한이 거부되었습니다.\n설정에서 "항상 허용"으로 변경해주세요.',
        GeofencePermissionStatus.restricted => '위치 서비스가 제한되어 있습니다.',
        GeofencePermissionStatus.authorizedWhenInUse =>
          '백그라운드 위치 모니터링에는 "항상 허용" 권한이 필요합니다.\n설정에서 변경해주세요.',
        _ => '위치 권한을 허용해주세요.',
      };

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 5)),
      );
    }
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

    // 위치 트리거 삭제 + 네이티브 영역 제거 (프리셋 FK보다 먼저 삭제)
    await ref.read(locationTriggerRepositoryProvider).deleteAllTriggers();
    if (Platform.isIOS) {
      await ref.read(geofenceServiceProvider).removeAllRegions();
    }
    // 프리셋 삭제 (CASCADE로 세션, 활성 타이머도 함께 삭제됨)
    await ref.read(presetRepositoryProvider).deleteAllPresets();
    // 설정을 기본값으로 복원 (locationTrackingEnabled도 false로 리셋)
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

/// 계정 섹션 — 로그인 상태에 따라 프로필 또는 로그인 버튼을 표시한다.
class _AccountSection extends ConsumerWidget {
  const _AccountSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsync = ref.watch(authStateProvider);

    return authAsync.when(
      loading: () => const ListTile(
        leading: Icon(Icons.account_circle_outlined),
        title: Text('계정'),
        trailing: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (_, __) => ListTile(
        leading: const Icon(Icons.account_circle_outlined),
        title: const Text('계정'),
        subtitle: const Text('연결 실패'),
        onTap: () => context.push(AppRoutes.login),
      ),
      data: (user) {
        if (user == null) {
          return ListTile(
            leading: const Icon(Icons.account_circle_outlined),
            title: const Text('로그인'),
            subtitle: const Text('클라우드 동기화를 사용하려면 로그인하세요'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRoutes.login),
          );
        }

        return ListTile(
          leading: const Icon(Icons.account_circle),
          title: Text(user.displayLabel),
          subtitle: _SyncSubtitle(email: user.email),
          isThreeLine: true,
          trailing: TextButton(
            onPressed: () => _confirmSignOut(context, ref),
            child: const Text('로그아웃'),
          ),
        );
      },
    );
  }

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('로그아웃하면 클라우드 동기화가 중단됩니다.\n로컬 데이터는 유지됩니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('로그아웃'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final authService = ref.read(authServiceProvider);
    await authService?.signOut();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그아웃되었습니다.')),
      );
    }
  }
}

/// 위치 권한 상태를 확인하여 표시하는 타일.
///
/// Always 권한이 아니면 경고 메시지를 보여준다.
/// denied/restricted 상태에서는 iOS 설정에서만 변경 가능하다.
class _PermissionStatusTile extends StatelessWidget {
  const _PermissionStatusTile({required this.ref});

  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<GeofencePermissionStatus>(
      future: ref.read(geofenceServiceProvider).checkPermission(),
      builder: (context, snapshot) {
        final status = snapshot.data;
        if (status == null || status == GeofencePermissionStatus.authorizedAlways) {
          return const SizedBox.shrink();
        }

        final (icon, label) = switch (status) {
          GeofencePermissionStatus.authorizedWhenInUse => (
              Icons.warning_amber_rounded,
              '설정 > 위치에서 "항상 허용"으로 변경해주세요',
            ),
          GeofencePermissionStatus.denied => (
              Icons.location_off,
              '설정 > 위치에서 위치 권한을 허용해주세요',
            ),
          GeofencePermissionStatus.restricted => (
              Icons.lock_outline,
              '기기 제한으로 위치 서비스를 사용할 수 없습니다',
            ),
          _ => (Icons.location_off, '위치 권한을 허용해주세요'),
        };

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.padding),
          child: Row(
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.error, size: 18),
              const SizedBox(width: AppSpacing.grid),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// 이메일 + 동기화 상태를 표시하는 서브타이틀.
class _SyncSubtitle extends ConsumerWidget {
  const _SyncSubtitle({required this.email});

  final String email;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(syncStatusProvider);
    final lastSync = ref.watch(lastSyncTimeProvider).valueOrNull;

    final syncLabel = statusAsync.whenOrNull(
      data: (status) => switch (status) {
        SyncStatus.syncing => '동기화 중...',
        SyncStatus.synced when lastSync != null => '마지막 동기화: ${TimeFormatter.relativeTime(lastSync)}',
        SyncStatus.error => '동기화 실패',
        _ => null,
      },
    );

    if (syncLabel == null) return Text(email);
    return Text('$email\n$syncLabel');
  }
}
