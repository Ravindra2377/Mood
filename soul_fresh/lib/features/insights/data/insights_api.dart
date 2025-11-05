import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:soul_fresh/features/insights/models/insights_data.dart';
import 'package:soul_fresh/state/app_state.dart';
import 'package:soul_fresh/services/api_client.dart';

final insightsApiProvider = Provider<InsightsApi>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return InsightsApi(apiClient);
});

class InsightsApi {
  InsightsApi(this._apiClient);

  final ApiClient _apiClient;

  Future<InsightsData> getInsights() async {
    final response = await _apiClient.getInsights();
    return InsightsData.fromJson(response);
  }
}
