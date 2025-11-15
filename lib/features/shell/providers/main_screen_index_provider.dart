import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tracks the currently selected index for the main app shell.
final mainScreenIndexProvider = StateProvider<int>((ref) => 0);
