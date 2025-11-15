import 'package:flutter/material.dart';

class QuoteCard extends StatelessWidget {
  final String quote;
  const QuoteCard({required this.quote, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.pink.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(quote, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}

class DonutChart extends StatelessWidget {
  final double percent;
  const DonutChart({required this.percent, super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(120, 120),
      painter: _DonutPainter(percent),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final double percent;
  _DonutPainter(this.percent);

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 18.0;
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = (size.width - stroke) / 2;

    final bg = Paint()
      ..color = Colors.grey.shade200
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    canvas.drawCircle(center, radius, bg);

    final prog = Paint()
      ..shader = SweepGradient(
        colors: [
          Colors.purple.shade200,
          Colors.blue.shade200,
          Colors.yellow.shade200,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    final sweep = 2 * 3.1415926 * percent;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.1415926 / 2,
      sweep,
      false,
      prog,
    );

    final tp = TextPainter(
      text: TextSpan(
        text: '${(percent * 100).round()}%',
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ContentListItem extends StatelessWidget {
  final String title;
  final String subtitle;
  const ContentListItem({
    required this.title,
    required this.subtitle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
