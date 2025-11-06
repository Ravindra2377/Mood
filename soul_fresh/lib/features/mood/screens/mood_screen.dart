import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/custom_card.dart';

class MoodScreen extends StatefulWidget {
  const MoodScreen({super.key});

  @override
  State<MoodScreen> createState() => _MoodScreenState();
}

class _MoodScreenState extends State<MoodScreen> {
  String? _selectedMood;
  final List<String> _selectedTriggers = [];
  final TextEditingController _notesController = TextEditingController();

  final List<Map<String, dynamic>> _moods = [
    {
      'emoji': '😊',
      'label': 'Happy',
      'color': AppColors.happyPastel,
    },
    {
      'emoji': '😌',
      'label': 'Calm',
      'color': AppColors.calmPastel,
    },
    {
      'emoji': '😰',
      'label': 'Anxious',
      'color': AppColors.anxiousPastel,
    },
    {
      'emoji': '😢',
      'label': 'Sad',
      'color': AppColors.sadPastel,
    },
    {
      'emoji': '⚡',
      'label': 'Energetic',
      'color': AppColors.energyPastel,
    },
    {
      'emoji': '😫',
      'label': 'Stressed',
      'color': AppColors.stressPastel,
    },
  ];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Gradient Header
          SliverAppBar(
            expandedHeight: 200,
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
                        color: AppColors.white.withValues(alpha: 0.9),
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
                _buildMoodIntroCard(),
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
                TextField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                    hintText: 'Add any additional thoughts or context...',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 32),

                // Save Button
                ElevatedButton(
                  onPressed: _saveMoodEntry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPastel,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Save Mood Entry',
                      style: AppTypography.body1.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
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

  Widget _buildMoodIntroCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.calmPastel.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: AppColors.calmPastel.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Take a mindful pause',
            style: AppTypography.h4.copyWith(
              color: AppColors.charcoal,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Use the prompts below to capture how you feel and what shaped your day. Small reflections lead to deeper insight.',
            style: AppTypography.body2.copyWith(
              color: AppColors.darkGrey,
            ),
            textAlign: TextAlign.center,
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
      ),
      itemCount: _moods.length,
      itemBuilder: (context, index) {
        final mood = _moods[index];
        final moodColor = mood['color'] as Color;
        final isSelected = _selectedMood == mood['label'];

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedMood = mood['label'] as String?;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? moodColor : AppColors.lightGrey,
              borderRadius: BorderRadius.circular(16),
              border: isSelected
                  ? Border.all(color: AppColors.primaryPastel, width: 2)
                  : null,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: moodColor.withValues(alpha: 0.3),
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
                  mood['emoji'],
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(height: 8),
                Text(
                  mood['label'],
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
          selectedColor: AppColors.primaryPastel.withValues(alpha: 0.2),
          checkmarkColor: AppColors.primaryPastel,
          labelStyle: AppTypography.label.copyWith(
            color: isSelected ? AppColors.primaryPastel : AppColors.darkGrey,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecentHistory() {
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
                        (entry['emoji']?.toString() ?? ''),
                        style: const TextStyle(fontSize: 24),
                      ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                            Text(
                              (entry['mood']?.toString() ?? ''),
                              style: AppTypography.body1.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.charcoal,
                              ),
                            ),
                            Text(
                              (entry['time']?.toString() ?? ''),
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.mediumGrey,
                              ),
                            ),
                  ],
                ),
              ),
              const Icon(
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Mood entry saved successfully!',
          style: AppTypography.body2.copyWith(color: AppColors.white),
        ),
        backgroundColor: AppColors.success,
      ),
    );

    setState(() {
      _selectedMood = null;
      _selectedTriggers.clear();
      _notesController.clear();
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
}
