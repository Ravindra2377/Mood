import 'package:flutter/material.dart';

import '../../models/exercise_models.dart';
import '../../services/exercise_service.dart';
import '../../widgets/exercise_scaffold.dart';

class SuccessVisualizationScreen extends StatefulWidget {
  const SuccessVisualizationScreen({Key? key}) : super(key: key);

  @override
  State<SuccessVisualizationScreen> createState() =>
      _SuccessVisualizationScreenState();
}

class _SuccessVisualizationScreenState
    extends State<SuccessVisualizationScreen> {
  late ExerciseSession session;
  final PageController _pageController = PageController();
  final _goalController = TextEditingController();
  final _obstaclesController = TextEditingController();
  final _affirmationController = TextEditingController();
  final List<_VisualizationPhase> _phases = _buildPhases();

  int _currentIndex = 0;
  double _confidence = 6;
  double _activation = 5;
  int _moodBefore = 6;
  int? _moodAfter;

  @override
  void initState() {
    super.initState();
    session = ExerciseSession(
      exerciseId: 'success_visualization',
      startTime: DateTime.now(),
    );
    session.moodBefore = _moodBefore;
  }

  @override
  void dispose() {
    _pageController.dispose();
    _goalController.dispose();
    _obstaclesController.dispose();
    _affirmationController.dispose();
    for (final phase in _phases) {
      phase.controller.dispose();
    }
    super.dispose();
  }

  Future<void> _completeExercise() async {
    FocusScope.of(context).unfocus();

    if (_goalController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name the goal you\'re rehearsing.')),
      );
      return;
    }

    session
      ..endTime = DateTime.now()
      ..moodBefore = _moodBefore
      ..moodAfter = _moodAfter
      ..notes = _affirmationController.text.trim().isEmpty
          ? null
          : _affirmationController.text.trim()
      ..extraData = {
        'goal': _goalController.text.trim(),
        'obstacles': _obstaclesController.text.trim(),
        'confidence': _confidence.round(),
        'activation': _activation.round(),
        'phases': _phases
            .map((phase) => {
                  'title': phase.title,
                  'details': phase.controller.text.trim(),
                })
            .toList(),
      };

    await ExerciseService().saveSession(session);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Visualization saved. Carry that confidence forward.')),
    );
    Navigator.of(context).pop();
  }

  void _next() {
    if (_currentIndex < _phases.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
      setState(() => _currentIndex++);
    } else {
      _completeExercise();
    }
  }

  void _previous() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
      setState(() => _currentIndex--);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ExerciseScaffold(
      title: 'Success Visualization',
      subtitle: 'Mentally rehearse your win',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _goalController,
            decoration: const InputDecoration(
              labelText: 'Your specific goal',
              hintText:
                  'Presenting calmly tomorrow, finishing a run, asking for support…',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _obstaclesController,
            minLines: 2,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Possible obstacles or sticking points',
              hintText: 'List the moments that usually trip you up.',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          _buildSliders(),
          const SizedBox(height: 16),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _phases.length,
              itemBuilder: (context, index) {
                final phase = _phases[index];
                return _PhaseCard(phase: phase);
              },
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _affirmationController,
            decoration: const InputDecoration(
              labelText: 'Anchor phrase for after the visualization',
              hintText: '“I show up grounded and ready.”',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _currentIndex == 0 ? null : _previous,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _next,
                  icon: Icon(
                    _currentIndex == _phases.length - 1
                        ? Icons.check_circle_outline
                        : Icons.arrow_forward,
                  ),
                  label: Text(
                    _currentIndex == _phases.length - 1
                        ? 'Save visualization'
                        : 'Next phase',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSliders() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How ready do you feel?',
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        _SliderTile(
          label: 'Confidence',
          value: _confidence,
          onChanged: (value) {
            setState(() => _confidence = value);
          },
        ),
        const SizedBox(height: 12),
        _SliderTile(
          label: 'Energy/activation',
          value: _activation,
          onChanged: (value) {
            setState(() => _activation = value);
          },
        ),
        const SizedBox(height: 12),
        _SliderTile(
          label: 'Mood before',
          value: _moodBefore.toDouble(),
          onChanged: (value) {
            setState(() {
              _moodBefore = value.round();
              session.moodBefore = _moodBefore;
            });
          },
        ),
        const SizedBox(height: 12),
        _SliderTile(
          label: 'Mood after',
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
}

class _VisualizationPhase {
  _VisualizationPhase({
    required this.title,
    required this.description,
    required this.cues,
  }) : controller = TextEditingController();

  final String title;
  final String description;
  final List<String> cues;
  final TextEditingController controller;
}

class _PhaseCard extends StatelessWidget {
  const _PhaseCard({required this.phase});

  final _VisualizationPhase phase;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              phase.title,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              phase.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: phase.cues
                  .map(
                    (cue) => ActionChip(
                      label: Text(cue),
                      onPressed: () {
                        final controller = phase.controller;
                        final current = controller.text.trim();
                        controller.text =
                            current.isEmpty ? cue : '$current \u2022 $cue';
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
                controller: phase.controller,
                decoration: const InputDecoration(
                  hintText:
                      'Capture imagery, self-talk, and emotions you want to feel.',
                  border: OutlineInputBorder(),
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

class _SliderTile extends StatelessWidget {
  const _SliderTile({
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

List<_VisualizationPhase> _buildPhases() {
  return [
    _VisualizationPhase(
      title: 'Arrive and prepare',
      description:
          'Ground yourself in the moment. Picture where you are, who\'s around, and how you enter the scene.',
      cues: [
        'Confident posture',
        'Supportive faces',
        'Steady breathing',
        'Clear intention'
      ],
    ),
    _VisualizationPhase(
      title: 'Experience the win',
      description:
          'See yourself executing flawlessly. Engage all senses: what do you see, hear, and feel as it unfolds?',
      cues: ['Voice steady', 'Audience engaged', 'Body relaxed', 'Flow state'],
    ),
    _VisualizationPhase(
      title: 'Anchor the afterglow',
      description:
          'Notice the emotions of success. Capture supportive self-talk and how you will carry this forward.',
      cues: ['Proud', 'Grateful', 'Capable', 'Calm'],
    ),
  ];
}
