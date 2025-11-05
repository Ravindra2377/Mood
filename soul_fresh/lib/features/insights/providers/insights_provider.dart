import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:soul_fresh/features/insights/data/insights_api.dart';
import 'package:soul_fresh/features/insights/models/insights_data.dart';

final insightsProvider =
    AsyncNotifierProvider<InsightsNotifier, InsightsData>(InsightsNotifier.new);

class InsightsNotifier extends AsyncNotifier<InsightsData> {
  @override
  Future<InsightsData> build() async {
    final api = ref.watch(insightsApiProvider);
    return api.getInsights();
  }
}
