import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  static ThemeData get lightTheme {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.whiteBg,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryPastel,
        onPrimary: AppColors.charcoal,
        secondary: AppColors.secondaryPastel,
        onSecondary: AppColors.charcoal,
        tertiary: AppColors.accentPastel,
        error: AppColors.error,
        onError: AppColors.charcoal,
        surface: AppColors.white,
        onSurface: AppColors.charcoal,
        background: AppColors.whiteBg,
        onBackground: AppColors.charcoal,
      ),
    );

    final textTheme = base.textTheme.copyWith(
      displayLarge: AppTypography.h1,
      displayMedium: AppTypography.h2,
      displaySmall: AppTypography.h3,
      headlineMedium: AppTypography.h3,
      headlineSmall: AppTypography.h4,
      titleLarge: AppTypography.h4,
      titleMedium: AppTypography.body1.copyWith(fontWeight: FontWeight.w600),
      titleSmall: AppTypography.label,
      bodyLarge: AppTypography.body1,
      bodyMedium: AppTypography.body2,
      bodySmall: AppTypography.labelSmall,
      labelLarge: AppTypography.button,
      labelMedium: AppTypography.label,
      labelSmall: AppTypography.labelSmall,
    );

    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.whiteBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.charcoal),
        titleTextStyle: AppTypography.h4,
      ),
      cardTheme: CardThemeData(
        color: AppColors.white,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.mediumGrey, width: 1),
        ),
        elevation: 0,
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: AppColors.lightGrey,
        selectedColor: AppColors.primaryPastel.withOpacity(0.2),
        pressElevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.mediumGrey),
        ),
        labelStyle: AppTypography.label.copyWith(color: AppColors.charcoal),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightGrey,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.mediumGrey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.mediumGrey, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.primaryPastel, width: 2),
        ),
        hintStyle: AppTypography.body2.copyWith(color: AppColors.darkGrey),
        labelStyle: AppTypography.label.copyWith(color: AppColors.darkGrey),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryPastel,
          foregroundColor: AppColors.charcoal,
          textStyle: AppTypography.button,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryPastel,
          textStyle: AppTypography.button,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          side: const BorderSide(color: AppColors.primaryPastel, width: 1.5),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accentPastel,
          textStyle: AppTypography.button.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primaryPastel,
        unselectedItemColor: AppColors.darkGrey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: AppTypography.label,
        unselectedLabelStyle: AppTypography.labelSmall,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.charcoal,
        contentTextStyle: AppTypography.body2.copyWith(color: AppColors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        titleTextStyle: AppTypography.h3,
        contentTextStyle: AppTypography.body1,
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: MaterialStateProperty.all(AppColors.primaryPastel.withOpacity(0.6)),
        radius: const Radius.circular(12),
      ),
    );
  }

  static ThemeData get darkTheme {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF101114),
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryPastel,
        onPrimary: AppColors.black,
        secondary: AppColors.secondaryPastel,
        onSecondary: AppColors.black,
        tertiary: AppColors.accentPastel,
        error: AppColors.error,
        onError: AppColors.black,
        surface: Color(0xFF191C1F),
        onSurface: AppColors.white,
        background: Color(0xFF101114),
        onBackground: AppColors.white,
      ),
    );

    final textTheme = base.textTheme.apply(
      fontFamily: AppTypography.secondaryFont,
      bodyColor: AppColors.white,
      displayColor: AppColors.white,
    ).copyWith(
      titleLarge: AppTypography.h3.copyWith(color: AppColors.white),
    );

    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF101114),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.white),
        titleTextStyle: AppTypography.h4,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF191C1F),
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Color(0xFF2A2D32), width: 1),
        ),
        elevation: 0,
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: const Color(0xFF2A2D32),
        selectedColor: AppColors.primaryPastel.withOpacity(0.25),
        labelStyle: AppTypography.label.copyWith(color: AppColors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF373B40)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1F2327),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFF373B40)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFF373B40)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.primaryPastel, width: 2),
        ),
        hintStyle: AppTypography.body2.copyWith(color: AppColors.lightGrey),
        labelStyle: AppTypography.label.copyWith(color: AppColors.lightGrey),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryPastel,
          foregroundColor: AppColors.black,
          textStyle: AppTypography.button,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryPastel,
          side: const BorderSide(color: AppColors.primaryPastel, width: 1.2),
          textStyle: AppTypography.button,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accentPastel,
          textStyle: AppTypography.button,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF191C1F),
        selectedItemColor: AppColors.primaryPastel,
        unselectedItemColor: Color(0xFF7C8086),
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: AppTypography.label,
        unselectedLabelStyle: AppTypography.labelSmall,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF2A2D32),
        contentTextStyle: AppTypography.body2.copyWith(color: AppColors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFF191C1F),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        titleTextStyle: AppTypography.h3.copyWith(color: AppColors.white),
        contentTextStyle: AppTypography.body1.copyWith(color: AppColors.white),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: MaterialStateProperty.all(AppColors.primaryPastel.withOpacity(0.5)),
        radius: const Radius.circular(12),
      ),
    );
  }
}