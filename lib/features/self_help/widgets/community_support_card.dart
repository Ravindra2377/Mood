import 'package:flutter/material.dart';

class CommunitySupportCard extends StatelessWidget {
  const CommunitySupportCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _CommunityGroup(
          title: 'Anxiety Warriors',
          description: 'Share wins and setbacks with people who truly get it.',
          members: '8.4k members',
          onTap: () {},
        ),
        const SizedBox(height: 12),
        _CommunityGroup(
          title: 'Sleep Better Collective',
          description: 'Trade routines, hacks, and encouragement for better rest.',
          members: '12.3k members',
          onTap: () {},
        ),
      ],
    );
  }
}

class _CommunityGroup extends StatelessWidget {
  final String title;
  final String description;
  final String members;
  final VoidCallback onTap;

  const _CommunityGroup({
    required this.title,
    required this.description,
    required this.members,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  members,
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: Colors.grey),
                ),
                ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 8),
                  ),
                  child: const Text('View'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}