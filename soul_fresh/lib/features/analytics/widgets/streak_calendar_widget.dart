import 'package:flutter/material.dart';

class StreakCalendarWidget extends StatelessWidget {
  const StreakCalendarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ðŸ“… Activity Streak',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '7 days',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Simple 7-day calendar view
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildDayCircle('M', true),
                _buildDayCircle('T', true),
                _buildDayCircle('W', true),
                _buildDayCircle('T', true),
                _buildDayCircle('F', true),
                _buildDayCircle('S', true),
                _buildDayCircle('S', false),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLegend(Colors.orange, 'Active'),
                _buildLegend(Colors.grey.shade300, 'Inactive'),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Keep it up! You\'re building healthy habits ðŸ’ª',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayCircle(String day, bool isActive) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isActive ? Colors.orange : Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              day,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey.shade600,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          day,
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildLegend(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11),
        ),
      ],
    );
  }
}

