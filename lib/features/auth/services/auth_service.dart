import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../core/network/app_config.dart';
import '../../../core/network/http_client_provider.dart';
import '../models/auth_state.dart';

class AuthTokens {
  const AuthTokens({
    required this.accessToken,
    this.refreshToken,
    this.user,
  });

  final String accessToken;
  final String? refreshToken;
  final AuthUser? user;
}

class AuthApiException implements Exception {
  AuthApiException({
    required this.message,
    this.statusCode,
    this.body,
  });

  final String message;
  final int? statusCode;
  final String? body;

  @override
  String toString() {
    return 'AuthApiException(statusCode: $statusCode, message: $message, body: $body)';
  }
}

class AuthService {
  AuthService({
    required http.Client client,
    String? baseUrl,
  })  : _client = client,
        _baseUrl = baseUrl ?? AppConfig.apiBaseUrl;

  final http.Client _client;
  final String _baseUrl;

  Uri _buildUri(String path) {
    final normalizedBase = _baseUrl.endsWith('/')
        ? _baseUrl.substring(0, _baseUrl.length - 1)
        : _baseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$normalizedBase$normalizedPath');
  }

  Map<String, String> _jsonHeaders({String? token}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<void> requestOtp(String email) async {
    final uri = _buildUri('/auth/otp/request');
    final response = await _client.post(
      uri,
      headers: _jsonHeaders(),
      body: json.encode({'email': email.trim()}),
    );
    _ensureSuccess(response, 'Failed to request verification code');
  }

  Future<AuthTokens> verifyOtp({
    required String email,
    required String code,
  }) async {
    final uri = _buildUri('/auth/verify-otp');
    final response = await _client.post(
      uri,
      headers: _jsonHeaders(),
      body: json.encode({
        'email': email.trim(),
        'code': code.trim(),
      }),
    );
    _ensureSuccess(response, 'Unable to verify code');

    final payload = json.decode(response.body) as Map<String, dynamic>;
    final accessToken = payload['access_token'] as String?;
    if (accessToken == null || accessToken.isEmpty) {
      throw AuthApiException(
        message: 'Response did not include an access token',
        statusCode: response.statusCode,
        body: response.body,
      );
    }

    final refreshToken = payload['refresh_token'] as String?;
    final userJson = payload['user'];
    final user =
        userJson is Map<String, dynamic> ? AuthUser.fromJson(userJson) : null;

    return AuthTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      user: user,
    );
  }

  Future<void> logout({
    String? accessToken,
    String? refreshToken,
  }) async {
    if (accessToken == null && refreshToken == null) {
      return;
    }

    final uri = _buildUri('/auth/logout');
    final body = refreshToken != null ? {'refresh_token': refreshToken} : null;
    try {
      await _client.post(
        uri,
        headers: _jsonHeaders(token: accessToken),
        body: body == null ? null : json.encode(body),
      );
    } catch (_) {
      // Swallow errors from logout attempts; session clearing happens client-side.
    }
  }

  void _ensureSuccess(http.Response response, String defaultMessage) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }
    throw AuthApiException(
      message: _extractMessage(response.body) ?? defaultMessage,
      statusCode: response.statusCode,
      body: response.body,
    );
  }

  String? _extractMessage(String? rawBody) {
    if (rawBody == null || rawBody.isEmpty) {
      return null;
    }
    try {
      final decoded = json.decode(rawBody);
      if (decoded is Map<String, dynamic>) {
        final detail = decoded['detail'];
        if (detail is String && detail.isNotEmpty) {
          return detail;
        }
        if (detail is Map<String, dynamic>) {
          final message = detail['message'];
          if (message is String && message.isNotEmpty) {
            return message;
          }
        }
      }
    } catch (_) {
      // ignore JSON errors
    }
    return null;
  }
}

final authServiceProvider = Provider<AuthService>((ref) {
  final client = ref.watch(httpClientProvider);
  return AuthService(client: client);
});
