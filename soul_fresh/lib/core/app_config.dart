/// Core app configuration
class AppConfig {
  AppConfig._();

  // Environment
  static const String environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'staging',
  );

  // API Configuration
  static const String apiBaseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://10.0.2.2:8001', // Emulator localhost
  );

  static const int apiTimeoutSeconds = 30;
  static const int maxRetries = 3;

  // Feature Flags
  static const bool enablePsychometricGames = false;
  static const bool enableCommunity = false;
  static const bool enableVoiceJournal = true;
  static const bool enableDarkMode = true;
  static const bool enableAnalytics = true;
  static const bool enableNotifications = true;
  static const bool enableOfflineMode = true;

  // Debug Flags
  static const bool enableDebugLogging = true;
  static const bool enableNetworkLogging = true;
  static const bool showPerformanceOverlay = false;

  // App Behavior
  static const bool requireEmailVerification = true;
  static const bool enableBiometricAuth = false;
  static const int sessionTimeoutMinutes = 30;

  // Storage
  static const String hiveBoxName = 'soul_box';
  static const String secureStorageNamespace = 'soul_secure';

  // External Services
  static const String sentryDsn = String.fromEnvironment('SENTRY_DSN');
  static const String firebaseApiKey = String.fromEnvironment('FIREBASE_API_KEY');

  // Helper methods
  static bool get isProduction => environment == 'production';
  static bool get isDevelopment => environment == 'development';
  static bool get isStaging => environment == 'staging';

  static String get appVersion => '1.0.0+1';
  static String get buildNumber => '1';

  // API Endpoints (combined with base URL)
  static String get authEndpoint => '$apiBaseUrl/api/auth';
  static String get moodsEndpoint => '$apiBaseUrl/api/moods';
  static String get journalsEndpoint => '$apiBaseUrl/api/journals';
  static String get analyticsEndpoint => '$apiBaseUrl/api/analytics';
  static String get profileEndpoint => '$apiBaseUrl/api/profile';
}
