import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../services/api_client.dart';
import 'runtime_config.dart';

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
  static const accessToken = 'auth_access_token';
}

/// Secure token repository (uses FlutterSecureStorage).
class TokenRepository {
  const TokenRepository(this._storage);

  final FlutterSecureStorage _storage;

  Future<String?> readAccessToken() => _storage.read(key: _StorageKeys.accessToken);

  Future<void> saveAccessToken(String token) =>
      _storage.write(key: _StorageKeys.accessToken, value: token);

  Future<void> clear() => _storage.delete(key: _StorageKeys.accessToken);
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
  final runtime = ref.watch(runtimeConfigProvider);

  final baseUrl = runtime.when(
    data: (v) => v,
    loading: () => null,
    error: (_, __) => null,
  );

  return ApiClientFactory.create(
    baseUrl: baseUrl,
    getToken: () => tokenRepo.readAccessToken(),
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


  /// Request an OTP to be sent to the provided email address.
  Future<void> sendOtp(String email) async {
    await _api.requestOtp(OtpRequest(email: email));
  }



  /// Verify OTP and store tokens.

  Future<void> verifyOtp({

    required String email,
    required String code,

  }) async {

    // Show loading state

    state = const AsyncLoading();



    try {

      final res = await _api.verifyOtp(VerifyOtpRequest(email: email, code: code));
      await _tokens.saveAccessToken(res.accessToken);



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
