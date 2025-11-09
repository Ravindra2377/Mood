import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../models/self_help/self_help_models.dart';
import '../../self_help/utils/self_help_algorithms.dart';
import '../../self_help/controllers/self_help_controller.dart';

class PersonalizedPlanScreen extends ConsumerWidget {
  final UserAssessment? assessment;

  const PersonalizedPlanScreen({super.key, this.assessment});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use passed assessment or get from provider
    final AsyncValue<UserAssessment?> assessmentAsync = assessment != null
        ? AsyncValue.data(assessment)
        : ref.watch(latestAssessmentProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Personalized Plan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/self-help'),
        ),
      ),
      body: assessmentAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error loading plan: $error'),
        ),
        data: (assessment) {
          if (assessment == null) {
            return const Center(
              child: Text('No assessment found. Please complete a check-in first.'),
            );
          }

          final plan = SelfHelpAlgorithms.generatePlan(assessment);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.secondary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Personalized for You',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Based on your recent check-in, here\'s what we recommend:',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Urgent Actions
                if (plan.urgentActions.isNotEmpty) ...[
                  Text(
                    'Immediate Actions',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...plan.urgentActions.map((action) => _ActionCard(
                    title: action.toolName,
                    description: action.reason,
                    priority: ActionPriority.urgent,
                    onTap: () => _handleAction(context, action),
                  )),
                  const SizedBox(height: 24),
                ],

                // Recommended Tools
                if (plan.recommendedTools.isNotEmpty) ...[
                  Text(
                    'Recommended Tools',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...plan.recommendedTools.map((tool) => _ActionCard(
                    title: tool.toolName,
                    description: tool.reason,
                    priority: ActionPriority.normal,
                    onTap: () => _handleAction(context, tool),
                  )),
                  const SizedBox(height: 24),
                ],

                // Suggested Programs
                if (plan.suggestedPrograms.isNotEmpty) ...[
                  Text(
                    'Guided Programs',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...plan.suggestedPrograms.map((program) => _ProgramCard(
                    programId: program.programId,
                    reason: program.reason,
                    onTap: () => _handleProgramEnrollment(context, program.programId),
                  )),
                ],

                const SizedBox(height: 32),

                // Encouragement
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          size: 48,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Remember: Small steps lead to big changes',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'You\'re taking positive action toward better mental health.',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _handleAction(BuildContext context, RecommendedAction action) {
    // Navigate based on toolId
    switch (action.toolId) {
      case 'crisis_support':
        _showProfessionalHelpDialog(context);
        break;
      case 'box_breathing':
        context.go('/self-help/box-breathing');
        break;
      case '5_4_3_2_1_grounding':
        context.go('/self-help/grounding');
        break;
      case 'thought_record':
        context.go('/self-help/thought-record');
        break;
      case 'pmr_quick':
        context.go('/self-help/pmr');
        break;
      case 'behavioral_activation':
        context.go('/self-help/behavioral-activation');
        break;
      case 'gentle_yoga':
        context.go('/self-help/yoga');
        break;
      case 'sleep_hygiene':
        context.go('/self-help/sleep');
        break;
      case 'dbt_interpersonal':
        context.go('/self-help/interpersonal');
        break;
      case 'gratitude_journal':
        context.go('/self-help/journal');
        break;
      default:
        // Show tool details or fallback
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tool: ${action.toolName}')),
        );
        break;
    }
  }

  void _handleProgramEnrollment(BuildContext context, String programId) {
    // Navigate to program details/enrollment
    context.go('/self-help/programs/$programId');
  }

  void _showProfessionalHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Professional Help'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('If you\'re in crisis or need immediate help:'),
            SizedBox(height: 8),
            Text('• Call emergency services (911)'),
            Text('• National Suicide Prevention Lifeline: 988'),
            Text('• Crisis Text Line: Text HOME to 741741'),
            SizedBox(height: 16),
            Text('For ongoing support, consider speaking with a mental health professional.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

}

class _ActionCard extends StatelessWidget {
  final String title;
  final String description;
  final ActionPriority priority;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.description,
    required this.priority,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = priority == ActionPriority.urgent
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.primary;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgramCard extends StatelessWidget {
  final String programId;
  final String reason;
  final VoidCallback onTap;

  const _ProgramCard({
    required this.programId,
    required this.reason,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.school,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _getProgramName(programId),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                reason,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getProgramName(String programId) {
    final programNames = {
      'anxiety_management': 'Anxiety Management',
      'sleep_hygiene': 'Sleep Hygiene',
      'depression_management': 'Depression Management',
      'stress_reduction': 'Stress Reduction',
      'mindfulness_practice': 'Mindfulness Practice',
      'cognitive_restructuring': 'Cognitive Restructuring',
    };
    return programNames[programId] ?? programId;
  }
}