import 'package:meta/meta.dart';

@immutable
class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id']?.toString() ?? '',
      email: (json['email'] as String?)?.trim() ?? '',
    );
  }

  final String id;
  final String email;
}

enum AuthStatus {
  unknown,
  unauthenticated,
  codeSent,
  authenticated,
}

enum AuthOperation {
  none,
  restoring,
  sendingCode,
  verifyingCode,
  loggingOut,
}

@immutable
class AuthState {
  const AuthState({
    required this.status,
    required this.operation,
    this.email,
    this.user,
    this.accessToken,
    this.refreshToken,
    this.errorMessage,
  });

  factory AuthState.initial() {
    return const AuthState(
      status: AuthStatus.unknown,
      operation: AuthOperation.restoring,
    );
  }

  final AuthStatus status;
  final AuthOperation operation;
  final String? email;
  final AuthUser? user;
  final String? accessToken;
  final String? refreshToken;
  final String? errorMessage;

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => operation != AuthOperation.none;

  AuthState copyWith({
    AuthStatus? status,
    AuthOperation? operation,
    String? email,
    bool clearEmail = false,
    AuthUser? user,
    bool clearUser = false,
    String? accessToken,
    bool clearAccessToken = false,
    String? refreshToken,
    bool clearRefreshToken = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      operation: operation ?? this.operation,
      email: clearEmail ? null : (email ?? this.email),
      user: clearUser ? null : (user ?? this.user),
      accessToken: clearAccessToken ? null : (accessToken ?? this.accessToken),
      refreshToken:
          clearRefreshToken ? null : (refreshToken ?? this.refreshToken),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
