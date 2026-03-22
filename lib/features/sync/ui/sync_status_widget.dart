import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taptime/core/providers/app_providers.dart';
import 'package:taptime/core/providers/auth_providers.dart';
import 'package:taptime/shared/services/sync_service.dart';

/// AppBar에 표시되는 동기화 상태 아이콘.
///
/// 로그인 상태에서만 표시되며, 동기화 상태에 따라 아이콘이 변한다:
/// - idle: cloud_outlined (회색)
/// - syncing: sync 아이콘 회전 애니메이션
/// - synced: cloud_done (primary 색상)
/// - error: cloud_off (error 색상)
class SyncStatusWidget extends ConsumerWidget {
  const SyncStatusWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.watch(isLoggedInProvider);
    if (!isLoggedIn) return const SizedBox.shrink();

    final statusAsync = ref.watch(syncStatusProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: statusAsync.when(
        loading: () => const SizedBox.shrink(),
        error: (_, __) => const Icon(Icons.cloud_off, size: 20),
        data: (status) => switch (status) {
          SyncStatus.idle => const Icon(Icons.cloud_outlined, size: 20),
          SyncStatus.syncing => const _SyncingIcon(),
          SyncStatus.synced => Icon(Icons.cloud_done, size: 20, color: Theme.of(context).colorScheme.primary),
          SyncStatus.error => Icon(Icons.cloud_off, size: 20, color: Theme.of(context).colorScheme.error),
        },
      ),
    );
  }
}

/// 동기화 진행 중 아이콘 — 반복 회전 애니메이션.
class _SyncingIcon extends StatefulWidget {
  const _SyncingIcon();

  @override
  State<_SyncingIcon> createState() => _SyncingIconState();
}

class _SyncingIconState extends State<_SyncingIcon> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: const Icon(Icons.sync, size: 20),
    );
  }
}
