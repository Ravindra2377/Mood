import 'package:flutter/material.dart';

class AssessmentsCard extends StatelessWidget {
  const AssessmentsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final assessments = [
      {
        'title': 'GAD-7',
        'fullTitle': 'Generalized Anxiety Disorder',
        'description': '7-item assessment for anxiety symptoms',
        'lastScore': 12,
        'previousScore': 15,
        'color': Colors.blue,
        'icon': Icons.psychology,
        'severity': 'Moderate',
      },
      {
        'title': 'PHQ-9',
        'fullTitle': 'Patient Health Questionnaire',
        'description': '9-item assessment for depression symptoms',
        'lastScore': 8,
        'previousScore': 10,
        'color': Colors.green,
        'icon': Icons.mood,
        'severity': 'Mild',
      },
      {
        'title': 'PSS',
        'fullTitle': 'Perceived Stress Scale',
        'description': '10-item assessment for stress levels',
        'lastScore': 22,
        'previousScore': 18,
        'color': Colors.orange,
        'icon': Icons.warning,
        'severity': 'Moderate',
      },
    ];

    return Column(
      children: assessments.map((assessment) {
        final delta = (assessment['lastScore'] as int) -
            (assessment['previousScore'] as int);
        final trend = delta == 0
            ? 'No change'
            : delta < 0
                ? '${delta.abs()} â†“'
                : '$delta â†‘';
        final trendColor = delta < 0
            ? Colors.green
            : delta > 0
                ? Colors.red
                : Colors.grey;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (assessment['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  assessment['icon'] as IconData,
                  color: assessment['color'] as Color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${assessment['title']} - ${assessment['fullTitle']}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      assessment['description'] as String,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          'Score: ${assessment['lastScore']}',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: trendColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            trend,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: trendColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: (assessment['color'] as Color)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            assessment['severity'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: assessment['color'] as Color,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              FilledButton.tonal(
                onPressed: () {},
                child: const Text('Take'),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

