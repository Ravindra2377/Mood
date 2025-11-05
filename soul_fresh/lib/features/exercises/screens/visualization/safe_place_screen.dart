import 'package:flutter/material.dart';

import '../../models/exercise_models.dart';
import '../../services/exercise_service.dart';
import '../../widgets/exercise_scaffold.dart';

class SafePlaceScreen extends StatefulWidget {
  const SafePlaceScreen({super.key});

  @override
  State<SafePlaceScreen> createState() => _SafePlaceScreenState();
}

class _SafePlaceScreenState extends State<SafePlaceScreen> {
  late ExerciseSession session;
  final PageController _pageController = PageController();
  final List<_VisualizationPrompt> _prompts = _buildPrompts();
  final TextEditingController _anchoringPhraseController =
      TextEditingController();

  int _currentStep = 0;
  bool _hasStarted = false;
  bool _soundscapeEnabled = false;
  double _intensity = 6;
  int _moodBefore = 5;
  int? _moodAfter;

  @override
  void initState() {
    super.initState();
    session = ExerciseSession(
      exerciseId: 'safe_place_visualization',
      startTime: DateTime.now(),
    );
    session.moodBefore = _moodBefore;
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (final prompt in _prompts) {
      prompt.controller.dispose();
    }
    _anchoringPhraseController.dispose();
    super.dispose();
  }

