import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/self_help/self_help_models.dart';
import '../screens/check_in_screen.dart';

class CheckInCard extends ConsumerWidget {
  const CheckInCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '👋 ',
                  style: TextStyle(fontSize: 24),
                ),
                Expanded(
                  child: Text(
                    'Hi Olivia, how are you today?',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _MoodButton(
                  emoji: '😊',
                  label: 'Great',
                  mood: MoodType.great,
                  color: Colors.green,
                ),
                _MoodButton(
                  emoji: '😌',
                  label: 'Good',
                  mood: MoodType.good,
                  color: Colors.lightGreen,
                ),
                _MoodButton(
                  emoji: '😐',
                  label: 'Okay',
                  mood: MoodType.okay,
                  color: Colors.amber,
                ),
                _MoodButton(
                  emoji: '😟',
                  label: 'Not Good',
                  mood: MoodType.notGood,
                  color: Colors.orange,
                ),
                _MoodButton(
                  emoji: '😢',
                  label: 'Bad',
                  mood: MoodType.bad,
                  color: Colors.deepOrange,
                ),
                _MoodButton(
                  emoji: '😰',
                  label: 'Crisis',
                  mood: MoodType.crisis,
                  color: Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MoodButton extends StatelessWidget {
  final String emoji;
  final String label;
  final MoodType mood;
  final Color color;

  const _MoodButton({
    required this.emoji,
    required this.label,
    required this.mood,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CheckInScreen(initialMood: mood),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: TextStyle(fontSize: 20)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: color.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}