import 'package:flutter/material.dart';

import 'package:taptime/core/constants/app_constants.dart';
import 'package:taptime/core/theme/app_spacing.dart';
import 'package:taptime/core/utils/color_utils.dart';
import 'package:taptime/shared/models/preset.dart';
import 'package:taptime/shared/models/session.dart';

/// 세션 기록 리스트 타일.
///
/// 프리셋 아이콘, 이름, 시간 범위, 소요 시간, 상태 뱃지를 표시한다.
/// 프리셋이 삭제된 경우 기본 아이콘과 "삭제된 프리셋"으로 표시한다.
/// 탭하면 메모 편집, 좌로 스와이프하면 삭제 확인 후 삭제.
class SessionListTile extends StatelessWidget {
  const SessionListTile({
    required this.session,
    this.preset,
    this.onTap,
    this.onDelete,
    super.key,
  });

  final Session session;

  /// 세션에 연결된 프리셋. 삭제된 프리셋이면 null.
  final Preset? preset;

  /// 탭 콜백 (메모 편집에 사용)
  final VoidCallback? onTap;

  /// 삭제 콜백 (Dismissible에서 호출)
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = preset != null ? ColorUtils.fromHex(preset!.color) : theme.colorScheme.outline;
    final icon = preset != null ? (AppConstants.presetIcons[preset!.icon] ?? Icons.timer) : Icons.delete_outline;
    final presetName = preset?.name ?? '삭제된 프리셋';

    return Dismissible(
      key: ValueKey(session.id),
      direction: DismissDirection.endToStart,
      background: _buildDismissBackground(),
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) => onDelete?.call(),
      child: Card(
        margin: const EdgeInsets.only(bottom: AppSpacing.grid),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.padding,
              vertical: AppSpacing.gap,
            ),
            child: Row(
              children: [
                // 프리셋 아이콘
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: AppSpacing.gap),
                // 프리셋 이름 + 시간 범위 + 메모
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        presetName,
                        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatTimeRange(session.startedAt, session.endedAt),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (session.memo != null && session.memo!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          session.memo!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.gap),
                // 소요 시간 + 상태 뱃지
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatDuration(session.durationSeconds),
                      style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    _StatusBadge(status: session.status),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDismissBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: AppSpacing.sectionGap),
      margin: const EdgeInsets.only(bottom: AppSpacing.grid),
      decoration: BoxDecoration(
        color: Colors.red.shade400,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: const Icon(Icons.delete, color: Colors.white),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('기록 삭제'),
            content: const Text('이 세션 기록을 삭제하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('삭제'),
              ),
            ],
          ),
        ) ??
        false;
  }

  /// 시간 범위를 "HH:MM - HH:MM" 형식으로 표시.
  static String _formatTimeRange(DateTime start, DateTime end) {
    String fmt(DateTime dt) => '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    return '${fmt(start)} - ${fmt(end)}';
  }

  /// 초를 읽기 쉬운 문자열로 변환.
  /// 1분 미만이면 초 단위로, 그 외에는 시:분 형식으로 표시.
  static String _formatDuration(int totalSeconds) {
    if (totalSeconds < 60) return '${totalSeconds}s';
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    if (hours == 0) return '${minutes}m';
    if (minutes == 0) return '${hours}h';
    return '${hours}h ${minutes}m';
  }
}

// ── 상태 뱃지 ──────────────────────────────────────────────

/// 세션 완료/중단 상태를 색상 뱃지로 표시한다.
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final SessionStatus status;

  @override
  Widget build(BuildContext context) {
    final isCompleted = status == SessionStatus.completed;
    final color = isCompleted ? Colors.green : Colors.orange;
    final label = isCompleted ? '완료' : '중단';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w500),
      ),
    );
  }
}
