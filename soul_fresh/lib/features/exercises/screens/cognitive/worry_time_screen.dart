import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/exercise_models.dart';
import '../../services/exercise_service.dart';
import '../../widgets/exercise_scaffold.dart';

class WorryTimeScreen extends StatefulWidget {
  const WorryTimeScreen({super.key});

  @override
  State<WorryTimeScreen> createState() => _WorryTimeScreenState();
}

class _WorryTimeScreenState extends State<WorryTimeScreen> {
  late ExerciseSession session;
  static const int totalSeconds = 15 * 60;
  int remaining = totalSeconds;
  bool running = false;
  Timer? timer;
  final TextEditingController ctrl = TextEditingController();
  final List<String> worries = <String>[];

  @override
  void initState() {
    super.initState();
    session = ExerciseSession(
      exerciseId: 'worry_time',
      startTime: DateTime.now(),
    );
  }

  void _start() {
    if (running) {
      return;
    }
    setState(() {
      running = true;
    });
    timer = Timer.periodic(const Duration(seconds: 1), (Timer tick) {
      if (remaining > 0) {
        setState(() {
          remaining--;
        });
        return;
      }
      _complete();
    });
  }

  void _pause() {
    timer?.cancel();
    setState(() {
      running = false;
    });
  }

  void _resetTimer() {
    timer?.cancel();
    setState(() {
      running = false;
      remaining = totalSeconds;
    });
  }

  void _add() {
    final String text = ctrl.text.trim();
    if (text.isEmpty) {
      return;
    }
    setState(() {
      worries.add(text);
      ctrl.clear();
    });
  }

  Future<void> _complete() async {
    timer?.cancel();
    final int elapsed = totalSeconds - remaining;
    setState(() {
      running = false;
      remaining = 0;
    });

    session.endTime = DateTime.now();
    session.extraData = <String, dynamic>{
      'duration_seconds': elapsed.clamp(0, totalSeconds),
      'worries': worries,
    };

    await ExerciseService().saveSession(session);

    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Worry time finished'),
        content: const Text(
          'You captured your concerns during the scheduled window.',
        ),
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

  String _format(int seconds) {
    final int minutes = seconds ~/ 60;
    final int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    timer?.cancel();
    ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return ExerciseScaffold(
      title: 'Worry Time',
      subtitle: '15 Minutes',
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Give your worries a space, then return to your day.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Remaining time',
                            style: theme.textTheme.labelMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _format(remaining),
                            style: theme.textTheme.displaySmall,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        FilledButton.tonalIcon(
                          onPressed: running ? _pause : _start,
                          icon: Icon(running ? Icons.pause : Icons.play_arrow),
                          label: Text(running ? 'Pause' : 'Start'),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed:
                              remaining == totalSeconds ? null : _resetTimer,
                          child: const Text('Reset'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: ctrl,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Capture a worry',
                hintText: 'Write the worry exactly as it appears in your mind.',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _add(),
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                FilledButton.icon(
                  onPressed: _add,
                  icon: const Icon(Icons.add),
                  label: const Text('Add worry'),
                ),
                const SizedBox(width: 12),
                Text('${worries.length} saved'),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: worries.isEmpty
                  ? Center(
                      child: Text(
                        'Use this space to list every worry that shows up.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium,
                      ),
                    )
                  : ListView.separated(
                      itemBuilder: (context, index) => ListTile(
                        title: Text(worries[index]),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () {
                            setState(() {
                              worries.removeAt(index);
                            });
                          },
                        ),
                      ),
                      separatorBuilder: (_, __) => const Divider(height: 0),
                      itemCount: worries.length,
                    ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: worries.isEmpty && remaining > 0 ? null : _complete,
                child: const Text('Finish worry time'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
