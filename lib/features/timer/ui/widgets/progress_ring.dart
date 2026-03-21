import 'dart:math';

import 'package:flutter/material.dart';

/// 원형 프로그레스 링.
///
/// 타이머 카운트다운의 진행률을 시각적으로 표시한다.
/// 시작점은 12시 방향(상단)이며, 시계 방향으로 채워진다.
class ProgressRing extends StatelessWidget {
  const ProgressRing({
    required this.progress,
    required this.color,
    this.strokeWidth = 12,
    this.size = 280,
    this.child,
    super.key,
  });

  /// 진행률 (0.0 ~ 1.0)
  final double progress;

  /// 프로그레스 바 색상 (프리셋 색상 사용)
  final Color color;

  /// 선 두께
  final double strokeWidth;

  /// 위젯 크기 (정사각형)
  final double size;

  /// 링 내부에 표시할 위젯 (카운트다운 텍스트 등)
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _ProgressRingPainter(
              progress: progress,
              color: color,
              strokeWidth: strokeWidth,
            ),
          ),
          if (child != null) child!,
        ],
      ),
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  _ProgressRingPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  final double progress;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - strokeWidth) / 2;

    // 배경 트랙
    final bgPaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    // 진행률 호 — 12시 방향(-π/2)에서 시계 방향으로 채운다
    if (progress > 0) {
      final fgPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        2 * pi * progress.clamp(0.0, 1.0),
        false,
        fgPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_ProgressRingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
