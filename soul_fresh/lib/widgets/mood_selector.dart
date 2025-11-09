import 'package:flutter/material.dart';
import '../models/app_models.dart';

class MoodSelector extends StatelessWidget {
  final MoodLevel? selectedMood;
  final Function(MoodLevel) onMoodSelected;

  const MoodSelector({
    required this.selectedMood,
    required this.onMoodSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _MoodButton(
          mood: MoodLevel.angry,
          emoji: 'ðŸ˜ ',
          color: const Color(0xFFFF6B6B),
          isSelected: selectedMood == MoodLevel.angry,
          onTap: () => onMoodSelected(MoodLevel.angry),
        ),
        _MoodButton(
          mood: MoodLevel.sad,
          emoji: 'ðŸ˜¢',
          color: const Color(0xFF6BCFFF),
          isSelected: selectedMood == MoodLevel.sad,
          onTap: () => onMoodSelected(MoodLevel.sad),
        ),
        _MoodButton(
          mood: MoodLevel.neutral,
          emoji: 'ðŸ˜',
          color: const Color(0xFFB4A7D6),
          isSelected: selectedMood == MoodLevel.neutral,
          onTap: () => onMoodSelected(MoodLevel.neutral),
        ),
        _MoodButton(
          mood: MoodLevel.happy,
          emoji: 'ðŸ˜Š',
          color: const Color(0xFFFFD93D),
          isSelected: selectedMood == MoodLevel.happy,
          onTap: () => onMoodSelected(MoodLevel.happy),
        ),
        _MoodButton(
          mood: MoodLevel.veryHappy,
          emoji: 'ðŸ˜„',
          color: const Color(0xFF6BCB77),
          isSelected: selectedMood == MoodLevel.veryHappy,
          onTap: () => onMoodSelected(MoodLevel.veryHappy),
        ),
      ],
    );
  }
}

class _MoodButton extends StatelessWidget {
  final MoodLevel mood;
  final String emoji;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _MoodButton({
    required this.mood,
    required this.emoji,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: color.withValues(alpha: isSelected ? 1.0 : 0.3),
          shape: BoxShape.circle,
          border: isSelected ? Border.all(color: color, width: 3) : null,
        ),
        child: Center(
          child: Text(
            emoji,
            style: const TextStyle(fontSize: 28),
          ),
        ),
      ),
    );
  }
}
