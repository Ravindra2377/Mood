import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Lightweight container describing how to render a sentiment chip.
class JournalSentimentStyle {
  const JournalSentimentStyle({
    required this.background,
    required this.foreground,
    required this.icon,
  });

  final Color background;
  final Color foreground;
  final IconData icon;
}

/// Maps a sentiment label into a style for chips and badges.
JournalSentimentStyle journalSentimentStyleFor(String? sentiment) {
  final normalized = sentiment?.trim().toLowerCase() ?? '';
  switch (normalized) {
    case 'positive':
      return const JournalSentimentStyle(
        background: Color(0x2B90EE90),
        foreground: AppColors.success,
        icon: Icons.sentiment_satisfied_alt,
      );
    case 'negative':
      return const JournalSentimentStyle(
        background: Color(0x29FFB6B9),
        foreground: AppColors.error,
        icon: Icons.sentiment_dissatisfied,
      );
    case 'neutral':
      return const JournalSentimentStyle(
        background: Color(0xB3F5F3F0),
        foreground: AppColors.darkGrey,
        icon: Icons.sentiment_neutral,
      );
    default:
      return const JournalSentimentStyle(
        background: Color(0x8CF5F3F0),
        foreground: AppColors.mediumGrey,
        icon: Icons.insights_outlined,
      );
  }
}
