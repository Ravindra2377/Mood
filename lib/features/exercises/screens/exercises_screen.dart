import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/custom_widgets.dart';

class ExercisesScreen extends StatelessWidget {
  const ExercisesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Mint Gradient Header
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.mintGradient,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Mindfulness Exercises',
                      style: AppTypography.h2.copyWith(
                        color: AppColors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Find peace and calm with guided exercises',
                      style: AppTypography.body1.copyWith(
                        color: AppColors.white.withOpacity(0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Quick Stats
                Row(
                  children: [
                    _buildStatCard('Today\'s\nSessions', '3', Icons.self_improvement),
                    const SizedBox(width: 12),
                    _buildStatCard('Total\nMinutes', '45', Icons.timer),
                  ],
                ),
                const SizedBox(height: 32),

                // Exercise Categories
                Text(
                  'Choose an Exercise',
                  style: AppTypography.h4.copyWith(
                    color: AppColors.charcoal,
                  ),
                ),
                const SizedBox(height: 16),
                _buildExerciseCategories(),
                const SizedBox(height: 32),

                // Recommended for You
                Text(
                  'Recommended for You',
                  style: AppTypography.h4.copyWith(
                    color: AppColors.charcoal,
                  ),
                ),
                const SizedBox(height: 16),
                _buildRecommendedExercises(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Expanded(
      child: CustomCard(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE8F5E8), Color(0xFFF1F8E9)],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: AppColors.success,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTypography.h3.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              title,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.darkGrey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseCategories() {
    final categories = [
      {
        'title': 'Breathing Exercises',
        'subtitle': '4-7-8, Box breathing, and more',
        'icon': Icons.air,
        'color': AppColors.calmPastel,
        'exercises': 8,
      },
      {
        'title': 'Relaxation Techniques',
        'subtitle': 'Progressive muscle relaxation',
        'icon': Icons.spa,
        'color': AppColors.secondaryPastel,
        'exercises': 6,
      },
      {
        'title': 'Grounding Exercises',
        'subtitle': '5-4-3-2-1 and sensory awareness',
        'icon': Icons.psychology,
        'color': AppColors.coolPastel,
        'exercises': 5,
      },
      {
        'title': 'Mindfulness Practices',
        'subtitle': 'Meditation and body scans',
        'icon': Icons.self_improvement,
        'color': AppColors.warmPastel,
        'exercises': 7,
      },
    ];

    return Column(
      children: categories.map((category) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: CustomCard(
            onTap: () => _navigateToCategory(category['title'] as String),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: category['color'] as Color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    category['icon'] as IconData,
                    color: AppColors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category['title'] as String,
                        style: AppTypography.h4.copyWith(
                          color: AppColors.charcoal,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        category['subtitle'] as String,
                        style: AppTypography.body2.copyWith(
                          color: AppColors.mediumGrey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildBadge('${category['exercises']} exercises', AppColors.primaryPastel),
                          const SizedBox(width: 8),
                          _buildBadge('5-15 min', AppColors.secondaryPastel),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: AppColors.mediumGrey,
                  size: 28,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecommendedExercises() {
    final exercises = [
      {
        'title': '4-7-8 Breathing',
        'duration': '4 min',
        'difficulty': 'Beginner',
        'color': AppColors.calmPastel,
      },
      {
        'title': 'Body Scan Meditation',
        'duration': '10 min',
        'difficulty': 'Intermediate',
        'color': AppColors.secondaryPastel,
      },
      {
        'title': '5-4-3-2-1 Grounding',
        'duration': '3 min',
        'difficulty': 'Beginner',
        'color': AppColors.coolPastel,
      },
    ];

    return Column(
      children: exercises.map((exercise) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: CustomCard(
            onTap: () => _startExercise(exercise['title'] as String),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: exercise['color'] as Color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.play_arrow,
                    color: AppColors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise['title'] as String,
                        style: AppTypography.body1.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.charcoal,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _buildBadge(exercise['duration'] as String, AppColors.primaryPastel),
                          const SizedBox(width: 8),
                          _buildBadge(exercise['difficulty'] as String,
                            (exercise['difficulty'] == 'Beginner')
                                ? AppColors.success
                                : AppColors.warning,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.favorite_border,
                  color: AppColors.mediumGrey,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Text(
        text,
        style: AppTypography.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _navigateToCategory(String category) {
    // In a real app, this would navigate to a category screen
    // For now, just show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Opening $category...',
          style: AppTypography.body2.copyWith(color: AppColors.white),
        ),
        backgroundColor: AppColors.primaryPastel,
      ),
    );
  }

  void _startExercise(String exercise) {
    // In a real app, this would start the exercise
    // For now, just show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Starting $exercise...',
          style: AppTypography.body2.copyWith(color: AppColors.white),
        ),
        backgroundColor: AppColors.secondaryPastel,
      ),
    );
  }
}