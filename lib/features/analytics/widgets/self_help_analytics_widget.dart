import 'package:flutter/material.dart';
import '../../../models/analytics/analytics_models.dart';

class SelfHelpAnalyticsWidget extends StatelessWidget {
  final SelfHelpStats stats;

  const SelfHelpAnalyticsWidget({
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
                const Icon(Icons.psychology, color: Colors.purple),
                const SizedBox(width: 8),
                Text(
                  'Self-Help Activities',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStat('Total Activities', '${stats.totalActivities}', '✅'),
            _buildStat('Total Time', '${stats.totalTimeMinutes} min', '⏱️'),
            _buildStat('Thought Records', '${stats.thoughtRecordsCount}', '✍️'),
            _buildStat('Check-Ins', '${stats.checkInsCount}', '❤️'),
            _buildStat('Guided Programs', '${stats.guidedProgramsCount}', '🗺️'),
            _buildStat('Assessments', '${stats.assessmentsCount}', '📋'),
            const SizedBox(height: 16),
            Text(
              'Activity Breakdown:',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            ..._buildActivityBreakdown(),
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

  List<Widget> _buildActivityBreakdown() {
    return stats.activitiesByType.entries.map((entry) {
      final percentage = stats.totalActivities > 0
          ? ((entry.value / stats.totalActivities) * 100).toStringAsFixed(0)
          : '0';

      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Text(_getActivityIcon(entry.key)),
                  const SizedBox(width: 8),
                  Text(_formatActivityType(entry.key)),
                ],
              ),
            ),
            Text('${entry.value} ($percentage%)'),
          ],
        ),
      );
    }).toList();
  }

  String _getActivityIcon(String type) {
    switch (type) {
      case 'thought_record':
        return '✍️';
      case 'check_in':
        return '❤️';
      case 'pathway':
        return '🗺️';
      case 'assessment':
        return '📋';
      default:
        return '✨';
    }
  }

  String _formatActivityType(String type) {
    switch (type) {
      case 'thought_record':
        return 'Thought Records';
      case 'check_in':
        return 'Check-Ins';
      case 'pathway':
        return 'Guided Programs';
      case 'assessment':
        return 'Assessments';
      default:
        return type;
    }
  }
}