import 'package:flutter/material.dart';

class GuidedPathwaysCard extends StatelessWidget {
  const GuidedPathwaysCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pathways = [
      {
        'title': 'Anxiety Reset',
        'description': '7-day program to break anxiety cycles',
        'progress': 0.6,
        'currentDay': 4,
        'totalDays': 7,
        'color': Colors.orange,
        'icon': Icons.warning_amber,
      },
      {
        'title': 'Sleep Restoration',
        'description': 'Improve sleep quality and establish healthy habits',
        'progress': 0.3,
        'currentDay': 2,
        'totalDays': 7,
        'color': Colors.indigo,
        'icon': Icons.nightlight,
      },
      {
        'title': 'Self-Esteem Building',
        'description': 'Develop confidence and self-compassion',
        'progress': 0.8,
        'currentDay': 6,
        'totalDays': 7,
        'color': Colors.pink,
        'icon': Icons.favorite,
      },
    ];

    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: pathways.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final pathway = pathways[index];
          return Container(
            width: 280,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      pathway['icon'] as IconData,
                      color: pathway['color'] as Color,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        pathway['title'] as String,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  pathway['description'] as String,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: pathway['progress'] as double,
                  backgroundColor: (pathway['color'] as Color).withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    pathway['color'] as Color,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Day ${pathway['currentDay']} of ${pathway['totalDays']} • ${((pathway['progress'] as double) * 100).round()}% complete',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.tonal(
                    onPressed: () {},
                    style: FilledButton.styleFrom(
                      backgroundColor: (pathway['color'] as Color).withValues(alpha: 0.1),
                      foregroundColor: pathway['color'] as Color,
                    ),
                    child: const Text('Continue'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}