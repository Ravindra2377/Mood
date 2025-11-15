import 'package:flutter/material.dart';

class QuickCheckInCard extends StatefulWidget {
  const QuickCheckInCard({Key? key}) : super(key: key);

  @override
  State<QuickCheckInCard> createState() => _QuickCheckInCardState();
}

class _QuickCheckInCardState extends State<QuickCheckInCard> {
  String? selectedMood;

  @override
  Widget build(BuildContext context) {
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
                const Text('❤️', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Text(
                  'How are you feeling right now?',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _MoodChip(
                  emoji: '😊',
                  label: 'Great',
                  isSelected: selectedMood == 'great',
                  onTap: () => setState(() => selectedMood = 'great'),
                ),
                _MoodChip(
                  emoji: '😌',
                  label: 'Good',
                  isSelected: selectedMood == 'good',
                  onTap: () => setState(() => selectedMood = 'good'),
                ),
                _MoodChip(
                  emoji: '😐',
                  label: 'Okay',
                  isSelected: selectedMood == 'okay',
                  onTap: () => setState(() => selectedMood = 'okay'),
                ),
                _MoodChip(
                  emoji: '😟',
                  label: 'Stressed',
                  isSelected: selectedMood == 'stressed',
                  onTap: () => setState(() => selectedMood = 'stressed'),
                ),
                _MoodChip(
                  emoji: '😢',
                  label: 'Sad',
                  isSelected: selectedMood == 'sad',
                  onTap: () => setState(() => selectedMood = 'sad'),
                ),
                _MoodChip(
                  emoji: '😰',
                  label: 'Anxious',
                  isSelected: selectedMood == 'anxious',
                  onTap: () => setState(() => selectedMood = 'anxious'),
                ),
              ],
            ),
            if (selectedMood != null) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Mood logged: $selectedMood ✓',
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: const Text('Get Personalized Suggestions'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MoodChip extends StatelessWidget {
  final String emoji;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _MoodChip({
    required this.emoji,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor
              : Colors.grey,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}