import 'package:flutter/material.dart';

class DailyWisdomCard extends StatelessWidget {
  const DailyWisdomCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final wisdoms = [
      {
        'quote':
            '"Success is not final, failure is not fatal: it is the courage to continue that counts." - Winston Churchill',
        'color': Colors.pink,
      },
      {
        'quote': '"The only way out is through." - Robert Frost',
        'color': Colors.purple,
      },
      {
        'quote':
            '"You are braver than you believe, stronger than you seem, and smarter than you think." - A.A. Milne',
        'color': Colors.blue,
      },
    ];

    final today = DateTime.now().day % wisdoms.length;
    final wisdom = wisdoms[today];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: (wisdom['color'] as Color).withOpacity(0.1),
        border: Border.all(
          color: (wisdom['color'] as Color).withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '✨ Daily Wisdom',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: wisdom['color'] as Color,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            wisdom['quote'] as String,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  height: 1.6,
                ),
          ),
        ],
      ),
    );
  }
}