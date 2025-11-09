import 'package:flutter/material.dart';

class CrisisSupportCard extends StatelessWidget {
  const CrisisSupportCard({super.key});

  @override
  Widget build(BuildContext context) {
    final crisisContacts = [
      {
        'title': '988 Suicide & Crisis Lifeline',
        'description': '24/7 free and confidential support',
        'number': '988',
        'color': Colors.red,
        'icon': Icons.phone,
        'action': 'Call now',
      },
      {
        'title': 'Crisis Text Line',
        'description': 'Text HOME to connect with a crisis counselor',
        'number': 'HOME',
        'color': Colors.blue,
        'icon': Icons.textsms,
        'action': 'Text HOME',
      },
      {
        'title': 'National Domestic Violence Hotline',
        'description': 'Support for domestic violence survivors',
        'number': '1-800-799-7233',
        'color': Colors.purple,
        'icon': Icons.shield,
        'action': 'Call now',
      },
      {
        'title': 'LGBTQ+ Crisis Hotline',
        'description': 'Peer support for LGBTQ+ individuals',
        'number': '1-888-843-4564',
        'color': Colors.pink,
        'icon': Icons.flag,
        'action': 'Call now',
      },
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('ðŸ†˜', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Text(
                'Crisis Support',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'If you are in immediate danger, call emergency services (911). These resources provide 24/7 confidential support.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.red.shade600,
                  height: 1.5,
                ),
          ),
          const SizedBox(height: 24),
          ...crisisContacts.map((contact) {
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: (contact['color'] as Color).withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        contact['icon'] as IconData,
                        color: contact['color'] as Color,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          contact['title'] as String,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    contact['description'] as String,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        contact['number'] as String,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: contact['color'] as Color,
                                  fontFamily: 'monospace',
                                ),
                      ),
                      const Spacer(),
                      FilledButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Opening ${contact['action']}...'),
                              backgroundColor: contact['color'] as Color,
                            ),
                          );
                        },
                        icon: Icon(contact['icon'] as IconData, size: 16),
                        label: Text(contact['action'] as String),
                        style: FilledButton.styleFrom(
                          backgroundColor: contact['color'] as Color,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Safety Plan',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Warning signs â€¢ Coping strategies â€¢ People to contact',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Review your plan'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

