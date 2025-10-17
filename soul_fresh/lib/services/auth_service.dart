import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_client.dart';
import '../services/secure_storage_service.dart';

// Provider for AuthService
final authServiceProvider = Provider<AuthService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final storage = ref.watch(secureStorageServiceProvider);
  return AuthService(apiClient, storage);
});

/// Authentication service for handling login, signup, and session management
class AuthService {
  final ApiClient _apiClient;
  final SecureStorageService _storage;

  AuthService(this._apiClient, this._storage);

  /// Sign up with email and password
  Future<AuthResponse> signup({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _apiClient.signup(
        SignupRequest(email: email, password: password),
      );
      
      // After signup, login to get tokens
      return await login(email: email, password: password);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Login with email and password
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.login(
        LoginRequest(email: email, password: password),
      );

      // Save tokens and user info
      await _storage.saveAccessToken(response.accessToken);
      if (response.refreshToken != null) {
        await _storage.saveRefreshToken(response.refreshToken!);
      }
      await _storage.saveUserEmail(email);

      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Request OTP (legacy support)
  Future<void> requestOtp(String email) async {
    try {
      await _apiClient.requestOtp(OtpRequest(email: email));
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Verify OTP (legacy support)
  Future<AuthResponse> verifyOtp({
    required String email,
    required String code,
  }) async {
    try {
      final response = await _apiClient.verifyOtp(
        VerifyOtpRequest(email: email, code: code),
      );

      // Save tokens and user info
      await _storage.saveAccessToken(response.accessToken);
      if (response.refreshToken != null) {
        await _storage.saveRefreshToken(response.refreshToken!);
      }
      await _storage.saveUserEmail(email);

      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      await _apiClient.logout();
    } catch (e) {
      // Best effort - continue even if API call fails
    } finally {
      await _storage.clearAll();
    }
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    return await _storage.isLoggedIn();
  }

  /// Get current access token
  Future<String?> getAccessToken() async {
    return await _storage.getAccessToken();
  }

  /// Refresh access token (if backend supports it)
  Future<void> refreshToken() async {
    try {
      final refreshToken = await _storage.getRefreshToken();
      if (refreshToken == null) {
        throw Exception('No refresh token available');
      }

      // TODO: Implement refresh token endpoint call when backend supports it
      // For now, just throw to force re-login
      throw Exception('Token refresh not implemented');
    } catch (e) {
      await _storage.clearAll();
      throw Exception('Session expired. Please login again.');
    }
  }

  /// Handle errors from API calls
  String _handleError(Object error) {
    if (error is DioException) {
      final response = error.response;
      if (response != null) {
        final data = response.data;
        if (data is Map && data.containsKey('detail')) {
          return data['detail'].toString();
        }
        if (data is String) {
          return data;
        }
        return 'Request failed with status ${response.statusCode}';
      }
      return 'Network error. Please check your connection.';
    }
    return error.toString();
  }
}
