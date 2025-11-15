import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/self_help/self_help_models.dart';
import '../controllers/self_help_controller.dart';
import '../screens/personalized_plan_screen.dart';

class CheckInScreen extends ConsumerStatefulWidget {
  final MoodType initialMood;

  const CheckInScreen({
    Key? key,
    required this.initialMood,
  }) : super(key: key);

  @override
  ConsumerState<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends ConsumerState<CheckInScreen> {
  late MoodType selectedMood;
  double energyLevel = 5;
  int? stressLevel;
  int? anxietyLevel;
  final Set<String> selectedTriggers = {};
  final Map<String, double> triggerIntensity = {};

  final triggers = [
    {'id': 'work_stress', 'label': 'Work stress', 'icon': '💼'},
    {'id': 'sleep_issues', 'label': 'Sleep issues', 'icon': '😴'},
    {'id': 'relationships', 'label': 'Relationships', 'icon': '❤️'},
    {'id': 'health', 'label': 'Health concerns', 'icon': '🏥'},
    {'id': 'financial', 'label': 'Financial worries', 'icon': '💰'},
    {'id': 'social', 'label': 'Social anxiety', 'icon': '👥'},
  ];

  @override
  void initState() {
    super.initState();
    selectedMood = widget.initialMood;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Check-In'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              title: 'How are you feeling right now?',
              child: _buildMoodSelector(),
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: 'Rate your energy level (1-10)',
              child: _buildEnergySlider(),
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: 'What\'s affecting you today?',
              child: _buildTriggerSelector(),
            ),
            if (selectedTriggers.isNotEmpty) ...[
              const SizedBox(height: 24),
              _buildSection(
                title: 'How intense are these?',
                child: _buildIntensitySliders(),
              ),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _submitCheckIn,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Get Personalized Plan →',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildMoodSelector() {
    final moods = [
      {'type': MoodType.great, 'emoji': '😊', 'label': 'Great'},
      {'type': MoodType.good, 'emoji': '😌', 'label': 'Good'},
      {'type': MoodType.okay, 'emoji': '😐', 'label': 'Okay'},
      {'type': MoodType.notGood, 'emoji': '😟', 'label': 'Not Good'},
      {'type': MoodType.bad, 'emoji': '😢', 'label': 'Bad'},
      {'type': MoodType.crisis, 'emoji': '😰', 'label': 'Crisis'},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: moods.map((mood) {
        final isSelected = selectedMood == mood['type'];
        return ChoiceChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(mood['emoji'] as String, style: TextStyle(fontSize: 20)),
              const SizedBox(width: 6),
              Text(mood['label'] as String),
            ],
          ),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              selectedMood = mood['type'] as MoodType;
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildEnergySlider() {
    return Column(
      children: [
        Slider(
          value: energyLevel,
          min: 1,
          max: 10,
          divisions: 9,
          label: energyLevel.round().toString(),
          onChanged: (value) {
            setState(() {
              energyLevel = value;
            });
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Low', style: TextStyle(color: Colors.grey)),
            Text(
              '${energyLevel.round()}/10',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text('High', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ],
    );
  }

  Widget _buildTriggerSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: triggers.map((trigger) {
        final isSelected = selectedTriggers.contains(trigger['id']);
        return FilterChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(trigger['icon'] as String),
              const SizedBox(width: 6),
              Text(trigger['label'] as String),
            ],
          ),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                selectedTriggers.add(trigger['id'] as String);
                triggerIntensity[trigger['id'] as String] = 5.0;
              } else {
                selectedTriggers.remove(trigger['id']);
                triggerIntensity.remove(trigger['id']);
              }
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildIntensitySliders() {
    return Column(
      children: selectedTriggers.map((triggerId) {
        final trigger = triggers.firstWhere((t) => t['id'] == triggerId);
        final intensity = triggerIntensity[triggerId] ?? 5.0;

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(trigger['icon'] as String),
                  const SizedBox(width: 8),
                  Text(
                    trigger['label'] as String,
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              Slider(
                value: intensity,
                min: 1,
                max: 10,
                divisions: 9,
                label: intensity.round().toString(),
                onChanged: (value) {
                  setState(() {
                    triggerIntensity[triggerId] = value;
                  });
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Mild', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  Text('${intensity.round()}/10'),
                  Text('Severe', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _submitCheckIn() {
    final assessment = UserAssessment(
      timestamp: DateTime.now(),
      mood: selectedMood,
      energyLevel: energyLevel.round(),
      triggers: selectedTriggers.toList(),
      triggerIntensity: triggerIntensity.map((k, v) => MapEntry(k, v.round())),
      stressLevel: stressLevel,
      anxietyLevel: anxietyLevel,
    );

    // Save assessment
    ref.read(selfHelpControllerProvider.notifier).saveAssessment(assessment);

    // Navigate to personalized plan
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PersonalizedPlanScreen(assessment: assessment),
      ),
    );
  }
}