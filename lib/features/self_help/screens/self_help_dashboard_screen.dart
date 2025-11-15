import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/custom_widgets.dart';

class SelfHelpDashboardScreen extends StatelessWidget {
  const SelfHelpDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Peace Gradient Header
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.peacePastelGradient,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Self-Help Tools',
                      style: AppTypography.h2.copyWith(
                        color: AppColors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your journey to mental wellness starts here',
                      style: AppTypography.body1.copyWith(
                        color: AppColors.white.withOpacity(0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.search,
                  color: AppColors.white,
                ),
                onPressed: () => _showSearchDialog(context),
              ),
              IconButton(
                icon: Icon(
                  Icons.bookmark_border,
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
                // Daily Progress
                _buildProgressSection(),
                const SizedBox(height: 32),

                // CBT/DBT/ACT Tools
                Text(
                  'Therapy Approaches',
                  style: AppTypography.h4.copyWith(
                    color: AppColors.charcoal,
                  ),
                ),
                const SizedBox(height: 16),
                _buildTherapyTools(context),
                const SizedBox(height: 32),

                // Guided Programs
                Text(
                  'Guided Programs',
                  style: AppTypography.h4.copyWith(
                    color: AppColors.charcoal,
                  ),
                ),
                const SizedBox(height: 16),
                _buildGuidedPrograms(context),
                const SizedBox(height: 32),

                // Quick Assessments
                Text(
                  'Quick Assessments',
                  style: AppTypography.h4.copyWith(
                    color: AppColors.charcoal,
                  ),
                ),
                const SizedBox(height: 16),
                _buildAssessments(context),
                const SizedBox(height: 32),

                // Resources & Support
                Text(
                  'Resources & Support',
                  style: AppTypography.h4.copyWith(
                    color: AppColors.charcoal,
                  ),
                ),
                const SizedBox(height: 16),
                _buildResources(context),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection() {
    return CustomCard(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFE8F4FD), Color(0xFFF3E8FF)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.psychology,
                color: AppColors.primaryPastel,
                size: 32,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Progress',
                      style: AppTypography.h4.copyWith(
                        color: AppColors.charcoal,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '7 days streak • 12 tools explored',
                      style: AppTypography.body2.copyWith(
                        color: AppColors.mediumGrey,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.success.withOpacity(0.3)),
                ),
                child: Text(
                  '85%',
                  style: AppTypography.label.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: 0.85,
            backgroundColor: AppColors.lightGrey,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.success),
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildTherapyTools(BuildContext context) {
    final tools = [
      {
        'name': 'CBT Tools',
        'description': 'Cognitive Behavioral Therapy techniques',
        'icon': Icons.psychology,
        'color': AppColors.primaryPastel,
        'tools': ['Thought Records', 'Behavioral Experiments', 'Cognitive Restructuring'],
      },
      {
        'name': 'DBT Skills',
        'description': 'Dialectical Behavior Therapy skills training',
        'icon': Icons.balance,
        'color': AppColors.secondaryPastel,
        'tools': ['Mindfulness', 'Distress Tolerance', 'Emotion Regulation'],
      },
      {
        'name': 'ACT Exercises',
        'description': 'Acceptance and Commitment Therapy',
        'icon': Icons.self_improvement,
        'color': AppColors.accentPastel,
        'tools': ['Values Clarification', 'Defusion', 'Committed Action'],
      },
    ];

    return Column(
      children: tools.map((tool) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: CustomCard(
            onTap: () => _openTherapyTool(
              context,
              tool['name'] as String,
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: tool['color'] as Color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    tool['icon'] as IconData,
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
                        tool['name'] as String,
                        style: AppTypography.body1.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.charcoal,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        tool['description'] as String,
                        style: AppTypography.body2.copyWith(
                          color: AppColors.mediumGrey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: (tool['tools'] as List<String>).map((skill) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: (tool['color'] as Color).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              skill,
                              style: AppTypography.labelSmall.copyWith(
                                color: tool['color'] as Color,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }).toList(),
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

  Widget _buildGuidedPrograms(BuildContext context) {
    final programs = [
      {
        'title': 'Anxiety Management',
        'duration': '4 weeks',
        'progress': 0.6,
        'color': AppColors.anxiousPastel,
      },
      {
        'title': 'Stress Reduction',
        'duration': '2 weeks',
        'progress': 0.3,
        'color': AppColors.stressPastel,
      },
      {
        'title': 'Sleep Improvement',
        'duration': '3 weeks',
        'progress': 0.8,
        'color': AppColors.calmPastel,
      },
    ];

    return Column(
      children: programs.map((program) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: CustomCard(
            onTap: () => _startProgram(
              context,
              program['title'] as String,
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: program['color'] as Color,
                    borderRadius: BorderRadius.circular(12),
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
                        program['title'] as String,
                        style: AppTypography.body1.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.charcoal,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            program['duration'] as String,
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.mediumGrey,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: LinearProgressIndicator(
                              value: program['progress'] as double,
                              backgroundColor: AppColors.lightGrey,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                program['color'] as Color,
                              ),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${((program['progress'] as double) * 100).toInt()}%',
                            style: AppTypography.labelSmall.copyWith(
                              color: program['color'] as Color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAssessments(BuildContext context) {
    final assessments = [
      {
        'title': 'Anxiety Level Check',
        'description': 'Quick 5-minute assessment',
        'icon': Icons.assessment,
        'color': AppColors.anxiousPastel,
      },
      {
        'title': 'Depression Screening',
        'description': 'PHQ-9 questionnaire',
        'icon': Icons.mood_bad,
        'color': AppColors.sadPastel,
      },
      {
        'title': 'Stress Level Test',
        'description': 'PSS-10 assessment',
        'icon': Icons.warning,
        'color': AppColors.stressPastel,
      },
    ];

    return Column(
      children: assessments.map((assessment) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: CustomCard(
            onTap: () => _takeAssessment(
              context,
              assessment['title'] as String,
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: assessment['color'] as Color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    assessment['icon'] as IconData,
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
                        assessment['title'] as String,
                        style: AppTypography.body1.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.charcoal,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        assessment['description'] as String,
                        style: AppTypography.body2.copyWith(
                          color: AppColors.mediumGrey,
                        ),
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

  Widget _buildResources(BuildContext context) {
    final resources = [
      {
        'title': 'Crisis Support',
        'subtitle': '24/7 emergency resources',
        'icon': Icons.emergency,
        'color': AppColors.error,
      },
      {
        'title': 'Community Forum',
        'subtitle': 'Connect with others',
        'icon': Icons.group,
        'color': AppColors.primaryPastel,
      },
      {
        'title': 'Help Articles',
        'subtitle': 'Mental health guides',
        'icon': Icons.article,
        'color': AppColors.secondaryPastel,
      },
    ];

    return Column(
      children: resources.map((resource) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: CustomCard(
            onTap: () => _openResource(
              context,
              resource['title'] as String,
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: resource['color'] as Color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    resource['icon'] as IconData,
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
                        resource['title'] as String,
                        style: AppTypography.body1.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.charcoal,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        resource['subtitle'] as String,
                        style: AppTypography.body2.copyWith(
                          color: AppColors.mediumGrey,
                        ),
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

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Search Tools',
          style: AppTypography.h4.copyWith(color: AppColors.charcoal),
        ),
        content: TextField(
          decoration: InputDecoration(
            hintText: 'Search for exercises, tools, or resources...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: AppTypography.button.copyWith(color: AppColors.mediumGrey),
            ),
          ),
          CustomButton(
            text: 'Search',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void _openTherapyTool(BuildContext context, String tool) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Opening $tool...',
          style: AppTypography.body2.copyWith(color: AppColors.white),
        ),
        backgroundColor: AppColors.primaryPastel,
      ),
    );
  }

  void _startProgram(BuildContext context, String program) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Starting $program program...',
          style: AppTypography.body2.copyWith(color: AppColors.white),
        ),
        backgroundColor: AppColors.secondaryPastel,
      ),
    );
  }

  void _takeAssessment(BuildContext context, String assessment) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Starting $assessment...',
          style: AppTypography.body2.copyWith(color: AppColors.white),
        ),
        backgroundColor: AppColors.accentPastel,
      ),
    );
  }

  void _openResource(BuildContext context, String resource) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Opening $resource...',
          style: AppTypography.body2.copyWith(color: AppColors.white),
        ),
        backgroundColor: AppColors.warmPastel,
      ),
    );
  }
}