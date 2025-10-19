import 'package:flutter/material.dart';

/// App color palette
class AppColors {
  AppColors._();

  // Primary brand colors
  static const Color primary = Color(0xFF2F3A5F);
  static const Color primaryLight = Color(0xFF4A5A8F);
  static const Color primaryDark = Color(0xFF1A2340);

  // Pastel accent colors
  static const Color pastelBlue = Color(0xFFD0F0FD);
  static const Color pastelPurple = Color(0xFFE8B4F0);
  static const Color pastelGreen = Color(0xFFA8E6CF);
  static const Color pastelYellow = Color(0xFFFFE066);
  static const Color pastelPink = Color(0xFFFFB4D4);
  static const Color pastelOrange = Color(0xFFFFD4B4);

  // Semantic colors
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color warning = Color(0xFFFF9800);
  static const Color warningLight = Color(0xFFFFF3E0);
  static const Color error = Color(0xFFF44336);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFFE3F2FD);

  // Neutral colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);

  // Background colors
  static const Color backgroundLight = Color(0xFFF7F9FC);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);

  // Text colors
  static const Color textPrimaryLight = Color(0xFF212121);
  static const Color textSecondaryLight = Color(0xFF757575);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);

  // Mood colors
  static const Color moodAngry = Color(0xFFFF5252);
  static const Color moodSad = Color(0xFF5C6BC0);
  static const Color moodNeutral = Color(0xFFFFCA28);
  static const Color moodHappy = Color(0xFF66BB6A);
  static const Color moodVeryHappy = Color(0xFF26A69A);

  // Activity colors
  static const Color activityYoga = pastelPurple;
  static const Color activityJournal = pastelBlue;
  static const Color activityExercise = pastelGreen;
  static const Color activityMeditation = pastelOrange;
}
