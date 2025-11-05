import 'package:flutter/material.dart';
import '../../../models/analytics/analytics_models.dart';

class ExerciseAnalyticsWidget extends StatelessWidget {
  final ExerciseStats stats;

  const ExerciseAnalyticsWidget({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.self_improvement, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Exercise Summary',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStat('Total Sessions', '${stats.totalSessions}', '📊'),
            _buildStat('Total Time', '${stats.totalTimeMinutes} min', '⏱️'),
            _buildStat('Avg Duration', '${stats.averageSessionDuration.toStringAsFixed(1)} min', '📈'),
            _buildStat('Mood Improvement', '${stats.averageMoodImprovement.toStringAsFixed(1)} pts', '😊'),
            _buildStat('Most Effective', stats.mostEffectiveExercise, '⭐'),
            const SizedBox(height: 16),
            Text(
              'By Category:',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            ...stats.sessionsByCategory.entries.map((entry) =>
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Text('${_getCategoryIcon(entry.key)} ${entry.key}'),
                    const Spacer(),
                    Text('${entry.value}'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value, String icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(icon),
              const SizedBox(width: 8),
              Text(label),
            ],
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  String _getCategoryIcon(String category) {
    switch (category) {
      case 'breathing':
        return '🫁';
      case 'pmr':
        return '💪';
      case 'grounding':
        return '🌍';
      case 'cognitive':
        return '🧠';
      case 'journaling':
        return '📝';
      default:
        return '✨';
    }
  }
}

