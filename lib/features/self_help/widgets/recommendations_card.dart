import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/self_help/self_help_models.dart';
import '../controllers/self_help_controller.dart';

class RecommendationsCard extends ConsumerWidget {
  const RecommendationsCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(personalizedPlanProvider);

    if (plan == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Smart Recommendations',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(width: 8),
            Text('💡', style: TextStyle(fontSize: 20)),
          ],
        ),
        Text(
          'Based on your recent patterns',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
        ),
        const SizedBox(height: 12),
        
        // Urgent actions
        if (plan.urgentActions.isNotEmpty) ...[
          ...plan.urgentActions.map((action) => _RecommendationCard(
                action: action,
                isUrgent: true,
              )),
          const SizedBox(height: 8),
        ],

        // Regular recommendations
        if (plan.recommendedTools.isNotEmpty) ...[
          ...plan.recommendedTools.take(2).map((action) => _RecommendationCard(
                action: action,
                isUrgent: false,
              )),
        ],
      ],
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final RecommendedAction action;
  final bool isUrgent;

  const _RecommendationCard({
    required this.action,
    required this.isUrgent,
  });

  @override
  Widget build(BuildContext context) {
    final color = isUrgent ? Colors.red : Colors.blue;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // Navigate to tool
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isUrgent ? Icons.warning_amber_rounded : Icons.lightbulb_outline,
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            action.toolName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${action.estimatedDuration} min',
                            style: TextStyle(
                              fontSize: 12,
                              color: color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      action.reason,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}