import 'package:flutter/material.dart';

import '../../models/exercise_models.dart';
import '../../services/exercise_service.dart';
import '../../widgets/exercise_scaffold.dart';

class FiveFourThreeTwoOneScreen extends StatefulWidget {
  const FiveFourThreeTwoOneScreen({super.key});

  @override
  State<FiveFourThreeTwoOneScreen> createState() =>
      _FiveFourThreeTwoOneScreenState();
}

class _FiveFourThreeTwoOneScreenState extends State<FiveFourThreeTwoOneScreen> {
  late ExerciseSession session;
  final List<_GroundingStep> _steps = _buildSteps();
  final TextEditingController _controller = TextEditingController();

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    session = ExerciseSession(
      exerciseId: '5_4_3_2_1',
      startTime: DateTime.now(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addItem() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _steps[_currentIndex].items.add(text);
      _controller.clear();
    });

    if (_steps[_currentIndex].isComplete &&
        _currentIndex == _steps.length - 1) {
      _completeExercise();
    }
  }

  void _removeItem(int index) {
    setState(() {
      _steps[_currentIndex].items.removeAt(index);
    });
  }

  void _goToNextStep() {
    if (!_steps[_currentIndex].isComplete) {
      return;
    }
    if (_currentIndex == _steps.length - 1) {
      _completeExercise();
      return;
    }
    setState(() {
      _currentIndex++;
      _controller.clear();
    });
  }

  Future<void> _completeExercise() async {
    session
      ..endTime = DateTime.now()
      ..extraData = {
        'responses': _steps
            .map(
              (step) => {
                'sense': step.sense,
                'items': List<String>.from(step.items),
              },
            )
            .toList(),
      };
    await ExerciseService().saveSession(session);

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_currentIndex];
    final progress = (_currentIndex + 1) / _steps.length;

    return ExerciseScaffold(
      title: '5-4-3-2-1 Grounding',
      subtitle: 'Use your senses to anchor in the present',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notice what is around you. Add the sensations to complete each step, then move on to the next sense.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Step ${_currentIndex + 1} of ${_steps.length}',
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    step.sense,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(step.prompt),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(value: progress.clamp(0, 1)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: step.items
                .asMap()
                .entries
                .map(
                  (entry) => Chip(
                    label: Text(entry.value),
                    onDeleted: () => _removeItem(entry.key),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: 'Add what you ${step.verbPresent}',
              helperText:
                  '${step.items.length}/${step.count} logged for this sense',
              suffixIcon: IconButton(
                onPressed: _controller.text.isEmpty ? null : _addItem,
                icon: const Icon(Icons.add_circle_outline),
              ),
            ),
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _addItem(),
          ),
          const Spacer(),
          FilledButton.icon(
            onPressed: step.isComplete ? _goToNextStep : null,
            icon: Icon(
              _steps.last == step ? Icons.flag : Icons.arrow_forward,
            ),
            label: Text(_steps.last == step ? 'Finish' : 'Next sense'),
          ),
        ],
      ),
    );
  }
}

class _GroundingStep {
  _GroundingStep({
    required this.sense,
    required this.prompt,
    required this.count,
    required this.verbPresent,
  });

  final String sense;
  final String prompt;
  final int count;
  final String verbPresent;
  final List<String> items = <String>[];

  bool get isComplete => items.length >= count;
}

List<_GroundingStep> _buildSteps() {
  return [
    _GroundingStep(
      sense: 'See',
      prompt: 'Name five things you can see in your surroundings.',
      verbPresent: 'see',
      count: 5,
    ),
    _GroundingStep(
      sense: 'Touch',
      prompt: 'Notice four things you can touch or feel against your skin.',
      verbPresent: 'feel',
      count: 4,
    ),
    _GroundingStep(
      sense: 'Hear',
      prompt: 'Listen for three distinct sounds around you.',
      verbPresent: 'hear',
      count: 3,
    ),
    _GroundingStep(
      sense: 'Smell',
      prompt: 'Identify two different smells nearby, even if they are subtle.',
      verbPresent: 'smell',
      count: 2,
    ),
    _GroundingStep(
      sense: 'Taste',
      prompt: 'Notice one thing you can taste or a flavor lingering.',
      verbPresent: 'taste',
      count: 1,
    ),
  ];
}
