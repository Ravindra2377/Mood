import 'dart:async';

import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:retrofit/retrofit.dart';

import '../core/config.dart';

part 'api_client.g.dart';

/// Simple token accessor you can plug into [AuthInterceptor].
typedef TokenGetter = FutureOr<String?> Function();
typedef TokenSetter = FutureOr<void> Function(String? token);

/// Interceptor that attaches Authorization header when a token is available.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({required this.getToken});

  final TokenGetter getToken;

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}

class TokenRefreshException implements Exception {
  const TokenRefreshException(this.message);
  final String message;

  @override
  String toString() => 'TokenRefreshException: $message';
}

class TokenRefreshInterceptor extends Interceptor {
  TokenRefreshInterceptor({
    required this.dio,
    required this.getAccessToken,
    required this.getRefreshToken,
    required this.saveAccessToken,
    required this.saveRefreshToken,
    this.clearTokens,
    this.onUnauthorized,
    this.refreshEndpoint = '/auth/refresh',
  }) : _refreshDio = Dio(
          BaseOptions(
            baseUrl: dio.options.baseUrl.isNotEmpty
                ? dio.options.baseUrl
                : AppConfig.apiBaseUrl,
            connectTimeout: dio.options.connectTimeout,
            receiveTimeout: dio.options.receiveTimeout,
            sendTimeout: dio.options.sendTimeout,
            headers: const {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
          ),
        );

  static const _skipKey = '__skip_token_refresh__';

  final Dio dio;
  final Dio _refreshDio;
  final TokenGetter getAccessToken;
  final TokenGetter getRefreshToken;
  final TokenSetter saveAccessToken;
  final TokenSetter saveRefreshToken;
  final FutureOr<void> Function()? clearTokens;
  final FutureOr<void> Function()? onUnauthorized;
  final String refreshEndpoint;

  Future<void>? _refreshing;

  bool _shouldSkip(RequestOptions options) => options.extra[_skipKey] == true;

  bool _isUnauthorized(DioException err) {
    if (err.type != DioExceptionType.badResponse) {
      return false;
    }
    final status = err.response?.statusCode;
    if (status != 401 || _shouldSkip(err.requestOptions)) {
      return false;
    }
    final path = err.requestOptions.path;
    if (path.endsWith('/auth/refresh') ||
        path.endsWith('/auth/login') ||
        path.endsWith('/auth/token')) {
      return false;
    }
    return true;
  }

  Future<void> _performRefresh() async {
    final refreshToken = await getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      throw const TokenRefreshException('Missing refresh token');
    }

    final response = await _refreshDio.post<dynamic>(
      refreshEndpoint,
      data: {'old_refresh_token': refreshToken},
    );

    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw const TokenRefreshException('Unexpected refresh response');
    }

    final newAccess = data['access_token'] as String?;
    final newRefresh = data['refresh_token'] as String?;

    if (newAccess == null || newAccess.isEmpty) {
      throw const TokenRefreshException('Refresh response missing access_token');
    }
    if (newRefresh == null || newRefresh.isEmpty) {
      throw const TokenRefreshException('Refresh response missing refresh_token');
    }

    await Future.sync(() => saveAccessToken(newAccess));
    await Future.sync(() => saveRefreshToken(newRefresh));
  }

  Future<void> _ensureRefreshing() {
    final existing = _refreshing;
    if (existing != null) {
      return existing;
    }

    Future<void> futureCallback() async {
      try {
        await _performRefresh();
      } catch (error) {
        await Future.sync(() => clearTokens?.call());
        rethrow;
      }
    }

    final future = futureCallback().whenComplete(() {
      _refreshing = null;
    });

    _refreshing = future;
    return future;
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (!_isUnauthorized(err)) {
      handler.next(err);
      return;
    }

    final requestOptions = err.requestOptions;

    try {
      await _ensureRefreshing();
    } catch (_) {
      await Future.sync(() => onUnauthorized?.call());
      handler.next(err);
      return;
    }

    try {
      final token = await getAccessToken();
      if (token != null && token.isNotEmpty) {
        requestOptions.headers['Authorization'] = 'Bearer $token';
      } else {
        requestOptions.headers.remove('Authorization');
      }

      requestOptions.extra[_skipKey] = true;
      final response = await dio.fetch<dynamic>(requestOptions);
      handler.resolve(response);
    } catch (retryErr) {
      if (retryErr is DioException && retryErr.response?.statusCode == 401) {
        await Future.sync(() => clearTokens?.call());
        await Future.sync(() => onUnauthorized?.call());
      }
      handler.next(
        retryErr is DioException
            ? retryErr
            : DioException(requestOptions: requestOptions, error: retryErr),
      );
    } finally {
      requestOptions.extra.remove(_skipKey);
    }
  }
}

