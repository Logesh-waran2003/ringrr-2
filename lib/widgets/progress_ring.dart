import 'dart:math';
import 'package:flutter/material.dart';
import 'package:ringrr/theme/app_theme.dart';

class ProgressRing extends StatelessWidget {
  final double percentage;
  final double radius;
  final double strokeWidth;
  final Color? progressColor;

  const ProgressRing({
    super.key,
    required this.percentage,
    this.radius = 38,
    this.strokeWidth = 9,
    this.progressColor,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(radius * 2, radius * 2),
      painter: _ProgressRingPainter(
        percentage: percentage,
        trackColor: AppColors.border,
        progressColor: progressColor ?? AppColors.primary,
        strokeWidth: strokeWidth,
      ),
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  final double percentage;
  final Color trackColor;
  final Color progressColor;
  final double strokeWidth;

  _ProgressRingPainter({
    required this.percentage,
    required this.trackColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, trackPaint);

    // Progress arc
    if (percentage > 0) {
      final progressPaint = Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      final sweepAngle = 2 * pi * (percentage / 100);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2, // start at top
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_ProgressRingPainter old) => old.percentage != percentage;
}