  Future<void> _completeExercise() async {
    FocusScope.of(context).unfocus();

    final entries = _prompts
        .where((prompt) => prompt.controller.text.trim().isNotEmpty)
        .map((prompt) => {
              'sense': prompt.sense,
              'details': prompt.controller.text.trim(),
            },)
        .toList();

    if (entries.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Capture at least three senses to anchor your space.'),
        ),
      );
      return;
    }

    session
      ..endTime = DateTime.now()
      ..moodBefore = _moodBefore
      ..moodAfter = _moodAfter
      ..notes = _anchoringPhraseController.text.trim().isEmpty
          ? null
          : _anchoringPhraseController.text.trim()
      ..extraData = {
        'steps_completed': _currentStep + 1,
        'soundscape_enabled': _soundscapeEnabled,
        'vividness_rating': _intensity.round(),
        'senses': entries,
      };

    await ExerciseService().saveSession(session);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Visualization saved. Carry this feeling with you.'),),
    );
    Navigator.of(context).pop();
  }

  void _goToStep(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() {
      _currentStep = index;
    });
  }

  void _goForward() {
    if (_currentStep < _prompts.length - 1) {
      _goToStep(_currentStep + 1);
    } else {
      _completeExercise();
    }
  }

  void _goBack() {
    if (_currentStep > 0) {
      _goToStep(_currentStep - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ExerciseScaffold(
      title: 'Safe Place Visualization',
      subtitle: 'Build a sanctuary using all senses',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(
            value: (_currentStep + 1) / _prompts.length,
          ),
          const SizedBox(height: 16),
          _buildMoodSection(),
          const SizedBox(height: 16),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _prompts.length,
              itemBuilder: (context, index) {
                final prompt = _prompts[index];
                return _SenseStepCard(
                  prompt: prompt,
                  hasStarted: _hasStarted,
                  onStarted: () {
                    if (!_hasStarted) {
                      setState(() => _hasStarted = true);
                    }
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          _buildControls(),
        ],
      ),
    );
  }

  Widget _buildMoodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How vivid is your space right now?',
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Slider(
          value: _intensity,
          min: 1,
          max: 10,
          divisions: 9,
          label: _intensity.round().toString(),
          onChanged: (value) {
            setState(() {
              _intensity = value;
            });
          },
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: _soundscapeEnabled,
          onChanged: (value) {
            setState(() {
              _soundscapeEnabled = value;
            });
          },
          title: const Text('Play ambient sound while visualizing'),
        ),
        const SizedBox(height: 8),
        Text(
          'Mood check-in',
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        _MoodSlider(
          label: 'Before starting',
          value: _moodBefore.toDouble(),
          onChanged: (value) {
            setState(() {
              _moodBefore = value.round();
              session.moodBefore = _moodBefore;
            });
          },
        ),
        const SizedBox(height: 12),
        _MoodSlider(
          label: 'After visualizing',
          value: (_moodAfter ?? _moodBefore).toDouble(),
          onChanged: (value) {
            setState(() {
              _moodAfter = value.round();
            });
          },
        ),
      ],
    );
  }

  Widget _buildControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _anchoringPhraseController,
          decoration: const InputDecoration(
            labelText: 'Anchor phrase (optional)',
            hintText: '“When I breathe in, I return to my safe place.”',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _currentStep == 0 ? null : _goBack,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: _goForward,
                icon: Icon(
                  _currentStep == _prompts.length - 1
                      ? Icons.check_circle_outline
                      : Icons.arrow_forward,
                ),
                label: Text(
                  _currentStep == _prompts.length - 1
                      ? 'Save visualization'
                      : 'Next sense',
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _VisualizationPrompt {
  _VisualizationPrompt({
    required this.sense,
    required this.description,
    required this.suggestions,
  }) : controller = TextEditingController();

  final String sense;
  final String description;
  final List<String> suggestions;
  final TextEditingController controller;
}

class _SenseStepCard extends StatelessWidget {
  const _SenseStepCard({
    required this.prompt,
    required this.hasStarted,
    required this.onStarted,
  });

  final _VisualizationPrompt prompt;
  final bool hasStarted;
  final VoidCallback onStarted;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  child: Text(prompt.sense.substring(0, 1).toUpperCase()),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    prompt.sense,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              prompt.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: prompt.suggestions
                  .map(
                    (suggestion) => ActionChip(
                      label: Text(suggestion),
                      onPressed: () {
                        if (!hasStarted) {
                          onStarted();
                        }
                        final controller = prompt.controller;
                        final current = controller.text;
                        controller.text = current.isEmpty
                            ? suggestion
                            : '$current, $suggestion';
                        controller.selection = TextSelection.fromPosition(
                          TextPosition(offset: controller.text.length),
                        );
                      },
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: prompt.controller,
                onTap: () {
                  if (!hasStarted) {
                    onStarted();
                  }
                },
                decoration: InputDecoration(
                  hintText:
                      'Describe what your ${prompt.sense.toLowerCase()} experiences here.',
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.multiline,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoodSlider extends StatelessWidget {
  const _MoodSlider({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text(value.round().toString()),
          ],
        ),
        Slider(
          value: value.clamp(1, 10),
          min: 1,
          max: 10,
          divisions: 9,
          label: value.round().toString(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

List<_VisualizationPrompt> _buildPrompts() {
  return [
    _VisualizationPrompt(
      sense: 'Sight',
      description:
          'Notice colors, shapes, and everything you can see in this space.',
      suggestions: [
        'Soft sunrise light',
        'Ocean horizon',
        'Forest greens',
        'Candle glow',
      ],
    ),
    _VisualizationPrompt(
      sense: 'Sound',
      description: 'Tune into comforting sounds surrounding you.',
      suggestions: [
        'Gentle waves',
        'Crackling fire',
        'Birdsong',
        'Quiet piano',
      ],
    ),
    _VisualizationPrompt(
      sense: 'Scent',
      description: 'Add scents that instantly calm you.',
      suggestions: ['Lavender', 'Fresh rain', 'Pine trees', 'Vanilla'],
    ),
    _VisualizationPrompt(
      sense: 'Touch',
      description: 'Feel textures, temperature, and anything you can touch.',
      suggestions: [
        'Warm blanket',
        'Soft sand',
        'Cool breeze',
        'Cozy armchair',
      ],
    ),
    _VisualizationPrompt(
      sense: 'Emotion',
      description:
          'How do you feel in this safe place? Capture the emotional tone.',
      suggestions: ['Peaceful', 'Empowered', 'Grounded', 'Light'],
    ),
  ];
}
