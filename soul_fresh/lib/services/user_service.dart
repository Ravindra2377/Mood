import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/app_state.dart';
import 'api_client.dart';

/// Service for user profile API calls
class UserService {
  UserService(this._apiClient);

  final ApiClient _apiClient;

  /// Fetch user profile
  Future<ProfileRead> getUserProfile() async {
    try {
      return await _apiClient.getProfile();
    } catch (e) {
      throw Exception('Failed to fetch user profile: $e');
    }
  }

  /// Update user profile
  Future<ProfileRead> updateUserProfile(ProfileUpdate update) async {
    try {
      return await _apiClient.updateProfile(update);
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
final userProfileProvider = FutureProvider<ProfileRead>((ref) async {
  final userService = ref.watch(userServiceProvider);
  return await userService.getUserProfile();
});
