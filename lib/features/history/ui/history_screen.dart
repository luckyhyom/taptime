import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taptime/core/providers/app_providers.dart';
import 'package:taptime/core/router/app_router.dart';
import 'package:taptime/core/theme/app_spacing.dart';
import 'package:taptime/core/utils/date_utils.dart';
import 'package:taptime/features/history/ui/history_providers.dart';
import 'package:taptime/features/history/ui/widgets/session_list_tile.dart';
import 'package:taptime/shared/models/preset.dart';
import 'package:taptime/shared/models/session.dart';

/// 세션 기록 화면 — 날짜별 타이머 기록을 표시한다.
///
/// 상단: 날짜 네비게이터 (이전/다음 날, 오늘 버튼)
/// 본문: 선택된 날짜의 세션 목록 (최신순)
/// 인터랙션: 탭 → 메모 편집, 스와이프 → 삭제
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final sessionsAsync = ref.watch(sessionsForDateProvider);
    final presetMapAsync = ref.watch(presetMapProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('기록'),
        actions: [
          // 오늘이 아닌 날짜를 보고 있을 때만 "오늘" 버튼 표시
          if (!selectedDate.isSameDay(DateTime.now()))
            TextButton(
              onPressed: () => ref.read(selectedDateProvider.notifier).state = DateTime.now(),
              child: const Text('오늘'),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.sessionNew),
        tooltip: '세션 기록',
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          _DateNavigator(
            date: selectedDate,
            onPrevious: () =>
                ref.read(selectedDateProvider.notifier).state = selectedDate.subtract(const Duration(days: 1)),
            // 오늘보다 미래로는 이동 불가
            onNext: selectedDate.isSameDay(DateTime.now())
                ? null
                : () =>
                    ref.read(selectedDateProvider.notifier).state = selectedDate.add(const Duration(days: 1)),
          ),
          Expanded(
            child: sessionsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('오류가 발생했습니다: $error')),
              data: (sessions) {
                if (sessions.isEmpty) {
                  return const Center(child: Text('이 날짜에 기록이 없습니다.'));
                }
                final presetMap = presetMapAsync.valueOrNull ?? {};
                return _SessionList(
                  sessions: sessions,
                  presetMap: presetMap,
                  onEditMemo: (session) => _showMemoEditor(context, ref, session),
                  onDelete: (session) => _deleteSession(ref, session),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── 메모 편집 ──────────────────────────────────────────────

  void _showMemoEditor(BuildContext context, WidgetRef ref, Session session) {
    final controller = TextEditingController(text: session.memo ?? '');

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.padding,
          right: AppSpacing.padding,
          top: AppSpacing.sectionGap,
          // 키보드가 올라올 때 입력 필드가 가려지지 않도록 하단 인셋을 추가
          bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.padding,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('메모', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.gap),
            TextField(
              controller: controller,
              autofocus: true,
              maxLines: 3,
              maxLength: 200,
              decoration: const InputDecoration(
                hintText: '메모를 입력하세요',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSpacing.gap),
            Row(
              children: [
                // 기존 메모가 있을 때만 삭제 버튼 표시
                if (session.memo != null && session.memo!.isNotEmpty)
                  TextButton(
                    onPressed: () async {
                      await ref.read(sessionRepositoryProvider).updateSession(session.clearMemo());
                      if (context.mounted) Navigator.of(context).pop();
                    },
                    child: const Text('메모 삭제'),
                  ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('취소'),
                ),
                const SizedBox(width: AppSpacing.grid),
                FilledButton(
                  onPressed: () async {
                    final text = controller.text.trim();
                    final repo = ref.read(sessionRepositoryProvider);
                    if (text.isEmpty) {
                      await repo.updateSession(session.clearMemo());
                    } else {
                      await repo.updateSession(session.copyWith(memo: text));
                    }
                    if (context.mounted) Navigator.of(context).pop();
                  },
                  child: const Text('저장'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── 세션 삭제 ──────────────────────────────────────────────

  Future<void> _deleteSession(WidgetRef ref, Session session) async {
    await ref.read(sessionRepositoryProvider).deleteSession(session.id);
  }
}

// ── 날짜 네비게이터 ─────────────────────────────────────────

/// 이전/다음 날짜 이동 및 현재 날짜 표시.
///
/// 오늘: "오늘", 어제: "어제", 그 외: "M월 D일 (요일)" 형식.
class _DateNavigator extends StatelessWidget {
  const _DateNavigator({
    required this.date,
    required this.onPrevious,
    this.onNext,
  });

  final DateTime date;
  final VoidCallback onPrevious;

  /// null이면 다음 버튼 비활성화 (오늘일 때)
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final isToday = date.isSameDay(now);
    final isYesterday = date.isSameDay(now.subtract(const Duration(days: 1)));

    String label;
    if (isToday) {
      label = '오늘';
    } else if (isYesterday) {
      label = '어제';
    } else {
      label = '${date.month}월 ${date.day}일 (${_weekdayName(date.weekday)})';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.grid,
        vertical: AppSpacing.grid,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: onPrevious,
          ),
          Text(label, style: theme.textTheme.titleMedium),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: onNext,
          ),
        ],
      ),
    );
  }

  static String _weekdayName(int weekday) {
    const names = ['월', '화', '수', '목', '금', '토', '일'];
    return names[weekday - 1];
  }
}

// ── 세션 리스트 ─────────────────────────────────────────────

class _SessionList extends StatelessWidget {
  const _SessionList({
    required this.sessions,
    required this.presetMap,
    required this.onEditMemo,
    required this.onDelete,
  });

  final List<Session> sessions;
  final Map<String, Preset> presetMap;
  final void Function(Session) onEditMemo;
  final void Function(Session) onDelete;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.padding),
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        final session = sessions[index];
        return SessionListTile(
          session: session,
          preset: presetMap[session.presetId],
          onTap: () => onEditMemo(session),
          onDelete: () => onDelete(session),
        );
      },
    );
  }
}