/// Factory to build a configured [Dio] and [ApiClient].
class ApiClientFactory {
  static Dio createDio({
    String? baseUrl,
    required TokenGetter getToken,
    required TokenGetter getRefreshToken,
    required TokenSetter saveAccessToken,
    required TokenSetter saveRefreshToken,
    FutureOr<void> Function()? clearTokens,
    FutureOr<void> Function()? onUnauthorized,
    List<Interceptor> extraInterceptors = const [],
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: (baseUrl?.isNotEmpty ?? false) ? baseUrl! : AppConfig.apiBaseUrl,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        sendTimeout: AppConfig.sendTimeout,
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    dio.interceptors.addAll([
      AuthInterceptor(getToken: getToken),
      TokenRefreshInterceptor(
        dio: dio,
        getAccessToken: getToken,
        getRefreshToken: getRefreshToken,
        saveAccessToken: saveAccessToken,
        saveRefreshToken: saveRefreshToken,
        clearTokens: clearTokens,
        onUnauthorized: onUnauthorized,
      ),
      // Log basic info in debug mode. You can swap with pretty logger.
      LogInterceptor(
        request: true,
        requestBody: true,
        responseBody: false,
        responseHeader: false,
        error: true,
      ),
      ...extraInterceptors,
    ]);
    return dio;
  }

  static ApiClient create({
    String? baseUrl,
    required TokenGetter getToken,
    required TokenGetter getRefreshToken,
    required TokenSetter saveAccessToken,
    required TokenSetter saveRefreshToken,
    FutureOr<void> Function()? clearTokens,
    FutureOr<void> Function()? onUnauthorized,
    List<Interceptor> extraInterceptors = const [],
  }) {
    final dio = createDio(
      baseUrl: baseUrl,
      getToken: getToken,
      getRefreshToken: getRefreshToken,
      saveAccessToken: saveAccessToken,
      saveRefreshToken: saveRefreshToken,
      clearTokens: clearTokens,
      onUnauthorized: onUnauthorized,
      extraInterceptors: extraInterceptors,
    );
    return ApiClient(dio);
  }
}

/// Retrofit API surface for SOUL backend.
/// Base URL comes from Dio; default is AppConfig.apiBaseUrl.
@RestApi()
abstract class ApiClient {
  factory ApiClient(Dio dio, {String baseUrl}) = _ApiClient;

  // -----------------------
  // Auth
  // -----------------------

  /// Request an OTP code to be sent to the user.
  @POST('/auth/otp/request')
  Future<MessageResponse> requestOtp(@Body() OtpRequest body);

  /// Verify OTP and obtain tokens.
  @POST('/auth/verify-otp')
  Future<AuthResponse> verifyOtp(@Body() VerifyOtpRequest body);

  /// Revoke server-side session/refresh token (optional but recommended).
  @POST('/auth/logout')
  Future<MessageResponse> logout();

  // -----------------------
  // Moods
  // -----------------------

  /// List moods. Supports simple pagination via page/limit.
  @GET('/moods')
  Future<List<MoodEntry>> listMoods({
    @Query('page') int? page,
    @Query('limit') int? limit,
    @Query('from') String? fromIso, // e.g., 2025-10-12
    @Query('to') String? toIso,
  });

  /// Create a new mood entry.
  @POST('/moods')
  Future<MoodEntry> createMood(@Body() CreateMoodRequest body);

  // -----------------------
  // Journals
  // -----------------------

  @GET('/journals')
  Future<List<JournalEntry>> listJournals({
    @Query('page') int? page,
    @Query('limit') int? limit,
  });

  @POST('/journals')
  Future<JournalEntry> createJournal(@Body() CreateJournalRequest body);

