import 'package:flutter/material.dart';
import 'dart:math' as math;

class EnhancedDonutChart extends StatelessWidget {
  final double percentage;
  final List<ChartSegment> segments;

  const EnhancedDonutChart({
    required this.percentage,
    required this.segments,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(180, 180),
      painter: _EnhancedDonutPainter(percentage, segments),
    );
  }
}

class ChartSegment {
  final double value;
  final Color color;

  const ChartSegment({required this.value, required this.color});
}

class _EnhancedDonutPainter extends CustomPainter {
  final double percentage;
  final List<ChartSegment> segments;

  _EnhancedDonutPainter(this.percentage, this.segments);

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 24.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Draw background circle
    final bgPaint = Paint()
      ..color = Colors.grey.shade200
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, bgPaint);

    // Draw segments
    double startAngle = -math.pi / 2;
    final totalValue = segments.fold<double>(0, (sum, seg) => sum + seg.value);

    for (final segment in segments) {
      final sweepAngle = 2 * math.pi * (segment.value / totalValue);
      final paint = Paint()
        ..color = segment.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }

    // Draw percentage text
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${(percentage * 100).round()}%',
        style: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: Colors.black,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      center - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}