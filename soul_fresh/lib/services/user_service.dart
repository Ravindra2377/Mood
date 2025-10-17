import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_client.dart';

/// Service for user profile API calls
class UserService {
  final ApiClient _apiClient;

  UserService(this._apiClient);

  /// Fetch user profile
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      return await _apiClient.getUserProfile();
    } catch (e) {
      throw Exception('Failed to fetch user profile: $e');
    }
  }

  /// Update user profile
  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    try {
      await _apiClient.updateUserProfile(data);
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }
}

/// Provider for UserService
final userServiceProvider = Provider<UserService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return UserService(apiClient);
});

/// Provider for user profile
final userProfileProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final userService = ref.watch(userServiceProvider);
  return await userService.getUserProfile();
});