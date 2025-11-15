import 'package:flutter/material.dart';

class AssessmentsCard extends StatelessWidget {
  const AssessmentsCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _AssessmentTile(
          title: 'GAD-7 Anxiety Check',
          subtitle: '7 questions • Clinically validated',
          score: '12 • 3 ↓',
          onTap: () {},
        ),
        const SizedBox(height: 12),
        _AssessmentTile(
          title: 'PHQ-9 Mood Check',
          subtitle: 'Monitor depressive symptoms',
          score: '9 • 2 ↓',
          onTap: () {},
        ),
        const SizedBox(height: 12),
        _AssessmentTile(
          title: 'Perceived Stress Scale',
          subtitle: '10 questions • Daily stress',
          score: '18 • 5 ↓',
          onTap: () {},
        ),
      ],
    );
  }
}

class _AssessmentTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String score;
  final VoidCallback onTap;

  const _AssessmentTile({
    required this.title,
    required this.subtitle,
    required this.score,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.assessment, color: Colors.blue),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          child: const Text('Take'),
        ),
      ),
    );
  }
}