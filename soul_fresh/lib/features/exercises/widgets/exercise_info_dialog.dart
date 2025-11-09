import 'package:flutter/material.dart';

import '../data/exercise_info_data.dart';
import '../models/exercise_info_model.dart';

class ExerciseInfoDialog extends StatelessWidget {
  final ExerciseInfo info;
  final VoidCallback onStartExercise;

  const ExerciseInfoDialog({
    super.key,
    required this.info,
    required this.onStartExercise,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _DialogHeader(info: info),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _DialogSection(
                      icon: Icons.psychology,
                      title: 'How it works',
                      color: info.color,
                      body: info.howItWorks,
                    ),
                    const SizedBox(height: 20),
                    _DialogSection(
                      icon: Icons.favorite,
                      title: 'Benefits',
                      color: info.color,
                      bullets: info.benefits,
                    ),
                    const SizedBox(height: 20),
                    _DialogSection(
                      icon: Icons.schedule,
                      title: 'When to use',
                      color: info.color,
                      body: info.whenToUse,
                    ),
                    const SizedBox(height: 20),
                    _DialogSection(
                      icon: Icons.list,
                      title: 'Steps',
                      color: info.color,
                      numberedSteps: info.steps,
                    ),
                    if (info.warningNote != null) ...<Widget>[
                      const SizedBox(height: 20),
                      _WarningCallout(
                        message: info.warningNote!,
                        color: info.color,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            _DialogActions(info: info, onStartExercise: onStartExercise),
          ],
        ),
      ),
    );
  }
}

class _DialogHeader extends StatelessWidget {
  const _DialogHeader({required this.info});

  final ExerciseInfo info;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: info.color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              shape: BoxShape.circle,
            ),
            child: Icon(info.icon, size: 32, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  info.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: <Widget>[
                    const Icon(
                      Icons.access_time,
                      size: 16,
                      color: Colors.white70,
                    ),
                    Text(
                      '${info.estimatedDuration.inMinutes} min',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const Icon(Icons.category, size: 16, color: Colors.white70),
                    Text(
                      info.category,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

class _DialogSection extends StatelessWidget {
  const _DialogSection({
    required this.icon,
    required this.title,
    required this.color,
    this.body,
    this.bullets,
    this.numberedSteps,
  });

  final IconData icon;
  final String title;
  final Color color;
  final String? body;
  final List<String>? bullets;
  final List<String>? numberedSteps;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (body != null)
          Text(
            body!,
            style:
                Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
          ),
        if (bullets != null)
          ...bullets!.map(
            (String item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 6,
                    height: 6,
                    decoration:
                        BoxDecoration(color: color, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (numberedSteps != null)
          ...numberedSteps!.asMap().entries.map(
                (MapEntry<int, String> entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${entry.key + 1}',
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            entry.value,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ],
    );
  }
}

class _WarningCallout extends StatelessWidget {
  const _WarningCallout({required this.message, required this.color});

  final String message;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final Color borderColor = color.withValues(alpha: 0.3);
    final Color textColor =
        color is MaterialColor ? (color as MaterialColor).shade900 : color;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(Icons.warning_amber, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: textColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _DialogActions extends StatelessWidget {
  const _DialogActions({required this.info, required this.onStartExercise});

  final ExerciseInfo info;
  final VoidCallback onStartExercise;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Maybe later'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: FilledButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                onStartExercise();
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start exercise'),
              style: FilledButton.styleFrom(
                backgroundColor: info.color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void showExerciseInfoDialog(
  BuildContext context, {
  required String exerciseId,
  required VoidCallback onStartExercise,
}) {
  final ExerciseInfo? info = ExerciseInfoDatabase.getExerciseInfo(exerciseId);
  if (info == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exercise information unavailable.')),
    );
    return;
  }

  showDialog<void>(
    context: context,
    builder: (BuildContext dialogContext) => ExerciseInfoDialog(
      info: info,
      onStartExercise: onStartExercise,
    ),
  );
}
