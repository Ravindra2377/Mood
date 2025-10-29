/// Feature flags for SOUL app features.
/// Allows enabling/disabling features via remote config.

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for feature flags state
final featureFlagsProvider = StateProvider<FeatureFlags>((ref) {
  return const FeatureFlags();
});

class FeatureFlags {
  /// Enable/disable AI chat feature
  final bool enableAiChat;

  /// Enable/disable new self-help experience
  final bool enableNewSelfHelp;

  /// Enable/disable beta features
  final bool enableBetaFeatures;

  /// Enable/disable analytics
  final bool enableAnalytics;

  const FeatureFlags({
    this.enableAiChat = true,
    this.enableNewSelfHelp = true,
    this.enableBetaFeatures = false,
    this.enableAnalytics = true,
  });

  factory FeatureFlags.fromJson(Map<String, dynamic> json) {
    return FeatureFlags(
      enableAiChat: json['enable_ai_chat'] ?? true,
      enableNewSelfHelp: json['enable_new_self_help'] ?? true,
      enableBetaFeatures: json['enable_beta_features'] ?? false,
      enableAnalytics: json['enable_analytics'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'enable_ai_chat': enableAiChat,
        'enable_new_self_help': enableNewSelfHelp,
        'enable_beta_features': enableBetaFeatures,
        'enable_analytics': enableAnalytics,
      };

  FeatureFlags copyWith({
    bool? enableAiChat,
    bool? enableNewSelfHelp,
    bool? enableBetaFeatures,
    bool? enableAnalytics,
  }) {
    return FeatureFlags(
      enableAiChat: enableAiChat ?? this.enableAiChat,
      enableNewSelfHelp: enableNewSelfHelp ?? this.enableNewSelfHelp,
      enableBetaFeatures: enableBetaFeatures ?? this.enableBetaFeatures,
      enableAnalytics: enableAnalytics ?? this.enableAnalytics,
    );
  }
}

/// Update feature flags (e.g., from remote config)
final updateFeatureFlagsProvider = Provider<Function(FeatureFlags)>((ref) {
  return (flags) {
    ref.read(featureFlagsProvider.notifier).state = flags;
  };
});
