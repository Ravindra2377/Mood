import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/insights_api.dart';
import '../models/insights_data.dart';

final insightsProvider =
    AsyncNotifierProvider<InsightsNotifier, InsightsData>(InsightsNotifier.new);

class InsightsNotifier extends AsyncNotifier<InsightsData> {
  @override
  Future<InsightsData> build() async {
    final api = ref.watch(insightsApiProvider);
    return api.getInsights();
  }
}
