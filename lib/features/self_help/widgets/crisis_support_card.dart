import 'package:flutter/material.dart';

class CrisisSupportCard extends StatelessWidget {
  const CrisisSupportCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.warning, color: Colors.red, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                'Crisis Support',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'If you\'re in immediate danger, call emergency services.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  icon: const Icon(Icons.call),
                  label: const Text('988'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  icon: const Icon(Icons.message),
                  label: const Text('Text HOME'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}