import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/config.dart';
import '../main.dart' show skipOtp;
import '../services/secure_storage_service.dart';

// Provider for AuthService
final authServiceProvider = Provider<AuthService>((ref) {
  final storage = ref.watch(secureStorageServiceProvider);
  return AuthService(storage);
});

/// Authentication service for handling login, signup, and session management
class AuthService {
  final SecureStorageService _storage;
  late final Dio _dio;

  AuthService(this._storage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
  }

  /// Sign up with email and password. Does NOT trigger OTP by itself; callers
  /// should follow with [requestOtp] so the UI can surface any preview code in
  /// dev mode.
  Future<Map<String, dynamic>> signup(String email, String password) async {
    if (skipOtp) {
      // Mock signup for testing without backend
      await _storage.saveAccessToken('dummy-token-$email');
      await _storage.saveUserEmail(email);
      return {'success': true, 'message': 'Mock signup successful'};
    }

    try {
      final response = await _dio.post(
        '/auth/signup',
        data: {
          'email': email,
          'password': password,
        },
      );
      // Do not request OTP here; let the caller handle it so any
      // preview code can be shown to the user in dev environments.
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Login with email and password
  Future<Map<String, dynamic>> login(String email, String password) async {
    if (skipOtp) {
      // Mock login for testing without backend
      await _storage.saveAccessToken('dummy-token-$email');
      await _storage.saveUserEmail(email);
      return {'access_token': 'dummy-token-$email', 'success': true};
    }

    try {
      final response = await _dio.post(
        '/auth/token',
        data: {
          'username': email, // FastAPI OAuth2 uses 'username' field
          'password': password,
          'grant_type': 'password',
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );

      final data = response.data as Map<String, dynamic>;

      // Save tokens and user info
      await _storage.saveAccessToken(data['access_token'] as String);
      if (data.containsKey('refresh_token')) {
        await _storage.saveRefreshToken(data['refresh_token'] as String);
      }
      await _storage.saveUserEmail(email);

      return data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Request OTP
  /// Request OTP and return preview code in dev mode if available.
  Future<String?> requestOtp(String email) async {
    if (skipOtp) {
      // Mock OTP request for testing
      return '123456';
    }

    try {
      final res = await _dio.post('/auth/otp/request', data: {'email': email});
      final data = res.data;
      if (data is Map &&
          data['preview'] is Map &&
          (data['preview'] as Map).containsKey('code')) {
        return (data['preview'] as Map)['code']?.toString();
      }
      return null;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Forgot password: request a 6-digit code to be emailed.
  Future<String?> requestPasswordResetOtp(String email) async {
    if (skipOtp) {
      return '123456';
    }
    try {
      final res =
          await _dio.post('/auth/password-otp/request', data: {'email': email});
      final data = res.data;
      if (data is Map &&
          data['preview'] is Map &&
          (data['preview'] as Map).containsKey('code')) {
        return (data['preview'] as Map)['code']?.toString();
      }
      return null;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Forgot password: confirm the 6-digit code and set new password.
  Future<void> confirmPasswordResetOtp({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    if (skipOtp) {
      // No-op. In dev mode just pretend success.
      return;
    }
    try {
      await _dio.post(
        '/auth/password-otp/confirm',
        data: {
          'email': email,
          'code': code,
          'new_password': newPassword,
        },
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Verify OTP
  Future<Map<String, dynamic>> verifyOtp(String email, String code) async {
    if (skipOtp) {
      // Mock OTP verification for testing
      await _storage.saveAccessToken('dummy-token-$email');
      await _storage.saveUserEmail(email);
      return {'success': true, 'message': 'Mock OTP verified'};
    }

    try {
      final response = await _dio.post(
        '/auth/verify-otp',
        data: {
          'email': email,
          'code': code,
        },
      );

      final data = response.data as Map<String, dynamic>;

      // Save tokens and user info
      if (data.containsKey('access_token')) {
        await _storage.saveAccessToken(data['access_token'] as String);
      }
      if (data.containsKey('refresh_token')) {
        await _storage.saveRefreshToken(data['refresh_token'] as String);
      }
      await _storage.saveUserEmail(email);

      return data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      final token = await _storage.getAccessToken();
      final refresh = await _storage.getRefreshToken();
      if (token != null) {
        await _dio.post(
          '/auth/logout',
          data: refresh == null ? null : {'refresh_token': refresh},
          options: Options(
            headers: {'Authorization': 'Bearer $token'},
          ),
        );
      }
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

      final response = await _dio.post(
        '/auth/refresh',
        data: {
          'old_refresh_token': refreshToken,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final newAccess = data['access_token'] as String?;
      final newRefresh = data['refresh_token'] as String?;

      if ((newAccess ?? '').isEmpty || (newRefresh ?? '').isEmpty) {
        await _storage.clearAll();
        throw Exception('Session refresh failed. Please login again.');
      }

      await _storage.saveAccessToken(newAccess!);
      await _storage.saveRefreshToken(newRefresh!);
    } on DioException catch (_) {
      await _storage.clearAll();
      throw Exception('Session expired. Please login again.');
    } catch (_) {
      await _storage.clearAll();
      throw Exception('Session expired. Please login again.');
    }
  }

  /// Handle errors from API calls
  String _handleError(DioException error) {
    final response = error.response;
    String? detail;
    int? status;
    if (response != null) {
      status = response.statusCode;
      final data = response.data;
      if (data is Map && data.containsKey('detail')) {
        detail = data['detail']?.toString();
      } else if (data is String) {
        detail = data;
      }
    }

    // Friendly mappings for common backend errors
    final msg = (detail ?? '').toLowerCase();
    if (status == 400 &&
        (msg.contains('invalid or expired code') ||
            msg.contains('invalid code'))) {
      return 'That code is invalid or has expired. Please request a new one.';
    }
    if (status == 400 && msg.contains('invalid or expired token')) {
      return 'Your reset link has expired or is invalid. Request a new reset email.';
    }
    if (status == 401 && msg.contains('invalid credentials')) {
      return 'Email or password is incorrect.';
    }
    if (status == 429) {
      String base = 'Too many attempts. Please wait a minute and try again.';
      try {
        final remaining = response?.headers.value('X-RateLimit-Remaining') ??
            response?.headers.value('x-ratelimit-remaining');
        final retryAfter = response?.headers.value('Retry-After') ??
            response?.headers.value('retry-after');
        if (retryAfter != null && retryAfter.isNotEmpty) {
          base = 'Too many attempts. Try again in ${retryAfter}s.';
        }
        if (remaining != null && remaining.isNotEmpty) {
          base = '$base Attempts left: $remaining';
        }
      } catch (_) {}
      return base;
    }

    if (response != null) {
      if (detail != null && detail.isNotEmpty) {
        return detail; // fallback to backend detail
      }
      return 'Request failed with status ${response.statusCode}';
    }

    return 'Network error. Please check your connection.';
  }
}
