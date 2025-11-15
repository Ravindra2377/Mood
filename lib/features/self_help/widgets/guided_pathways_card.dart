import 'package:flutter/material.dart';

class GuidedPathwaysCard extends StatelessWidget {
  const GuidedPathwaysCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _PathwayCard(
            title: '7-Day\nAnxiety Reset',
            progress: 3,
            totalDays: 7,
            percentage: 43,
            color: Colors.blue,
            emoji: '😰',
          ),
          const SizedBox(width: 12),
          _PathwayCard(
            title: '14-Day\nSleep Restoration',
            progress: 5,
            totalDays: 14,
            percentage: 36,
            color: Colors.purple,
            emoji: '😴',
          ),
          const SizedBox(width: 12),
          _PathwayCard(
            title: '10-Day\nSelf-Esteem',
            progress: 0,
            totalDays: 10,
            percentage: 0,
            color: Colors.pink,
            emoji: '✨',
          ),
        ],
      ),
    );
  }
}

class _PathwayCard extends StatelessWidget {
  final String title;
  final int progress;
  final int totalDays;
  final int percentage;
  final Color color;
  final String emoji;

  const _PathwayCard({
    required this.title,
    required this.progress,
    required this.totalDays,
    required this.percentage,
    required this.color,
    required this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 24)),
              Text(
                '$percentage%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 6,
              backgroundColor: color.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Day $progress of $totalDays',
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(
                  color: Colors.grey,
                ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: color),
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
              child: Text(
                'Continue',
                style: TextStyle(color: color, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}