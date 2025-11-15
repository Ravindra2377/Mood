import 'package:flutter/material.dart';

class WeeklyInsightsCard extends StatelessWidget {
  const WeeklyInsightsCard({super.key});

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
                const Icon(Icons.insights, color: Colors.purple),
                const SizedBox(width: 8),
                Text(
                  'Weekly Insights',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.purple.withOpacity(0.1),
                    Colors.blue.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('ðŸŽ¯', style: TextStyle(fontSize: 24)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'This Week\'s Progress',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInsightItem(
                    'Most Active Day',
                    'Wednesday - 4 activities completed',
                    Icons.calendar_today,
                  ),
                  const SizedBox(height: 8),
                  _buildInsightItem(
                    'Best Exercise',
                    'Box Breathing - practiced 3 times',
                    Icons.self_improvement,
                  ),
                  const SizedBox(height: 8),
                  _buildInsightItem(
                    'Mood Improvement',
                    '+15% better than last week',
                    Icons.trending_up,
                  ),
                  const SizedBox(height: 8),
                  _buildInsightItem(
                    'Consistency',
                    'Active 5 out of 7 days',
                    Icons.check_circle,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.emoji_events, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Achievement Unlocked: "Consistent Practitioner" - 5 active days!',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '$label: ',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

