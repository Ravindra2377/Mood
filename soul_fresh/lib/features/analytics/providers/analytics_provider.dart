import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/analytics/analytics_models.dart';
import '../services/analytics_service.dart';

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService();
});

final analyticsSnapshotProvider = FutureProvider<AnalyticsSnapshot>((ref) async {
  final service = ref.watch(analyticsServiceProvider);
  return service.getAnalyticsSnapshot();
});

final exerciseStatsProvider = FutureProvider<ExerciseStats>((ref) async {
  final service = ref.watch(analyticsServiceProvider);
  return service.getExerciseStats(days: 7);
});

final selfHelpStatsProvider = FutureProvider<SelfHelpStats>((ref) async {
  final service = ref.watch(analyticsServiceProvider);
  return service.getSelfHelpStats(days: 7);
});

final moodStatsProvider = FutureProvider<MoodStats>((ref) async {
  final service = ref.watch(analyticsServiceProvider);
  return service.getMoodStats(days: 7);
});

