/// Feature flags for controlling app behavior
class FeatureFlags {
  /// Toggle between mock data and real API data
  /// Set to false when your backend is ready
  static const bool useMockData = true;

  /// Enable debug logging
  static const bool enableDebugLogging = true;

  /// Enable offline mode
  static const bool enableOfflineMode = true;

  /// Enable data caching
  static const bool enableCaching = true;

  /// API request timeout in seconds
  static const int apiTimeoutSeconds = 30;

  /// Maximum retry attempts for failed requests
  static const int maxRetryAttempts = 3;
}