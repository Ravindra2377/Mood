import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/custom_widgets.dart';
import '../../../core/widgets/custom_input_field.dart';

class MoodScreen extends StatefulWidget {
  const MoodScreen({super.key});

  @override
  State<MoodScreen> createState() => _MoodScreenState();
}

class _MoodScreenState extends State<MoodScreen> {
  String? _selectedMood;
  final List<String> _selectedTriggers = [];
  final TextEditingController _notesController = TextEditingController();

  final List<_MoodOption> _moods = const [
    _MoodOption(
      emoji: '😊',
      label: 'Happy',
      color: AppColors.happyPastel,
      headline: 'Celebrate the good moments',
      message: 'Capture what lifted your mood so you can recreate it on tougher days.',
    ),
    _MoodOption(
      emoji: '�',
      label: 'Calm',
      color: AppColors.calmPastel,
      headline: 'Notice your ease',
      message: 'Jot down the habits or support that helped you feel balanced today.',
    ),
    _MoodOption(
      emoji: '😰',
      label: 'Anxious',
      color: AppColors.anxiousPastel,
      headline: 'You are not alone',
      message: 'Name the worry, ground your senses, and plan one compassionate next step.',
    ),
    _MoodOption(
      emoji: '😢',
      label: 'Sad',
      color: AppColors.sadPastel,
      headline: 'Offer yourself kindness',
      message: 'Write about what feels heavy and the comfort you wish you had right now.',
    ),
    _MoodOption(
      emoji: '⚡',
      label: 'Energetic',
      color: AppColors.energyPastel,
      headline: 'Channel the energy',
      message: 'List one thing you can create or move forward with this momentum.',
    ),
    _MoodOption(
      emoji: '😫',
      label: 'Stressed',
      color: AppColors.stressPastel,
      headline: 'Let the pressure breathe out',
      message: 'Break the stress down into smaller pieces and be gentle with expectations.',
    ),
  ];

  String _supportHeadline = 'How are you arriving?';
  String _supportMessage = 'Select a mood to unlock tailored grounding prompts and micro-steps.';

  final List<String> _triggers = [
    'Work',
    'Family',
    'Friends',
    'Health',
    'Money',
    'Weather',
    'Sleep',
    'Food',
    'Exercise',
    'Social Media',
  ];

