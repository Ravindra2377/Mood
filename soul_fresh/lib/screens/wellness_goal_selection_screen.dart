import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soul_fresh/config/app_colors.dart';

// Model for goal category
class GoalCategory {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final Color accentColor;
  final List<String> benefits;

  GoalCategory({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.accentColor,
    required this.benefits,
  });
}

// Provider for selected goals
final selectedGoalsProvider = StateProvider<Set<String>>((ref) => {});

class WellnessGoalSelectionScreen extends ConsumerStatefulWidget {
  final VoidCallback onComplete;

  const WellnessGoalSelectionScreen({
    Key? key,
    required this.onComplete,
  }) : super(key: key);

  @override
  ConsumerState<WellnessGoalSelectionScreen> createState() =>
      _WellnessGoalSelectionScreenState();
}

class _WellnessGoalSelectionScreenState
    extends ConsumerState<WellnessGoalSelectionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  final List<GoalCategory> goalCategories = [
    GoalCategory(
      id: 'managing_stress',
      title: 'Managing Stress',
      description: 'Track and reduce stress with guided exercises',
      emoji: '😰',
      accentColor: const Color(0xFFFF6B6B),
      benefits: [
        'Daily stress tracking',
        'Breathing exercises',
        'Stress relief techniques',
        'Trigger identification',
      ],
    ),
    GoalCategory(
      id: 'improving_mood',
      title: 'Improving Mood',
      description: 'Boost your mood with activities and gratitude',
      emoji: '😊',
      accentColor: const Color(0xFFFFD93D),
      benefits: [
        'Mood tracking dashboard',
        'Activity recommendations',
        'Gratitude journal',
        'Positive affirmations',
      ],
    ),
    GoalCategory(
      id: 'better_sleep',
      title: 'Better Sleep',
      description: 'Improve sleep quality and duration',
      emoji: '😴',
      accentColor: const Color(0xFF6C5CE7),
      benefits: [
        'Sleep tracking',
        'Sleep hygiene tips',
        'Bedtime meditation',
        'Sleep analysis',
      ],
    ),
    GoalCategory(
      id: 'mindfulness',
      title: 'Mindfulness Practice',
      description: 'Build a consistent meditation habit',
      emoji: '🧘',
      accentColor: const Color(0xFF00B894),
      benefits: [
        'Guided meditations',
        'Streak tracking',
        'Progress achievements',
        'Multiple meditation types',
      ],
    ),
    GoalCategory(
      id: 'coping_anxiety',
      title: 'Coping with Anxiety',
      description: 'Learn coping techniques and manage anxiety',
      emoji: '😰',
      accentColor: const Color(0xFFFF7675),
      benefits: [
        'Anxiety tracking',
        'Coping techniques',
        'Grounding exercises',
        'Safety planning',
      ],
    ),
    GoalCategory(
      id: 'general_wellness',
      title: 'General Wellness',
      description: 'Holistic health and lifestyle tracking',
      emoji: '🌟',
      accentColor: const Color(0xFF74B9FF),
      benefits: [
        'Wellness score',
        'Lifestyle logging',
        'Goal tracking',
        'Comprehensive insights',
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedGoals = ref.watch(selectedGoalsProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        title: const Text(
          'Your Wellness Journey',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textColor,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Header with description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select areas you want to focus on:',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.secondaryText,
                      ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.borderColor,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '💡 Tip: You can change these anytime in settings',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.primaryColor,
                        ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Goal cards grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemCount: goalCategories.length,
              itemBuilder: (context, index) {
                final goal = goalCategories[index];
                final isSelected = selectedGoals.contains(goal.id);

                return _GoalCard(
                  goal: goal,
                  isSelected: isSelected,
                  onTap: () {
                    final newSelection = Set<String>.from(selectedGoals);
                    if (isSelected) {
                      newSelection.remove(goal.id);
                    } else {
                      newSelection.add(goal.id);
                    }
                    ref.read(selectedGoalsProvider.notifier).state = newSelection;
                  },
                  animationController: _animationController,
                  index: index,
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          // Continue button
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: selectedGoals.isNotEmpty
                      ? () {
                          // Save selection and continue
                          widget.onComplete();
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    disabledBackgroundColor: AppColors.primaryColor.withOpacity(0.5),
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 32,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Continue with ${selectedGoals.length} goal${selectedGoals.length != 1 ? 's' : ''}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, color: Colors.white),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Skip for now',
                    style: TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final GoalCategory goal;
  final bool isSelected;
  final VoidCallback onTap;
  final AnimationController animationController;
  final int index;

  const _GoalCard({
    Key? key,
    required this.goal,
    required this.isSelected,
    required this.onTap,
    required this.animationController,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Interval(
          index * 0.1,
          (index * 0.1) + 0.6,
          curve: Curves.easeOut,
        ),
      ),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8 + (animation.value * 0.2),
          child: Opacity(
            opacity: 0.2 + (animation.value * 0.8),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? goal.accentColor.withOpacity(0.15)
                : AppColors.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? goal.accentColor : AppColors.borderColor,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: goal.accentColor.withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with emoji and checkmark
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    goal.emoji,
                    style: const TextStyle(fontSize: 32),
                  ),
                  if (isSelected)
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: goal.accentColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              // Title and description
              Text(
                goal.title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                goal.description,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.secondaryText,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              // Benefits badges
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: goal.benefits.take(2).map((benefit) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: goal.accentColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      benefit,
                      style: TextStyle(
                        fontSize: 9,
                        color: goal.accentColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      ),
    );
  }
}
