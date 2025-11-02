import 'package:flutter/material.dart';

class ResourcesLibraryCard extends StatelessWidget {
  const ResourcesLibraryCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ResourceTile(
          initial: 'A',
          title: 'Understanding Anxiety Loops',
          type: 'Article • 8 min read',
          rating: '4.9',
          onTap: () {},
        ),
        const SizedBox(height: 12),
        _ResourceTile(
          initial: 'V',
          title: 'CBT Thought Challenging Demo',
          type: 'Video • 12 min',
          rating: '4.8',
          onTap: () {},
        ),
        const SizedBox(height: 12),
        _ResourceTile(
          initial: 'W',
          title: 'Sleep Ritual Planner (PDF)',
          type: 'Worksheet • Download',
          rating: '4.7',
          onTap: () {},
        ),
      ],
    );
  }
}

class _ResourceTile extends StatelessWidget {
  final String initial;
  final String title;
  final String type;
  final String rating;
  final VoidCallback onTap;

  const _ResourceTile({
    required this.initial,
    required this.title,
    required this.type,
    required this.rating,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue,
          child: Text(
            initial,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Row(
          children: [
            Text(type),
            const SizedBox(width: 12),
            const Icon(Icons.star, size: 14, color: Colors.orange),
            Text(rating, style: const TextStyle(fontSize: 12)),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}