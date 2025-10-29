import 'package:flutter/material.dart';

import '../../models/exercise_models.dart';
import '../../services/exercise_service.dart';
import '../../widgets/exercise_scaffold.dart';

class GratitudeJournalScreen extends StatefulWidget {
  const GratitudeJournalScreen({Key? key}) : super(key: key);

  @override
  State<GratitudeJournalScreen> createState() => _GratitudeJournalScreenState();
}

class _GratitudeJournalScreenState extends State<GratitudeJournalScreen> {
  static const int _minimumItems = 3;

  late ExerciseSession session;
  final List<_GratitudeEntry> _entries =
      List.generate(_minimumItems, (_) => _GratitudeEntry());
  final TextEditingController _reflectionController = TextEditingController();

  bool _reminderEnabled = false;
  int _moodBefore = 6;
  int? _moodAfter;

  @override
  void initState() {
    super.initState();
    session = ExerciseSession(
      exerciseId: 'gratitude_journal',
      startTime: DateTime.now(),
    );
    session.moodBefore = _moodBefore;
  }

  @override
  void dispose() {
    for (final entry in _entries) {
      entry.dispose();
    }
    _reflectionController.dispose();
    super.dispose();
  }

  void _addEntry() {
    setState(() {
      _entries.add(_GratitudeEntry());
    });
  }

  Future<void> _completeExercise() async {
    FocusScope.of(context).unfocus();

    final filledEntries = _entries
        .where((entry) => entry.gratitude.trim().isNotEmpty)
        .map((entry) => {
              'gratitude': entry.gratitude.trim(),
              'why': entry.reason.trim(),
            })
        .toList();

    if (filledEntries.length < _minimumItems) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Capture at least $_minimumItems gratitudes to finish today\'s entry.',
          ),
        ),
      );
      return;
    }

    session
      ..endTime = DateTime.now()
      ..moodBefore = _moodBefore
      ..moodAfter = _moodAfter
      ..notes = _reflectionController.text.trim().isEmpty
          ? null
          : _reflectionController.text.trim()
      ..extraData = {
        'gratitudes': filledEntries,
        'reminder_enabled': _reminderEnabled,
        'total_count': filledEntries.length,
      };

    await ExerciseService().saveSession(session);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gratitude saved. See you tomorrow!')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return ExerciseScaffold(
      title: 'Gratitude Journal',
      subtitle: 'Note 3 specific wins from today',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMoodRow(),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              children: [
                Text(
                  'Today I\'m grateful for…',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                for (var index = 0; index < _entries.length; index++)
                  _GratitudeCard(
                    index: index,
                    entry: _entries[index],
                    onDelete: _entries.length > _minimumItems
                        ? () {
                            setState(() {
                              _entries[index].dispose();
                              _entries.removeAt(index);
                            });
                          }
                        : null,
                  ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _addEntry,
                  icon: const Icon(Icons.add),
                  label: const Text('Add another moment'),
                ),
                const SizedBox(height: 24),
                Text(
                  'Reflection',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _reflectionController,
                  decoration: const InputDecoration(
                    hintText:
                        'Notice any themes, surprises, or feelings that emerged.',
                    border: OutlineInputBorder(),
                  ),
                  minLines: 3,
                  maxLines: 5,
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _reminderEnabled,
                  onChanged: (value) {
                    setState(() {
                      _reminderEnabled = value;
                    });
                  },
                  title: const Text('Send me a reminder to journal tomorrow'),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _completeExercise,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Save gratitude entry'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mood check-in',
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        _MoodSlider(
          label: 'Before journaling',
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
          label: 'After journaling',
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

class _GratitudeEntry {
  _GratitudeEntry()
      : gratitudeController = TextEditingController(),
        reasonController = TextEditingController();

  final TextEditingController gratitudeController;
  final TextEditingController reasonController;

  String get gratitude => gratitudeController.text;
  String get reason => reasonController.text;

  void dispose() {
    gratitudeController.dispose();
    reasonController.dispose();
  }
}

class _GratitudeCard extends StatelessWidget {
  const _GratitudeCard({
    required this.index,
    required this.entry,
    this.onDelete,
  });

  final int index;
  final _GratitudeEntry entry;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  child: Text('${index + 1}'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Gratitude #${index + 1}',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                if (onDelete != null)
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: entry.gratitudeController,
              decoration: const InputDecoration(
                labelText: 'What happened today?',
                hintText: 'A specific moment, person, or detail…',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: entry.reasonController,
              decoration: const InputDecoration(
                labelText: 'Why does this matter to you?',
                hintText: 'How did it make you feel or what did it change?',
                border: OutlineInputBorder(),
              ),
              minLines: 2,
              maxLines: 3,
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
