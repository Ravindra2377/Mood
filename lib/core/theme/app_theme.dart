import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryPastel,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.whiteBg,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.whiteBg,
        foregroundColor: AppColors.charcoal,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTypography.h4.copyWith(
          color: AppColors.charcoal,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        shadowColor: AppColors.lightGrey.withOpacity(0.3),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryPastel,
          foregroundColor: AppColors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: AppTypography.button,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryPastel,
          side: BorderSide(color: AppColors.primaryPastel, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: AppTypography.button,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightGrey,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primaryPastel, width: 2),
        ),
        labelStyle: AppTypography.body2.copyWith(
          color: AppColors.darkGrey,
        ),
        hintStyle: AppTypography.body2.copyWith(
          color: AppColors.mediumGrey,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: AppTypography.h1,
        displayMedium: AppTypography.h2,
        displaySmall: AppTypography.h3,
        headlineMedium: AppTypography.h4,
        bodyLarge: AppTypography.body1,
        bodyMedium: AppTypography.body2,
        labelLarge: AppTypography.label,
        labelSmall: AppTypography.labelSmall,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primaryPastel,
        unselectedItemColor: AppColors.mediumGrey,
        selectedLabelStyle: AppTypography.labelSmall,
        unselectedLabelStyle: AppTypography.labelSmall,
        elevation: 8,
        shadowColor: AppColors.lightGrey.withOpacity(0.3),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryPastel,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: AppColors.charcoal,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.charcoal,
        foregroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTypography.h4.copyWith(
          color: AppColors.white,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkGrey,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        shadowColor: AppColors.black.withOpacity(0.3),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryPastel,
          foregroundColor: AppColors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: AppTypography.button,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryPastel,
          side: BorderSide(color: AppColors.primaryPastel, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: AppTypography.button,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkGrey,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primaryPastel, width: 2),
        ),
        labelStyle: AppTypography.body2.copyWith(
          color: AppColors.lightGrey,
        ),
        hintStyle: AppTypography.body2.copyWith(
          color: AppColors.mediumGrey,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: AppTypography.h1.copyWith(color: AppColors.white),
        displayMedium: AppTypography.h2.copyWith(color: AppColors.white),
        displaySmall: AppTypography.h3.copyWith(color: AppColors.white),
        headlineMedium: AppTypography.h4.copyWith(color: AppColors.white),
        bodyLarge: AppTypography.body1.copyWith(color: AppColors.white),
        bodyMedium: AppTypography.body2.copyWith(color: AppColors.white),
        labelLarge: AppTypography.label.copyWith(color: AppColors.white),
        labelSmall: AppTypography.labelSmall.copyWith(color: AppColors.white),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkGrey,
        selectedItemColor: AppColors.primaryPastel,
        unselectedItemColor: AppColors.mediumGrey,
        selectedLabelStyle: AppTypography.labelSmall,
        unselectedLabelStyle: AppTypography.labelSmall,
        elevation: 8,
        shadowColor: AppColors.black.withOpacity(0.3),
      ),
    );
  }
}