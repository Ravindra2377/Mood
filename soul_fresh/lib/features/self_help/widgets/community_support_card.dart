import 'package:flutter/material.dart';

class CommunitySupportCard extends StatelessWidget {
  const CommunitySupportCard({super.key});

  @override
  Widget build(BuildContext context) {
    final supportGroups = [
      {
        'name': 'Anxiety Support Circle',
        'description':
            'Connect with others managing anxiety and share coping strategies',
        'members': 1247,
        'isActive': true,
        'color': Colors.blue,
        'icon': Icons.group,
      },
      {
        'name': 'Depression Warriors',
        'description':
            'A supportive community for those experiencing depression',
        'members': 2156,
        'isActive': true,
        'color': Colors.purple,
        'icon': Icons.healing,
      },
      {
        'name': 'Stress Management Hub',
        'description': 'Learn and share techniques for managing daily stress',
        'members': 892,
        'isActive': false,
        'color': Colors.orange,
        'icon': Icons.self_improvement,
      },
      {
        'name': 'Sleep Struggles Support',
        'description': 'Connect with others working on better sleep habits',
        'members': 634,
        'isActive': true,
        'color': Colors.indigo,
        'icon': Icons.nightlight,
      },
    ];

    return Column(
      children: supportGroups.map((group) {
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (group['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      group['icon'] as IconData,
                      color: group['color'] as Color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                group['name'] as String,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                            if (group['isActive'] as bool)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Active',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          group['description'] as String,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.people,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${group['members']} members â€¢ Anonymous & moderated',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          textStyle: const TextStyle(fontSize: 12),
                        ),
                        child: const Text('View posts'),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          textStyle: const TextStyle(fontSize: 12),
                        ),
                        child: const Text('Share story'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

