import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/routes.dart';
import '../services/auth_service.dart';
import '../screens/login_screen.dart';
import '../screens/signup_screen.dart';
import '../screens/otp_verification_screen.dart';
// Import other screens as they are created
// import '../screens/home_screen.dart';
// import '../screens/mood_entry_screen.dart';
// etc.

/// App router configuration
class AppRouter {
  final WidgetRef ref;

  AppRouter(this.ref);

  /// Check if user is authenticated
  Future<bool> _isAuthenticated() async {
    final authService = ref.read(authServiceProvider);
    return await authService.isAuthenticated();
  }

  /// Generate routes
  Route<dynamic>? onGenerateRoute(RouteSettings settings) {
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
          builder: (_) => FutureBuilder<bool>(
            future: _isAuthenticated(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              
              if (snapshot.data == true) {
                // TODO: Replace with actual HomeScreen
                return Scaffold(
                  appBar: AppBar(title: const Text('Home')),
                  body: const Center(
                    child: Text('Home Screen - To be implemented'),
                  ),
                );
              } else {
                // Redirect to login
                Future.microtask(() {
                  Navigator.of(context).pushReplacementNamed(Routes.login);
                });
                return const SizedBox.shrink();
              }
            },
          ),
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
      builder: (_) => Scaffold(
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
                onPressed: () => Navigator.of(_).pushReplacementNamed(Routes.home),
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
final appRouterProvider = Provider<AppRouter>((ref) => AppRouter(ref));
