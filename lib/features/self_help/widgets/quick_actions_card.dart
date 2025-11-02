import 'package:flutter/material.dart';

class QuickActionsCard extends StatelessWidget {
  const QuickActionsCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose Your Path',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _QuickActionButton(
              icon: Icons.build_outlined,
              title: 'Interactive\nToolkit',
              color: Colors.blue,
              onTap: () {
                // Navigate to toolkit
              },
            ),
            _QuickActionButton(
              icon: Icons.map_outlined,
              title: 'Guided\nPrograms',
              color: Colors.purple,
              onTap: () {
                // Navigate to programs
              },
            ),
            _QuickActionButton(
              icon: Icons.library_books_outlined,
              title: 'Resource\nLibrary',
              color: Colors.teal,
              onTap: () {
                // Navigate to resources
              },
            ),
            _QuickActionButton(
              icon: Icons.warning_amber_rounded,
              title: 'Crisis\nSupport',
              color: Colors.red,
              onTap: () {
                // Navigate to crisis support
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: color.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}