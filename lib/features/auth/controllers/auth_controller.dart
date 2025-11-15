import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/token_storage.dart';
import '../../journal/providers/journal_provider.dart';
import '../models/auth_state.dart';
import '../services/auth_service.dart';

class AuthController extends StateNotifier<AuthState> {
  AuthController(
    this._ref,
    this._authService,
    this._tokenStorage,
  ) : super(AuthState.initial()) {
    _initialize();
  }

  final Ref _ref;
  final AuthService _authService;
  final TokenStorage _tokenStorage;

  Future<void> _initialize() async {
    try {
      final accessToken = await _tokenStorage.readAccessToken();
      final refreshToken = await _tokenStorage.readRefreshToken();
      final email = await _tokenStorage.readUserEmail();
      final userId = await _tokenStorage.readUserId();
      AuthUser? user;
      if (userId != null &&
          userId.isNotEmpty &&
          email != null &&
          email.isNotEmpty) {
        user = AuthUser(id: userId, email: email);
      }
      if (accessToken != null && accessToken.isNotEmpty) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          operation: AuthOperation.none,
          accessToken: accessToken,
          refreshToken: refreshToken,
          email: email,
          user: user,
          clearError: true,
        );
      } else {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          operation: AuthOperation.none,
          email: email,
          clearAccessToken: true,
          clearRefreshToken: true,
          user: user,
          clearError: true,
        );
      }
    } catch (_) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        operation: AuthOperation.none,
        errorMessage: 'Failed to restore previous session.',
      );
    }
  }

  Future<void> requestOtp(String email) async {
    final trimmed = email.trim();
    if (trimmed.isEmpty) {
      state = state.copyWith(errorMessage: 'Please enter your email address.');
      return;
    }

    state = state.copyWith(
      operation: AuthOperation.sendingCode,
      email: trimmed,
      clearError: true,
    );

    try {
      await _authService.requestOtp(trimmed);
      state = state.copyWith(
        status: AuthStatus.codeSent,
        operation: AuthOperation.none,
        clearError: true,
      );
    } on AuthApiException catch (error) {
      state = state.copyWith(
        operation: AuthOperation.none,
        errorMessage: error.message,
      );
    } catch (_) {
      state = state.copyWith(
        operation: AuthOperation.none,
        errorMessage: 'Unable to send code. Please try again.',
      );
    }
  }

  Future<void> verifyOtp(String code) async {
    final trimmedCode = code.trim();
    final email = state.email;
    if (email == null || email.isEmpty) {
      state = state.copyWith(
        errorMessage: 'Enter your email before verifying the code.',
      );
      return;
    }
    if (trimmedCode.isEmpty) {
      state = state.copyWith(
        errorMessage: 'Enter the verification code sent to your email.',
      );
      return;
    }

    state = state.copyWith(
      operation: AuthOperation.verifyingCode,
      clearError: true,
    );

    try {
      final tokens = await _authService.verifyOtp(
        email: email,
        code: trimmedCode,
      );

      await _tokenStorage.writeAccessToken(tokens.accessToken);
      if (tokens.refreshToken != null && tokens.refreshToken!.isNotEmpty) {
        await _tokenStorage.writeRefreshToken(tokens.refreshToken!);
      } else {
        await _tokenStorage.clearRefreshToken();
      }
      await _tokenStorage.writeUserEmail(email);
      if (tokens.user != null) {
        await _tokenStorage.writeUserId(tokens.user!.id);
      } else {
        await _tokenStorage.clearUserId();
      }

      state = state.copyWith(
        status: AuthStatus.authenticated,
        operation: AuthOperation.none,
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
        clearRefreshToken: tokens.refreshToken == null,
        user: tokens.user,
        clearUser: tokens.user == null,
        clearError: true,
      );

      _ref.invalidate(journalProvider);
    } on AuthApiException catch (error) {
      state = state.copyWith(
        operation: AuthOperation.none,
        errorMessage: error.message,
      );
    } catch (_) {
      state = state.copyWith(
        operation: AuthOperation.none,
        errorMessage: 'Verification failed. Please try again.',
      );
    }
  }

  Future<void> logout() async {
    final accessToken = state.accessToken;
    final refreshToken = state.refreshToken;
    state = state.copyWith(
      operation: AuthOperation.loggingOut,
      clearError: true,
    );

    try {
      await _authService.logout(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
    } finally {
      await _tokenStorage.clearAll();
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        operation: AuthOperation.none,
        clearAccessToken: true,
        clearRefreshToken: true,
        clearUser: true,
        clearEmail: true,
        clearError: true,
      );
      _ref.invalidate(journalProvider);
    }
  }

  void resetFlow() {
    state = state.copyWith(
      status: AuthStatus.unauthenticated,
      clearEmail: true,
      clearError: true,
    );
  }

  void clearError() {
    if (state.errorMessage != null) {
      state = state.copyWith(clearError: true);
    }
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  final service = ref.watch(authServiceProvider);
  final storage = ref.watch(tokenStorageProvider);
  return AuthController(ref, service, storage);
});
