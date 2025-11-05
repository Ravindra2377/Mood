import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/api_client.dart';
import '../../../state/app_state.dart';
import '../models/insights_data.dart';

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