  @PUT('/journals/{id}')
  Future<JournalEntry> updateJournal(
    @Path('id') String id,
    @Body() UpdateJournalRequest body,
  );

  @DELETE('/journals/{id}')
  Future<MessageResponse> deleteJournal(@Path('id') String id);
}

// ============================================================================
// DTOs (json_serializable)
// You can move these into their own files later; kept together here for
// convenience while scaffolding. Run build_runner to generate *.g.dart.
// ============================================================================

@JsonSerializable()
class MessageResponse {
  final String message;

  MessageResponse({required this.message});

  factory MessageResponse.fromJson(Map<String, dynamic> json) => _$MessageResponseFromJson(json);
  Map<String, dynamic> toJson() => _$MessageResponseToJson(this);
}

// -----------------------
// Auth DTOs
// -----------------------

@JsonSerializable()
class OtpRequest {
  final String phone;
  OtpRequest({required this.phone});

  factory OtpRequest.fromJson(Map<String, dynamic> json) => _$OtpRequestFromJson(json);
  Map<String, dynamic> toJson() => _$OtpRequestToJson(this);
}

@JsonSerializable()
class VerifyOtpRequest {
  final String phone;
  final String code;
  VerifyOtpRequest({required this.phone, required this.code});

  factory VerifyOtpRequest.fromJson(Map<String, dynamic> json) => _$VerifyOtpRequestFromJson(json);
  Map<String, dynamic> toJson() => _$VerifyOtpRequestToJson(this);
}

@JsonSerializable()
class AuthResponse {
  @JsonKey(name: 'access_token')
  final String accessToken;

  @JsonKey(name: 'refresh_token')
  final String? refreshToken;

  @JsonKey(name: 'token_type')
  final String? tokenType;

  AuthResponse({
    required this.accessToken,
    this.refreshToken,
    this.tokenType,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => _$AuthResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
}

// -----------------------
// Mood DTOs
// -----------------------

@JsonSerializable()
class MoodEntry {
  final String id;
  final int score; // 1..10
  final String? note;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  MoodEntry({
    required this.id,
    required this.score,
    this.note,
    required this.createdAt,
  });

  factory MoodEntry.fromJson(Map<String, dynamic> json) => _$MoodEntryFromJson(json);
  Map<String, dynamic> toJson() => _$MoodEntryToJson(this);
}

@JsonSerializable()
class CreateMoodRequest {
  final int score; // 1..10
  final String? note;

  CreateMoodRequest({required this.score, this.note});

  factory CreateMoodRequest.fromJson(Map<String, dynamic> json) => _$CreateMoodRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateMoodRequestToJson(this);
}

// -----------------------
// Journal DTOs
// -----------------------

@JsonSerializable()
class JournalEntry {
  final String id;
  final String title;
  final String content; // markdown/plaintext
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  JournalEntry({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.updatedAt,
  });

  factory JournalEntry.fromJson(Map<String, dynamic> json) => _$JournalEntryFromJson(json);
  Map<String, dynamic> toJson() => _$JournalEntryToJson(this);
}

@JsonSerializable()
class CreateJournalRequest {
  final String title;
  final String content;

  CreateJournalRequest({required this.title, required this.content});

  factory CreateJournalRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateJournalRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateJournalRequestToJson(this);
}

@JsonSerializable()
class UpdateJournalRequest {
  final String? title;
  final String? content;

  UpdateJournalRequest({this.title, this.content});

  factory UpdateJournalRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateJournalRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateJournalRequestToJson(this);
}

// ============================================================================
// Error helpers
// ============================================================================

/// Convert a Dio error into a user-friendly string (optional usage in UI).
String formatDioError(Object error) {
  if (error is DioException) {
    final res = error.response;
    final status = res?.statusCode;
    final data = res?.data;
    if (status != null) {
      return 'Request failed ($status): ${_safeString(data) ?? error.message ?? 'Unknown error'}';
    }
    return 'Network error: ${error.message ?? 'Unknown'}';
  }
  return error.toString();
}

String? _safeString(dynamic data) {
  if (data == null) return null;
  if (data is String) return data;
  if (data is Map && data['message'] is String) return data['message'] as String;
  return null;
}
