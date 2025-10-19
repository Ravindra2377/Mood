import 'package:flutter/material.dart';

/// App color configuration for SOUL Mental Health App
/// Centralized color palette with Material Design 3 compliance
class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF6C5CE7); // Purple
  static const Color primaryLight = Color(0xFF8B7FFF);
  static const Color primaryDark = Color(0xFF4A3BB3);

  // Background Colors
  static const Color backgroundColor = Color(0xFFF5F3FF);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color cardColor = Color(0xFFF9F7FF);

  // Text Colors
  static const Color textColor = Color(0xFF1F1F1F);
  static const Color secondaryText = Color(0xFF757575);
  static const Color hintText = Color(0xFFBDBDBD);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFE74C3C);
  static const Color info = Color(0xFF2196F3);

  // Tab Colors
  static const Color stressTabColor = Color(0xFFFF6B6B); // Red
  static const Color moodTabColor = Color(0xFFFFA500); // Orange
  static const Color sleepTabColor = Color(0xFF9C27B0); // Deep Purple
  static const Color mindfulnessTabColor = Color(0xFF00BCD4); // Cyan
  static const Color anxietyTabColor = Color(0xFFE91E63); // Pink
  static const Color wellnessTabColor = Color(0xFF4CAF50); // Green

  // Gradient Colors
  static const List<Color> stressGradient = [
    Color(0xFFFF6B6B),
    Color(0xFFFF8E8E),
  ];

  static const List<Color> moodGradient = [
    Color(0xFFFFA500),
    Color(0xFFFFB84D),
  ];

  static const List<Color> sleepGradient = [
    Color(0xFF9C27B0),
    Color(0xFFB469C8),
  ];

  static const List<Color> mindfulnessGradient = [
    Color(0xFF00BCD4),
    Color(0xFF4DD0E1),
  ];

  static const List<Color> anxietyGradient = [
    Color(0xFFE91E63),
    Color(0xFFEC407A),
  ];

  static const List<Color> wellnessGradient = [
    Color(0xFF4CAF50),
    Color(0xFF66BB6A),
  ];

  // Emotion Colors (Mood Tracking)
  static const Color emotionAngry = Color(0xFFFF6B6B);
  static const Color emotionSad = Color(0xFF5B9FE6);
  static const Color emotionNeutral = Color(0xFFFFD93D);
  static const Color emotionHappy = Color(0xFFFFA500);
  static const Color emotionExcited = Color(0xFFFF4081);

  // Overlay Colors
  static const Color overlayDark = Color(0x99000000);
  static const Color overlayLight = Color(0x99FFFFFF);

  // Divider Color
  static const Color dividerColor = Color(0xFFE0E0E0);

  // Border Color
  static const Color borderColor = Color(0xFFD0D0D0);
}
