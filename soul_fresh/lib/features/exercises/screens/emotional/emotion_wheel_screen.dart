import 'package:flutter/material.dart';

import '../../models/exercise_models.dart';
import '../../services/exercise_service.dart';
import '../../widgets/exercise_scaffold.dart';

class EmotionWheelScreen extends StatefulWidget {
  const EmotionWheelScreen({Key? key}) : super(key: key);

  @override
  State<EmotionWheelScreen> createState() => _EmotionWheelScreenState();
}

class _EmotionWheelScreenState extends State<EmotionWheelScreen> {
  late ExerciseSession session;

  final TextEditingController _triggerController = TextEditingController();
  final TextEditingController _needController = TextEditingController();
  final TextEditingController _actionController = TextEditingController();

  String? _primary;
  String? _secondary;
  String? _tertiary;
  double _intensity = 5;
  int _moodBefore = 5;
  int? _moodAfter;

  @override
  void initState() {
    super.initState();
    session = ExerciseSession(
      exerciseId: 'emotion_wheel',
      startTime: DateTime.now(),
    );
    session.moodBefore = _moodBefore;
  }

  @override
  void dispose() {
    _triggerController.dispose();
    _needController.dispose();
    _actionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();

    if (_primary == null || _secondary == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Choose at least a primary and secondary emotion.')),
      );
      return;
    }

    session
      ..endTime = DateTime.now()
      ..moodBefore = _moodBefore
      ..moodAfter = _moodAfter
      ..notes = _actionController.text.trim().isEmpty
          ? null
          : _actionController.text.trim()
      ..extraData = {
        'primary': _primary,
        'secondary': _secondary,
        'tertiary': _tertiary,
        'intensity': _intensity.round(),
        'trigger': _triggerController.text.trim(),
        'need': _needController.text.trim(),
      };

    await ExerciseService().saveSession(session);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Emotion noted. Thanks for checking in.')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final secondaryOptions =
        _primary == null ? <String>[] : _emotionTree[_primary!]!.keys.toList();
    final tertiaryOptions = (_primary != null && _secondary != null)
        ? _emotionTree[_primary!]![_secondary!]!
        : <String>[];

    return ExerciseScaffold(
      title: 'Emotion Wheel',
      subtitle: 'Name, understand, respond',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMeter(),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              children: [
                _buildChipSection(
                  title: 'Primary emotion',
                  options: _emotionTree.keys.toList(),
                  selected: _primary,
                  onSelected: (value) {
                    setState(() {
                      _primary = value;
                      _secondary = null;
                      _tertiary = null;
                    });
                  },
                ),
                if (secondaryOptions.isNotEmpty)
                  _buildChipSection(
                    title: 'Secondary emotion',
                    options: secondaryOptions,
                    selected: _secondary,
                    onSelected: (value) {
                      setState(() {
                        _secondary = value;
                        _tertiary = null;
                      });
                    },
                  ),
                if (tertiaryOptions.isNotEmpty)
                  _buildChipSection(
                    title: 'Refine it further',
                    options: tertiaryOptions,
                    selected: _tertiary,
                    onSelected: (value) {
                      setState(() {
                        _tertiary = value;
                      });
                    },
                  ),
                const SizedBox(height: 12),
                Text(
                  'What sparked this emotion?',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _triggerController,
                  decoration: const InputDecoration(
                    hintText:
                        'A conversation, memory, body sensation, thought…',
                    border: OutlineInputBorder(),
                  ),
                  minLines: 2,
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                Text(
                  'What do you need?',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _needController,
                  decoration: const InputDecoration(
                    hintText: 'Comfort, clarity, movement, connection…',
                    border: OutlineInputBorder(),
                  ),
                  minLines: 2,
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                Text(
                  'Next supportive action',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _actionController,
                  decoration: const InputDecoration(
                    hintText:
                        'E.g. "Message a friend" or "Take 5 grounding breaths"',
                    border: OutlineInputBorder(),
                  ),
                  minLines: 2,
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Save emotion check-in'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeter() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Intensity',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
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
            const SizedBox(height: 12),
            _MoodSlider(
              label: 'Mood before check-in',
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
              label: 'Mood after naming it',
              value: (_moodAfter ?? _moodBefore).toDouble(),
              onChanged: (value) {
                setState(() {
                  _moodAfter = value.round();
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChipSection({
    required String title,
    required List<String> options,
    required String? selected,
    required ValueChanged<String> onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options
              .map(
                (option) => ChoiceChip(
                  label: Text(option),
                  selected: selected == option,
                  onSelected: (_) => onSelected(option),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 16),
      ],
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

const Map<String, Map<String, List<String>>> _emotionTree = {
  'Joy': {
    'Optimistic': ['Inspired', 'Hopeful', 'Eager'],
    'Proud': ['Confident', 'Valued', 'Accomplished'],
    'Content': ['Relaxed', 'Grateful', 'Satisfied'],
  },
  'Trust': {
    'Connected': ['Supported', 'Seen', 'Loved'],
    'Safe': ['Grounded', 'Secure', 'Settled'],
    'Curious': ['Open', 'Interested', 'Engaged'],
  },
  'Fear': {
    'Anxious': ['Uneasy', 'On edge', 'Overwhelmed'],
    'Vulnerable': ['Exposed', 'Insecure', 'Fragile'],
    'Worried': ['Concerned', 'Apprehensive', 'Alert'],
  },
  'Sadness': {
    'Down': ['Heavy', 'Low energy', 'Disappointed'],
    'Hurt': ['Lonely', 'Ignored', 'Misunderstood'],
    'Tired': ['Exhausted', 'Drained', 'Unmotivated'],
  },
  'Anger': {
    'Frustrated': ['Annoyed', 'Irritated', 'Impatient'],
    'Threatened': ['Defensive', 'Hostile', 'Judgmental'],
    'Resentful': ['Bitter', 'Jealous', 'Indignant'],
  },
  'Surprise': {
    'Excited': ['Amazed', 'Moved', 'Energized'],
    'Confused': ['Disoriented', 'Startled', 'Unsure'],
    'Astonished': ['Shocked', 'Speechless', 'Wide-eyed'],
  },
  'Disgust': {
    'Withdrawn': ['Distant', 'Disconnected', 'Apathetic'],
    'Aversion': ['Repulsed', 'Grossed out', 'Bothered'],
    'Contempt': ['Dismissive', 'Superior', 'Judgmental'],
  },
  'Anticipation': {
    'Alert': ['Ready', 'Prepared', 'Focused'],
    'Motivated': ['Driven', 'Determined', 'Purposeful'],
    'Restless': ['Impatient', 'Agitated', 'Keyed up'],
  },
};