  final List<_MicroStep> _microSteps = const [
    _MicroStep(
      title: 'Breathing reset',
      description: 'Inhale for 4 counts, hold 4, exhale for 6. Repeat three times.',
      icon: Icons.air,
    ),
    _MicroStep(
      title: 'Body scan',
      description: 'Notice tension from head to toe and soften one area at a time.',
      icon: Icons.self_improvement,
    ),
    _MicroStep(
      title: 'Gratitude jot',
      description: 'Write three small gratitudes or moments of ease from today.',
      icon: Icons.favorite_border,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Gradient Header
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.lavenderGradient,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'How are you feeling?',
                      style: AppTypography.h2.copyWith(
                        color: AppColors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Track your mood to understand your patterns',
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
                _buildSupportCard(),
                const SizedBox(height: 24),
                // Mood Selection
                Text(
                  'Select your mood',
                  style: AppTypography.h4.copyWith(
                    color: AppColors.charcoal,
                  ),
                ),
                const SizedBox(height: 16),
                _buildMoodGrid(),
                const SizedBox(height: 32),

                // Triggers Section
                Text(
                  'What triggered this mood?',
                  style: AppTypography.h4.copyWith(
                    color: AppColors.charcoal,
                  ),
                ),
                const SizedBox(height: 16),
                _buildTriggersSection(),
                const SizedBox(height: 32),

                // Notes Section
                CustomInputField(
                  label: 'Notes (optional)',
                  hint: 'Add any additional thoughts or context...',
                  controller: _notesController,
                  maxLines: 3,
                ),
                const SizedBox(height: 32),

                // Save Button
                CustomButton(
                  text: 'Save Mood Entry',
                  onPressed: _saveMoodEntry,
                  backgroundColor: AppColors.primaryPastel,
                ),
                const SizedBox(height: 32),

                // Recent History Preview
                Text(
                  'Recent Entries',
                  style: AppTypography.h4.copyWith(
                    color: AppColors.charcoal,
                  ),
                ),
                const SizedBox(height: 16),
                _buildRecentHistory(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: _moods.length,
      itemBuilder: (context, index) {
        final mood = _moods[index];
        final isSelected = _selectedMood == mood.label;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedMood = mood.label;
            });
            _updateSupportState(mood);
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? mood.color : AppColors.lightGrey,
              borderRadius: BorderRadius.circular(16),
              border: isSelected
                  ? Border.all(color: AppColors.primaryPastel, width: 2)
                  : null,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: mood.color.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  mood.emoji,
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(height: 8),
                Text(
                  mood.label,
                  style: AppTypography.label.copyWith(
                    color: isSelected ? AppColors.charcoal : AppColors.darkGrey,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTriggersSection() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _triggers.map((trigger) {
        final isSelected = _selectedTriggers.contains(trigger);
        return FilterChip(
          label: Text(trigger),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedTriggers.add(trigger);
              } else {
                _selectedTriggers.remove(trigger);
              }
            });
          },
          backgroundColor: AppColors.lightGrey,
          selectedColor: AppColors.primaryPastel.withOpacity(0.2),
          checkmarkColor: AppColors.primaryPastel,
          labelStyle: AppTypography.label.copyWith(
            color: isSelected ? AppColors.primaryPastel : AppColors.darkGrey,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecentHistory() {
    // Mock recent entries - in a real app, this would come from a database
    final recentEntries = [
      {'mood': 'Happy', 'emoji': '😊', 'date': 'Today', 'time': '2 hours ago'},
      {'mood': 'Calm', 'emoji': '😌', 'date': 'Yesterday', 'time': '1 day ago'},
      {'mood': 'Anxious', 'emoji': '😰', 'date': '2 days ago', 'time': '2 days ago'},
    ];

    return Column(
      children: recentEntries.map((entry) {
        return CustomCard(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Text(
                entry['emoji'] as String,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry['mood'] as String,
                      style: AppTypography.body1.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.charcoal,
                      ),
                    ),
                    Text(
                      entry['time'] as String,
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.mediumGrey,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppColors.mediumGrey,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _saveMoodEntry() {
    if (_selectedMood == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select a mood before saving',
            style: AppTypography.body2.copyWith(color: AppColors.white),
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // In a real app, this would save to a database
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Mood entry saved successfully!',
          style: AppTypography.body2.copyWith(color: AppColors.white),
        ),
        backgroundColor: AppColors.success,
      ),
    );

    // Reset form
    setState(() {
      _selectedMood = null;
      _selectedTriggers.clear();
      _notesController.clear();
      _supportHeadline = 'Check in complete';
      _supportMessage = 'Take a moment to notice any shifts after logging your state.';
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Widget _buildSupportCard() {
    return CustomCard(
      backgroundColor: AppColors.white,
      border: Border.all(color: AppColors.calmPastel.withOpacity(0.6)),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: AppColors.lavenderGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.spa_rounded, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _supportHeadline,
                      style: AppTypography.h4.copyWith(
                        color: AppColors.charcoal,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _supportMessage,
                      style: AppTypography.body2.copyWith(
                        color: AppColors.darkGrey,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Micro-steps you can try',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.darkGrey,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 10),
          Column(
            children: _microSteps.map((step) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(step.icon, color: AppColors.primaryPastel, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            step.title,
                            style: AppTypography.body1.copyWith(
                              color: AppColors.charcoal,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            step.description,
                            style: AppTypography.body2.copyWith(
                              color: AppColors.darkGrey,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _updateSupportState(_MoodOption mood) {
    setState(() {
      _supportHeadline = mood.headline;
      _supportMessage = mood.message;
    });
  }
}

class _MoodOption {
  const _MoodOption({
    required this.emoji,
    required this.label,
    required this.color,
    required this.headline,
    required this.message,
  });

  final String emoji;
  final String label;
  final Color color;
  final String headline;
  final String message;
}

class _MicroStep {
  const _MicroStep({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;
}