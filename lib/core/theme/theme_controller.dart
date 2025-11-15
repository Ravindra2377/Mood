import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadTheme();
  }

  static const _themeKey = 'theme_mode';

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final storedIndex = prefs.getInt(_themeKey);

    if (!mounted) {
      return;
    }

    if (storedIndex == null ||
        storedIndex < 0 ||
        storedIndex >= ThemeMode.values.length) {
      state = ThemeMode.system;
      return;
    }

    state = ThemeMode.values[storedIndex];
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    if (state == themeMode) {
      return;
    }

    state = themeMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, themeMode.index);
  }

  Future<void> toggleTheme() async {
    switch (state) {
      case ThemeMode.light:
        await setThemeMode(ThemeMode.dark);
        break;
      case ThemeMode.dark:
        await setThemeMode(ThemeMode.light);
        break;
      case ThemeMode.system:
        await setThemeMode(ThemeMode.light);
        break;
    }
  }
}
