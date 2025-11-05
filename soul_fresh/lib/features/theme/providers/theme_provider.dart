import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Simple theme controller that keeps track of the active [ThemeMode].
/// TODO: persist to shared preferences when the storage layer is ready.
final themeProvider = StateNotifierProvider<ThemeController, ThemeMode>(
    (ref) => ThemeController(),);

class ThemeController extends StateNotifier<ThemeMode> {
  ThemeController() : super(ThemeMode.system);

  void setThemeMode(ThemeMode mode) {
    state = mode;
  }
}
