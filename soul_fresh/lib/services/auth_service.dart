import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/config.dart';
import '../services/secure_storage_service.dart';
import '../main.dart' show skipOtp;

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

  /// Sign up with email and password
  Future<Map<String, dynamic>> signup(String email, String password) async {
    if (skipOtp) {
      // Mock signup for testing without backend
      await _storage.saveAccessToken('dummy-token-$email');
      await _storage.saveUserEmail(email);
      return {'success': true, 'message': 'Mock signup successful'};
    }

    try {
      final response = await _dio.post('/auth/signup', data: {
        'email': email,
        'password': password,
      });
      
      // After signup, request OTP
      await requestOtp(email);
      
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
      final response = await _dio.post('/auth/token', data: {
        'username': email,  // FastAPI OAuth2 uses 'username' field
        'password': password,
        'grant_type': 'password',
      }, options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ));

      final data = response.data;
      
      // Save tokens and user info
      await _storage.saveAccessToken(data['access_token']);
      if (data.containsKey('refresh_token')) {
        await _storage.saveRefreshToken(data['refresh_token']);
      }
      await _storage.saveUserEmail(email);

      return data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Request OTP
  Future<void> requestOtp(String email) async {
    if (skipOtp) {
      // Mock OTP request for testing
      return;
    }

    try {
      await _dio.post('/auth/otp/request', data: {'email': email});
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
      final response = await _dio.post('/auth/verify-otp', data: {
        'email': email,
        'code': code,
      });

      final data = response.data;
      
      // Save tokens and user info
      if (data.containsKey('access_token')) {
        await _storage.saveAccessToken(data['access_token']);
      }
      if (data.containsKey('refresh_token')) {
        await _storage.saveRefreshToken(data['refresh_token']);
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

      final response = await _dio.post('/auth/refresh', data: {
        'old_refresh_token': refreshToken,
      });

      final data = response.data;
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
}
