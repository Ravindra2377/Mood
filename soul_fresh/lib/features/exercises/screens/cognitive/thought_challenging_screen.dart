import 'package:flutter/material.dart';
import '../../models/exercise_models.dart';
import '../../services/exercise_service.dart';
import '../../widgets/exercise_scaffold.dart';

class ThoughtChallengingScreen extends StatefulWidget {
  const ThoughtChallengingScreen({super.key});

  @override
  State<ThoughtChallengingScreen> createState() =>
      _ThoughtChallengingScreenState();
}

class _ThoughtChallengingScreenState extends State<ThoughtChallengingScreen> {
  late ExerciseSession session;
  final List<TextEditingController> ctrls = List.generate(
    5,
    (_) => TextEditingController(),
  );
  int step = 0;
  final List<String> titles = <String>[
    'Negative Thought',
    'Evidence Supporting It',
    'Evidence Against It',
    'Alternative Perspective',
    'Balanced Thought',
  ];

  final List<String> hints = <String>[
    'What is the automatic thought you want to challenge?',
    'List reasons or facts that make the thought feel true.',
    'Note any facts or experiences that show the thought may be inaccurate.',
    'Write a kinder or more objective way to view the situation.',
    'Summarise a balanced statement you can revisit later.',
  ];

  @override
  void initState() {
    super.initState();
    session = ExerciseSession(
      exerciseId: 'thought_challenging',
      startTime: DateTime.now(),
    );
  }

  void _previous() {
    if (step == 0) {
      return;
    }
    setState(() {
      step--;
    });
  }

  void _next() {
    if (step < ctrls.length - 1) {
      setState(() {
        step++;
      });
      return;
    }
    _complete();
  }

  Future<void> _handleNext() async {
    if (ctrls[step].text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Please add something for ${titles[step].toLowerCase()}.',),),
      );
      return;
    }
    _next();
  }

  Future<void> _complete() async {
    session.endTime = DateTime.now();
    session.extraData = <String, String>{
      'negative': ctrls[0].text.trim(),
      'for': ctrls[1].text.trim(),
      'against': ctrls[2].text.trim(),
      'alternative': ctrls[3].text.trim(),
      'balanced': ctrls[4].text.trim(),
    };

    await ExerciseService().saveSession(session);

    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reflection saved'),
        content: const Text('Keep this balanced thought handy for next time.'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    for (final TextEditingController controller in ctrls) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return ExerciseScaffold(
      title: 'Thought Challenging',
      subtitle: 'CBT',
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Step ${step + 1} of ${titles.length}',
              style: theme.textTheme.labelMedium,
            ),
            const SizedBox(height: 8),
            Text(
              titles[step],
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TextField(
                controller: ctrls[step],
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  hintText: hints[step],
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List<Widget>.generate(
                ctrls.length,
                (int index) => ChoiceChip(
                  label: Text('Step ${index + 1}'),
                  selected: index == step,
                  onSelected: (bool selected) {
                    if (!selected) {
                      return;
                    }
                    setState(() {
                      step = index;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                TextButton(
                  onPressed: step == 0 ? null : _previous,
                  child: const Text('Back'),
                ),
                const Spacer(),
                OutlinedButton(
                  onPressed: () {
                    showModalBottomSheet<void>(
                      context: context,
                      showDragHandle: true,
                      builder: (context) => Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text('Your notes so far',
                                style: theme.textTheme.titleMedium,),
                            const SizedBox(height: 12),
                            for (int i = 0; i < ctrls.length; i++)
                              if (ctrls[i].text.trim().isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(titles[i],
                                          style: theme.textTheme.labelLarge,),
                                      const SizedBox(height: 4),
                                      Text(ctrls[i].text.trim()),
                                    ],
                                  ),
                                ),
                          ],
                        ),
                      ),
                    );
                  },
                  child: const Text('Review'),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: _handleNext,
                  child: Text(step == ctrls.length - 1 ? 'Finish' : 'Next'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
