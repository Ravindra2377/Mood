import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../services/api_client.dart';

/// Simple auth state for the SOUL Flutter app.
/// - [initialized] tells the UI when the async bootstrap has finished
/// - [accessToken] determines whether the user is authenticated
class AuthState {
  final bool initialized;
  final String? accessToken;

  const AuthState({
    required this.initialized,
    required this.accessToken,
  });

  bool get isAuthenticated => (accessToken != null && accessToken!.isNotEmpty);

  AuthState copyWith({
    bool? initialized,
    String? accessToken,
  }) {
    return AuthState(
      initialized: initialized ?? this.initialized,
      accessToken: accessToken,
    );
  }

  static const uninitialized = AuthState(initialized: false, accessToken: null);
}

/// Storage keys used for secure storage
class _StorageKeys {
  static const accessToken = 'access_token';
  static const refreshToken = 'refresh_token';
  static const legacyAccessToken = 'auth_access_token';
}

/// Secure token repository (uses FlutterSecureStorage).
class TokenRepository {
  const TokenRepository(this._storage);

  final FlutterSecureStorage _storage;

  Future<String?> readAccessToken() async {
    final token = await _storage.read(key: _StorageKeys.accessToken);
    if (token != null && token.isNotEmpty) {
      return token;
    }
    final legacy = await _storage.read(key: _StorageKeys.legacyAccessToken);
    if (legacy != null && legacy.isNotEmpty) {
      await saveAccessToken(legacy);
      await _storage.delete(key: _StorageKeys.legacyAccessToken);
      return legacy;
    }
    return null;
  }

  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _StorageKeys.accessToken, value: token);
    await _storage.delete(key: _StorageKeys.legacyAccessToken);
  }

  Future<void> clearAccessToken() async {
    await _storage.delete(key: _StorageKeys.accessToken);
    await _storage.delete(key: _StorageKeys.legacyAccessToken);
  }

  Future<String?> readRefreshToken() =>
      _storage.read(key: _StorageKeys.refreshToken);

  Future<void> saveRefreshToken(String token) =>
      _storage.write(key: _StorageKeys.refreshToken, value: token);

  Future<void> clearRefreshToken() =>
      _storage.delete(key: _StorageKeys.refreshToken);

  Future<void> clear() async {
    await clearAccessToken();
    await clearRefreshToken();
  }
}

/// Providers

/// Secure storage instance
final secureStorageProvider = Provider<FlutterSecureStorage>(
  (ref) => const FlutterSecureStorage(),
);

/// Token repository provider
final tokenRepositoryProvider = Provider<TokenRepository>(
  (ref) => TokenRepository(ref.read(secureStorageProvider)),
);

/// ApiClient provider configured with an interceptor that reads the token
final apiClientProvider = Provider<ApiClient>((ref) {
  final tokenRepo = ref.read(tokenRepositoryProvider);

  // ApiClientFactory attaches an interceptor that calls this getter per request.
  return ApiClientFactory.create(
    getToken: () => tokenRepo.readAccessToken(),
    getRefreshToken: () => tokenRepo.readRefreshToken(),
    saveAccessToken: (token) async {
      if (token == null || token.isEmpty) {
        await tokenRepo.clearAccessToken();
      } else {
        await tokenRepo.saveAccessToken(token);
      }
    },
    saveRefreshToken: (token) async {
      if (token == null || token.isEmpty) {
        await tokenRepo.clearRefreshToken();
      } else {
        await tokenRepo.saveRefreshToken(token);
      }
    },
    clearTokens: () => tokenRepo.clear(),
    onUnauthorized: () {
      ref.invalidate(authControllerProvider);
    },
  );
});

/// Auth controller with async bootstrap.
/// On app launch, it loads the token from secure storage.
final authControllerProvider =
    AsyncNotifierProvider<AuthController, AuthState>(() => AuthController());

class AuthController extends AsyncNotifier<AuthState> {
  TokenRepository get _tokens => ref.read(tokenRepositoryProvider);
  ApiClient get _api => ref.read(apiClientProvider);

  @override
  Future<AuthState> build() async {
    final token = await _tokens.readAccessToken();
    return AuthState(initialized: true, accessToken: token);
  }

  /// Request an OTP to be sent to the provided phone number.
  Future<void> sendOtp(String phone) async {
    await _api.requestOtp(OtpRequest(phone: phone));
  }

  /// Verify OTP and store tokens.
  Future<void> verifyOtp({
    required String phone,
    required String code,
  }) async {
    // Show loading state
    state = const AsyncLoading();

    try {
      final res = await _api.verifyOtp(VerifyOtpRequest(phone: phone, code: code));
      await _tokens.saveAccessToken(res.accessToken);
      if ((res.refreshToken ?? '').isNotEmpty) {
        await _tokens.saveRefreshToken(res.refreshToken!);
      }

      // Rebuild state with the new token
      state = AsyncData(AuthState(initialized: true, accessToken: res.accessToken));
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  /// Log out: revoke server session (best-effort) and clear token locally.
  Future<void> logout() async {
    try {
      // Best-effort; ignore failures
      await _api.logout();
    } catch (_) {
      // no-op
    }
    await _tokens.clear();
    state = const AsyncData(AuthState(initialized: true, accessToken: null));
  }

  /// Convenience helper if you already have a token (e.g., deep link auth).
  Future<void> setToken(String token) async {
    await _tokens.saveAccessToken(token);
    state = AsyncData(AuthState(initialized: true, accessToken: token));
  }
}
