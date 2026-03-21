import 'dart:async';

import 'package:flutter/material.dart';

import 'package:taptime/core/constants/app_constants.dart';
import 'package:taptime/core/theme/app_spacing.dart';
import 'package:taptime/core/utils/color_utils.dart';
import 'package:taptime/core/utils/date_utils.dart';
import 'package:taptime/shared/models/preset.dart';

/// 홈 화면 그리드에 표시되는 프리셋 카드.
///
/// 아이콘, 이름, 시간(분), 일일 진행률을 하나의 카드에 표시한다.
/// 탭하면 타이머 화면으로, 길게 누르면 수정 화면으로 이동한다.
///
/// todayMinutes는 오늘 이 프리셋으로 기록한 누적 시간이다.
/// Phase 3(타이머)에서 실제 세션 데이터가 연결되기 전까지는 0으로 표시된다.
/// 프리셋 카드의 타이머 활성 상태.
enum PresetTimerStatus { none, running, paused }

class PresetCard extends StatelessWidget {
  const PresetCard({
    required this.preset,
    this.todayMinutes = 0,
    this.timerStatus = PresetTimerStatus.none,
    this.timerDisplaySeconds = 0,
    this.isCountdown = false,
    this.onTap,
    this.onLongPress,
    super.key,
  });

  final Preset preset;

  /// 오늘 이 프리셋으로 기록한 시간 (분 단위)
  final int todayMinutes;

  /// 이 프리셋의 타이머 활성 상태
  final PresetTimerStatus timerStatus;

  /// 배지에 표시할 시간 (초). 카운트다운이면 남은 시간, 스톱워치면 경과 시간.
  final int timerDisplaySeconds;

  /// 카운트다운 모드 여부. true면 매초 감소, false면 매초 증가.
  final bool isCountdown;

  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final presetColor = ColorUtils.fromHex(preset.color);
    // DB에 저장된 아이콘 키를 실제 IconData로 변환한다.
    // 매핑에 없는 키가 올 경우 기본 타이머 아이콘을 사용한다.
    final icon = AppConstants.presetIcons[preset.icon] ?? Icons.timer;
    final theme = Theme.of(context);

    // 일일 목표 진행률 (0.0 ~ 1.0)
    // dailyGoalMin이 0이면 목표가 없으므로 진행률 바를 표시하지 않는다.
    final hasGoal = preset.dailyGoalMin > 0;
    final progress = hasGoal ? (todayMinutes / preset.dailyGoalMin).clamp(0.0, 1.0) : 0.0;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 아이콘 배지 + 타이머 상태 ─────────────────────────
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: presetColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                    ),
                    child: Icon(icon, color: presetColor, size: 28),
                  ),
                  const Spacer(),
                  if (timerStatus != PresetTimerStatus.none)
                    _TimerStatusBadge(
                      status: timerStatus,
                      color: presetColor,
                      displaySeconds: timerDisplaySeconds,
                      isCountdown: isCountdown,
                    ),
                ],
              ),

              const SizedBox(height: AppSpacing.gap),

              // ── 이름 + 시간 ─────────────────────────────────────
              Text(
                preset.name,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                preset.durationMin > 0 ? '${preset.durationMin}분' : '무제한',
                style: theme.textTheme.bodySmall,
              ),

              // Column 내부에서 남은 공간을 차지하여
              // 진행률 바를 카드 하단에 고정한다.
              const Spacer(),

              // ── 일일 진행률 ─────────────────────────────────────
              if (hasGoal) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: presetColor.withValues(alpha: 0.15),
                    valueColor: AlwaysStoppedAnimation<Color>(presetColor),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$todayMinutes / ${preset.dailyGoalMin}분',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── 타이머 상태 배지 ────────────────────────────────────────────

/// 프리셋 카드 우측 상단에 표시되는 타이머 상태 배지.
///
/// 실행 중일 때 매초 시간을 갱신한다.
/// 카운트다운이면 감소, 스톱워치면 증가.
/// StatefulWidget인 이유: 주기적 Timer로 매초 setState를 호출하기 위함.
class _TimerStatusBadge extends StatefulWidget {
  const _TimerStatusBadge({
    required this.status,
    required this.color,
    required this.displaySeconds,
    required this.isCountdown,
  });

  final PresetTimerStatus status;
  final Color color;
  final int displaySeconds;
  final bool isCountdown;

  @override
  State<_TimerStatusBadge> createState() => _TimerStatusBadgeState();
}

class _TimerStatusBadgeState extends State<_TimerStatusBadge> {
  Timer? _ticker;
  late int _displaySeconds;

  @override
  void initState() {
    super.initState();
    _displaySeconds = widget.displaySeconds;
    _startTickerIfNeeded();
  }

  @override
  void didUpdateWidget(_TimerStatusBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 외부에서 새 값이 들어오면(일시정지/재개 등) 동기화한다.
    _displaySeconds = widget.displaySeconds;
    if (oldWidget.status != widget.status) {
      _startTickerIfNeeded();
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _startTickerIfNeeded() {
    _ticker?.cancel();
    if (widget.status == PresetTimerStatus.running) {
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() {
          // 카운트다운: 감소 (0 이하로 내려가지 않음), 스톱워치: 증가
          if (widget.isCountdown) {
            _displaySeconds = (_displaySeconds - 1).clamp(0, 999999);
          } else {
            _displaySeconds++;
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRunning = widget.status == PresetTimerStatus.running;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: widget.color.withValues(alpha: isRunning ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 실행 중 = ⏸(일시정지 가능), 일시정지 = ▶(재개 가능)
          Icon(
            isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
            size: 14,
            color: widget.color,
          ),
          const SizedBox(width: 2),
          Text(
            TimeFormatter.mmss(_displaySeconds),
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: widget.color),
          ),
        ],
      ),
    );
  }
}
