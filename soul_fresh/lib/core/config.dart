/*
  Core configuration for the SOUL Flutter app.

  The API base URL is provided via a compile-time constant using --dart-define.
  Example:
    flutter run --dart-define=BASE_URL=https://api-staging.soulapp.app
    flutter build apk --release --dart-define=BASE_URL=https://api.soulapp.app
*/

class AppConfig {
  AppConfig._();

  /// Default fallback if no dart-define is provided.
  static const String _defaultBaseUrl = 'https://api.soulapp.app';

  /// The root backend URL. Override at build time with:
  ///   --dart-define=BASE_URL=https://api-staging.soulapp.app
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: _defaultBaseUrl,
  );

  /// Common API prefix used by the backend.
  static const String apiPrefix = '/api';

  /// The full API base URL (baseUrl + apiPrefix), normalized to one slash.
  static String get apiBaseUrl => _join(baseUrl, apiPrefix);

  /// Standard HTTP timeouts for the API client.
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 20);
  static const Duration sendTimeout = Duration(seconds: 20);

  /// Helper to easily construct endpoint paths consistently:
  /// AppConfig.endpoint('/auth/otp/request') -> https://.../api/auth/otp/request
  static Uri endpoint(String path, {Map<String, dynamic>? query}) {
    final String normalized = _join(apiBaseUrl, path);
    final uri = Uri.parse(normalized);
    return (query == null || query.isEmpty)
        ? uri
        : uri.replace(queryParameters: {
            ...uri.queryParameters,
            ...query.map((k, v) => MapEntry(k, '$v')),
          });
  }

  /// True if the current base URL looks like a staging endpoint.
  static bool get isStaging =>
      baseUrl.contains('staging') || baseUrl.contains('dev');

  /// Ensure a + b have exactly one slash between them.
  static String _join(String a, String b) {
    final String left = a.endsWith('/') ? a.substring(0, a.length - 1) : a;
    final String right = b.startsWith('/') ? b.substring(1) : b;
    return '$left/$right';
  }
}
