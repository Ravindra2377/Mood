import 'package:flutter/material.dart';

class TherapyToolboxCard extends StatelessWidget {
  const TherapyToolboxCard({super.key});

  @override
  Widget build(BuildContext context) {
    final tools = [
      {
        'title': 'Cognitive Behavioral Therapy (CBT)',
        'description':
            'Challenge negative thought patterns and develop healthier thinking habits',
        'color': Colors.blue,
        'tools': [
          'Thought Records',
          'Cognitive Restructuring',
          'Behavioral Experiments',
        ],
        'icon': Icons.psychology,
      },
      {
        'title': 'Dialectical Behavior Therapy (DBT)',
        'description':
            'Build skills for emotional regulation and interpersonal effectiveness',
        'color': Colors.purple,
        'tools': ['Mindfulness', 'Distress Tolerance', 'Emotion Regulation'],
        'icon': Icons.self_improvement,
      },
      {
        'title': 'Acceptance & Commitment Therapy (ACT)',
        'description':
            'Accept difficult thoughts and commit to value-driven actions',
        'color': Colors.green,
        'tools': ['Acceptance', 'Defusion', 'Values Clarification'],
        'icon': Icons.explore,
      },
    ];

    return Column(
      children: tools.map((tool) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: (tool['color'] as Color).withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: (tool['color'] as Color).withOpacity(0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    tool['icon'] as IconData,
                    color: tool['color'] as Color,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      tool['title'] as String,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: tool['color'] as Color,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                tool['description'] as String,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: (tool['tools'] as List<String>).map((toolName) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: (tool['color'] as Color).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      toolName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: tool['color'] as Color,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: tool['color'] as Color),
                  ),
                  child: Text(
                    'Explore ${tool['title'].toString().split(' ')[0]} Tools',
                    style: TextStyle(color: tool['color'] as Color),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

