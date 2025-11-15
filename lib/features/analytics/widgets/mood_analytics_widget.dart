import 'package:flutter/material.dart';
import '../../../models/analytics/analytics_models.dart';

class MoodAnalyticsWidget extends StatelessWidget {
  final MoodStats stats;

  const MoodAnalyticsWidget({
    Key? key,
    required this.stats,
  }) : super(key: key);

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
                const Icon(Icons.mood, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  'Mood Summary',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStat('Weekly Average', '${stats.weeklyAverageMood.toStringAsFixed(1)}/10', '📊'),
            _buildStat('Mood Trend', _formatTrend(stats.moodTrend), _getTrendIcon(stats.moodTrend)),
            _buildStat('Common State', stats.mostCommonEmotionalState, '🎯'),
            const SizedBox(height: 16),
            Text(
              'Top Triggers:',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            ...stats.topTriggers.map((trigger) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  const Text('→'),
                  const SizedBox(width: 8),
                  Text(trigger),
                ],
              ),
            )),
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

  String _formatTrend(double trend) {
    if (trend > 0) {
      return '+${trend.toStringAsFixed(1)}';
    }
    return trend.toStringAsFixed(1);
  }

  String _getTrendIcon(double trend) {
    if (trend > 0) {
      return '📈';
    } else if (trend < 0) {
      return '📉';
    }
    return '➡️';
  }
}