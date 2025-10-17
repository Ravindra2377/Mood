/// App-wide constants
class Constants {
  Constants._();

  // App Information
  static const String appName = 'SOUL';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Your Mental Health Companion';

  // API Endpoints (relative paths - base URL configured in AppConfig)
  static const String apiAuth = '/auth';
  static const String apiMoods = '/moods';
  static const String apiJournals = '/journals';
  static const String apiAnalytics = '/analytics';
  static const String apiProfile = '/profile';

  // Storage Keys
  static const String keyThemeMode = 'theme_mode';
  static const String keyLanguage = 'language';
  static const String keyOnboardingComplete = 'onboarding_complete';
  static const String keyLastSyncTime = 'last_sync_time';

  // Durations
  static const Duration splashDuration = Duration(seconds: 2);
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration snackBarDuration = Duration(seconds: 3);
  static const Duration errorSnackBarDuration = Duration(seconds: 5);
  static const Duration debounceD uration = Duration(milliseconds: 500);

  // Limits
  static const int maxJournalTitleLength = 100;
  static const int maxJournalContentLength = 5000;
  static const int maxMoodNoteLength = 500;
  static const int minPasswordLength = 8;
  static const int otpLength = 6;

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Mood Scale
  static const int minMoodScore = 1;
  static const int maxMoodScore = 10;

  // Date Formats
  static const String dateFormatShort = 'MMM d, y';
  static const String dateFormatLong = 'd MMMM y';
  static const String dateFormatApi = 'yyyy-MM-dd';
  static const String timeFormat = 'h:mm a';

  // Feature Flags Keys
  static const String featureCommunity = 'community';
  static const String featureGamification = 'gamification';
  static const String featureCrisisSupport = 'crisis_support';
  static const String featurePsychometricGames = 'psychometric_games';

  // Assets
  static const String assetBrainIcon = 'assets/images/brain.png';
  static const String assetLogoIcon = 'assets/images/logo.png';
  static const String assetPlaceholder = 'assets/images/placeholder.png';

  // External Links
  static const String supportEmail = 'support@soulapp.com';
  static const String privacyPolicyUrl = 'https://soulapp.com/privacy';
  static const String termsOfServiceUrl = 'https://soulapp.com/terms';
  static const String helpCenterUrl = 'https://help.soulapp.com';

  // Crisis Resources
  static const String crisisHotline = '988';
  static const String crisisTextLine = '741741';
  static const String crisisHotlineName = 'National Suicide Prevention Lifeline';
  static const String crisisTextLineName = 'Crisis Text Line';

  // Validation Patterns
  static const String emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String phonePattern = r'^\+?[\d\s-()]+$';

  // UI Constants
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;
  static const double borderRadiusXLarge = 24.0;

  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
  static const double iconSizeXLarge = 48.0;

  // Animation Values
  static const double fadeInOpacity = 1.0;
  static const double fadeOutOpacity = 0.0;

  // Error Messages
  static const String errorNetwork = 'Network error. Please check your connection.';
  static const String errorServer = 'Server error. Please try again later.';
  static const String errorUnknown = 'An unexpected error occurred.';
  static const String errorSessionExpired = 'Your session has expired. Please login again.';
  static const String errorInvalidCredentials = 'Invalid email or password.';

  // Success Messages
  static const String successLogin = 'Welcome back!';
  static const String successSignup = 'Account created successfully!';
  static const String successLogout = 'Logged out successfully';
  static const String successMoodSaved = 'Mood logged successfully';
  static const String successJournalSaved = 'Journal entry saved';

  // Empty States
  static const String emptyMoods = 'No mood entries yet. Start tracking your mood!';
  static const String emptyJournals = 'No journal entries yet. Start writing!';
  static const String emptyActivities = 'No activities found.';
  static const String emptyNotifications = 'No notifications yet.';

  // Quotes (default/fallback)
  static const List<String> motivationalQuotes = [
    'Every day is a new beginning.',
    'You are stronger than you think.',
    'Progress, not perfection.',
    'Be kind to yourself.',
    'One step at a time.',
    'You\'ve got this.',
    'It\'s okay to not be okay.',
    'Healing is not linear.',
    'Your feelings are valid.',
    'Take care of yourself.',
  ];

  // Activity Durations (in minutes)
  static const int shortActivityDuration = 5;
  static const int mediumActivityDuration = 15;
  static const int longActivityDuration = 30;

  // Notification Channel IDs (for mobile)
  static const String notificationChannelReminders = 'reminders';
  static const String notificationChannelAlerts = 'alerts';
  static const String notificationChannelUpdates = 'updates';
}
