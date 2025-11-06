import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/routes.dart';
import '../features/analytics/screens/unified_analytics_screen.dart';
import '../features/exercises/exercise_routes.dart';
import '../features/exercises/screens/exercises_main_screen.dart';
import '../features/home/screens/improved_home_screen.dart';
// New redesigned screens
import '../features/mood/screens/mood_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../screens/login_screen.dart';
import '../screens/otp_verification_screen.dart';
import '../screens/privacy_settings_screen.dart';
import '../screens/signup_screen.dart';

/// App router configuration
class AppRouter {
  /// Generate routes
  Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final exerciseRoute = createExerciseRoute(settings);
    if (exerciseRoute != null) {
      return exerciseRoute;
    }

    switch (settings.name) {
      // Auth routes
      case Routes.login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );

      case Routes.signup:
        return MaterialPageRoute(
          builder: (_) => const SignupScreen(),
          settings: settings,
        );

      case Routes.otpVerification:
        final args = settings.arguments as Map<String, dynamic>?;
        final email = args?['email'] as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => OtpVerificationScreen(email: email),
          settings: settings,
        );

      // Home route (protected)
      case Routes.home:
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: const Text('Home')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Home Screen - Logged In!'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(Routes.profile);
                    },
                    child: const Text('Go to Profile'),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const ImprovedHomeScreen(),
                      ),);
                    },
                    child: const Text('Open Improved Home'),
                  ),
                ],
              ),
            ),
          ),
          settings: settings,
        );

      // Profile routes
      case Routes.profile:
        return MaterialPageRoute(
          builder: (_) => const ProfileScreen(),
          settings: settings,
        );

      case Routes.privacySettings:
        return MaterialPageRoute(
          builder: (_) => const PrivacySettingsScreen(),
          settings: settings,
        );

      // Redesigned feature screens
      case Routes.moodEntry:
        return MaterialPageRoute(
          builder: (_) => const MoodScreen(),
          settings: settings,
        );

      case Routes.analytics:
      case Routes.analyticsDashboard:
        return MaterialPageRoute(
          builder: (_) => const UnifiedAnalyticsScreen(),
          settings: settings,
        );

      // Exercises main screen (new)
      case '/exercises':
        return MaterialPageRoute(
          builder: (_) => const ExercisesMainScreen(),
          settings: settings,
        );

      // Fallback to login
      default:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );
    }
  }

  /// Handle unknown routes
  Route<dynamic>? onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(title: const Text('Not Found')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Page not found: ${settings.name}',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pushReplacementNamed(Routes.home),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Provider for AppRouter  
final appRouterProvider = Provider<AppRouter>((ref) => AppRouter());
