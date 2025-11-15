import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class RecentActivityCard extends StatelessWidget {
  const RecentActivityCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // This would come from your state/database
    final activities = [
      _Activity(
        icon: '🫁',
        title: 'Completed Box Breathing',
        time: DateTime.now().subtract(Duration(minutes: 5)),
      ),
      _Activity(
        icon: '😊',
        title: 'Logged mood entry',
        time: DateTime.now().subtract(Duration(hours: 2)),
      ),
      _Activity(
        icon: '📚',
        title: 'Day 3 of Anxiety Reset',
        time: DateTime.now().subtract(Duration(hours: 5)),
        action: 'Continue',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        ...activities.map((activity) => _ActivityTile(activity: activity)),
      ],
    );
  }
}

class _Activity {
  final String icon;
  final String title;
  final DateTime time;
  final String? action;

  _Activity({
    required this.icon,
    required this.title,
    required this.time,
    this.action,
  });
}

class _ActivityTile extends StatelessWidget {
  final _Activity activity;

  const _ActivityTile({required this.activity});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(activity.icon, style: TextStyle(fontSize: 24)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    timeago.format(activity.time),
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (activity.action != null) ...[
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () {
                  // Handle action
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  activity.action!,
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}