import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/custom_card.dart';
import '../providers/analytics_provider.dart';

class UnifiedAnalyticsScreen extends ConsumerWidget {
  const UnifiedAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Multi-color Gradient Header
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFE6D5F0), // Lavender
                      Color(0xFFD4F7EE), // Mint
                      Color(0xFFFFE5B4), // Peach
                      Color(0xFFBBCEFF), // Periwinkle
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Your Wellness Journey',
                      style: AppTypography.h2.copyWith(
                        color: AppColors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Track your progress and insights',
                      style: AppTypography.body1.copyWith(
                        color: AppColors.white.withValues(alpha: 0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.share,
                  color: AppColors.white,
                ),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(
                  Icons.download,
                  color: AppColors.white,
                ),
                onPressed: () {},
              ),
            ],
          ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Wellness Score Display
                _buildWellnessScore(ref),
                const SizedBox(height: 32),

                // Key Metrics Row
                _buildKeyMetrics(ref),
                const SizedBox(height: 32),

                // Mood Trends
                Text(
                  'Mood Trends',
                  style: AppTypography.h4.copyWith(
                    color: AppColors.charcoal,
                  ),
                ),
                const SizedBox(height: 16),
                _buildMoodTrends(),
                const SizedBox(height: 32),

                // Exercise Stats
                Text(
                  'Exercise Activity',
                  style: AppTypography.h4.copyWith(
                    color: AppColors.charcoal,
                  ),
                ),
                const SizedBox(height: 16),
                _buildExerciseStats(),
                const SizedBox(height: 32),

                // Achievements
                Text(
                  'Achievements',
                  style: AppTypography.h4.copyWith(
                    color: AppColors.charcoal,
                  ),
                ),
                const SizedBox(height: 16),
                _buildAchievements(),
                const SizedBox(height: 32),

                // Weekly Summary
                _buildWeeklySummary(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWellnessScore(WidgetRef ref) {
    final analyticsAsync = ref.watch(analyticsSnapshotProvider);

    return analyticsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
      data: (snapshot) => CustomCard(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Overall Wellness Score',
                      style: AppTypography.h3.copyWith(
                        color: AppColors.charcoal,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Last 7 days',
                      style: AppTypography.body2.copyWith(
                        color: AppColors.mediumGrey,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '+12%',
                    style: AppTypography.label.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 140,
                  height: 140,
                  child: CircularProgressIndicator(
                    value: snapshot.wellnessScore / 100,
                    strokeWidth: 14,
                    backgroundColor: AppColors.lightGrey,
                    valueColor: const AlwaysStoppedAnimation(AppColors.primaryPastel),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  children: [
                    Text(
                      '${snapshot.wellnessScore}',
                      style: AppTypography.h1.copyWith(
                        color: AppColors.charcoal,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      '/100',
                      style: AppTypography.body1.copyWith(
                        color: AppColors.mediumGrey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'You\'re doing great! Keep up the good work 🎉',
              style: AppTypography.body1.copyWith(
                color: AppColors.charcoal,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyMetrics(WidgetRef ref) {
    final analyticsAsync = ref.watch(analyticsSnapshotProvider);

    return analyticsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
      data: (snapshot) => Row(
        children: [
          {
            'label': 'Mood Entries',
            'value': '${snapshot.moodStats.entries.length}',
            'change': '+12%',
            'icon': Icons.mood,
            'color': AppColors.happyPastel,
          },
          {
            'label': 'Exercises Done',
            'value': '${snapshot.exerciseStats.totalSessions}',
            'change': '+8%',
            'icon': Icons.fitness_center,
            'color': AppColors.secondaryPastel,
          },
          {
            'label': 'Self-Help Tools',
            'value': '${snapshot.selfHelpStats.totalActivities}',
            'change': '+25%',
            'icon': Icons.psychology,
            'color': AppColors.primaryPastel,
          },
          {
            'label': 'Streak Days',
            'value': '${snapshot.currentStreak}',
            'change': 'New!',
            'icon': Icons.local_fire_department,
            'color': AppColors.energyPastel,
          },
        ].map((metric) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: CustomCard(
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: metric['color'] as Color,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        metric['icon'] as IconData,
                        color: AppColors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      metric['value'] as String,
                      style: AppTypography.h3.copyWith(
                        color: AppColors.charcoal,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      metric['label'] as String,
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.mediumGrey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        metric['change'] as String,
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMoodTrends() {
    final moodData = [
      {'day': 'Mon', 'mood': 'Happy', 'emoji': '😊', 'score': 8},
      {'day': 'Tue', 'mood': 'Calm', 'emoji': '😌', 'score': 7},
      {'day': 'Wed', 'mood': 'Anxious', 'emoji': '😰', 'score': 4},
      {'day': 'Thu', 'mood': 'Happy', 'emoji': '😊', 'score': 9},
      {'day': 'Fri', 'mood': 'Calm', 'emoji': '😌', 'score': 8},
      {'day': 'Sat', 'mood': 'Happy', 'emoji': '😊', 'score': 9},
      {'day': 'Sun', 'mood': 'Happy', 'emoji': '😊', 'score': 8},
    ];

    return CustomCard(
      child: Column(
        children: [
          SizedBox(
            height: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: moodData.map((data) {
                final height = (data['score'] as int) * 10.0;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      data['emoji'] as String,
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 30,
                      height: height,
                      decoration: BoxDecoration(
                        color: _getMoodColor(data['mood'] as String),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data['day'] as String,
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.mediumGrey,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildMoodLegend('Happy', AppColors.happyPastel),
              const SizedBox(width: 16),
              _buildMoodLegend('Calm', AppColors.calmPastel),
              const SizedBox(width: 16),
              _buildMoodLegend('Anxious', AppColors.anxiousPastel),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMoodLegend(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.darkGrey,
          ),
        ),
      ],
    );
  }

  Color _getMoodColor(String mood) {
    switch (mood) {
      case 'Happy':
        return AppColors.happyPastel;
      case 'Calm':
        return AppColors.calmPastel;
      case 'Anxious':
        return AppColors.anxiousPastel;
      case 'Sad':
        return AppColors.sadPastel;
      default:
        return AppColors.mediumGrey;
    }
  }

  Widget _buildExerciseStats() {
    final exerciseStats = [
      {'name': 'Breathing', 'count': 8, 'color': AppColors.calmPastel},
      {'name': 'Meditation', 'count': 5, 'color': AppColors.secondaryPastel},
      {'name': 'Grounding', 'count': 3, 'color': AppColors.coolPastel},
      {'name': 'Relaxation', 'count': 2, 'color': AppColors.warmPastel},
    ];

    return CustomCard(
      child: Column(
        children: exerciseStats.map((stat) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: stat['color'] as Color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.fitness_center,
                    color: AppColors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    stat['name'] as String,
                    style: AppTypography.body1.copyWith(
                      color: AppColors.charcoal,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: (stat['color'] as Color).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${stat['count']} sessions',
                    style: AppTypography.label.copyWith(
                      color: stat['color'] as Color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAchievements() {
    final achievements = [
      {
        'title': 'First Week Streak',
        'description': 'Logged mood for 7 days straight',
        'icon': Icons.local_fire_department,
        'color': AppColors.energyPastel,
        'earned': true,
      },
      {
        'title': 'Mindfulness Master',
        'description': 'Completed 10 meditation sessions',
        'icon': Icons.self_improvement,
        'color': AppColors.secondaryPastel,
        'earned': true,
      },
      {
        'title': 'Breathing Expert',
        'description': 'Practiced breathing exercises 15 times',
        'icon': Icons.air,
        'color': AppColors.calmPastel,
        'earned': false,
      },
      {
        'title': 'Wellness Warrior',
        'description': 'Maintained wellness score above 75%',
        'icon': Icons.star,
        'color': AppColors.accentPastel,
        'earned': false,
      },
    ];

    return Column(
      children: achievements.map((achievement) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: CustomCard(
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: achievement['earned'] as bool
                        ? achievement['color'] as Color
                        : AppColors.lightGrey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    achievement['icon'] as IconData,
                    color: achievement['earned'] as bool
                        ? AppColors.white
                        : AppColors.mediumGrey,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        achievement['title'] as String,
                        style: AppTypography.body1.copyWith(
                          color: AppColors.charcoal,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        achievement['description'] as String,
                        style: AppTypography.body2.copyWith(
                          color: AppColors.mediumGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                if (achievement['earned'] as bool)
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.success,
                    size: 24,
                  )
                else
                  const Icon(
                    Icons.lock,
                    color: AppColors.mediumGrey,
                    size: 20,
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildWeeklySummary() {
    return CustomCard(
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.insights,
                color: AppColors.primaryPastel,
                size: 32,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Weekly Insights',
                      style: AppTypography.h4.copyWith(
                        color: AppColors.charcoal,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Your mood has been consistently positive this week\n• Breathing exercises helped reduce anxiety levels\n• You\'ve been most active on Wednesdays and Saturdays\n• Consider trying more grounding exercises for stress management',
                      style: AppTypography.body2.copyWith(
                        color: AppColors.darkGrey,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

