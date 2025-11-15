import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shell/providers/main_screen_index_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    void navigateToTab(int index) {
      ref.read(mainScreenIndexProvider.notifier).state = index;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Good morning'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => navigateToTab(3),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How are you feeling today?',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            const _MoodTrackerCard(),
            const SizedBox(height: 28),
            Text(
              'Your tools',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            _ActionCard(
              title: 'Write in journal',
              subtitle: 'Reflect on your day and clear your mind.',
              icon: Icons.auto_stories_outlined,
              backgroundColor: theme.colorScheme.primaryContainer,
              foregroundColor: theme.colorScheme.onPrimaryContainer,
              onTap: () => navigateToTab(1),
            ),
            const SizedBox(height: 12),
            _ActionCard(
              title: 'AI companion',
              subtitle: 'Talk through your feelings with a guide.',
              icon: Icons.chat_bubble_outline,
              backgroundColor: theme.colorScheme.secondaryContainer,
              foregroundColor: theme.colorScheme.onSecondaryContainer,
              onTap: () => navigateToTab(2),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: backgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(icon, size: 30, color: foregroundColor),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: foregroundColor,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: foregroundColor.withOpacity(0.8),
                          ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: foregroundColor),
            ],
          ),
        ),
      ),
    );
  }
}

class _MoodTrackerCard extends StatelessWidget {
  const _MoodTrackerCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: theme.colorScheme.surfaceVariant,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const [
            Icon(Icons.sentiment_very_dissatisfied, size: 36),
            Icon(Icons.sentiment_dissatisfied, size: 36),
            Icon(Icons.sentiment_neutral, size: 36),
            Icon(Icons.sentiment_satisfied, size: 36),
            Icon(Icons.sentiment_very_satisfied, size: 36),
          ],
        ),
      ),
    );
  }
}
