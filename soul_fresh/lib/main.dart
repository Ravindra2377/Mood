import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'config/app_colors.dart';
// New router and auth screens
import 'core/router.dart';
import 'core/routes.dart';
import 'core/theme/app_theme.dart' as soul_theme;
import 'features/analytics/screens/unified_analytics_screen.dart';
import 'features/analytics/services/analytics_service.dart';
import 'features/exercises/screens/exercises_main_screen.dart';
import 'features/home/screens/improved_home_screen.dart';
import 'models/journal_entry_adapter.dart';
import 'screens/activities_screen.dart';
import 'screens/enhanced_meditation_screen.dart';
import 'screens/expression_screen.dart';
import 'screens/journal_list.dart';
import 'screens/login_screen.dart' as new_login;
import 'screens/mental_health/anxiety_management_screen.dart';
import 'screens/mental_health/mindfulness_screen.dart';
import 'screens/mental_health/mood_tracking_screen.dart';
import 'screens/mental_health/sleep_tracking_screen.dart';
import 'screens/mental_health/stress_management_screen.dart';
import 'screens/mental_health/wellness_screen.dart';
import 'screens/mental_health_dashboard.dart';
import 'screens/onboarding_screen.dart';
import 'screens/self_help_screen.dart';
import 'state/app_state.dart';

/// SOUL Flutter application entry point
///
/// - Initializes Hive (local storage foundation).
/// - Sets up Riverpod ProviderScope.
/// - Bootstraps Material 3 theming (light/dark).
/// - Provides routing with an authentication gate that decides whether to show
///   Login/OTP or the Home shell based on the presence of an auth token.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for future offline caches (moods, journals, etc.).
  await Hive.initFlutter();
  // Register adapters used by local storage
  if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(JournalEntryAdapter());
  
  // Initialize analytics service
  await AnalyticsService.initialize();

  runApp(const ProviderScope(child: SoulApp()));
}

// Toggle this during local testing to bypass the OTP network flow.
// When true the app will directly set a dummy access token and navigate
// to the Home screen so you can test signup/login UI without a backend.
const bool skipOtp = true;

// Provider to track current tab in mental health dashboard
final mentalHealthTabProvider = StateProvider<int>((ref) => 0);

class SoulApp extends ConsumerWidget {
  const SoulApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    
    return MaterialApp(
      title: 'SOUL',
      debugShowCheckedModeBanner: false,
      // Use the redesigned global theme
      theme: soul_theme.AppTheme.lightTheme,
      darkTheme: soul_theme.AppTheme.darkTheme,

      // Use the AuthGate to decide between Login and Home based on token state.
      home: const _AuthGate(),

      // Use new router with auth guards
      onGenerateRoute: router.onGenerateRoute,
      onUnknownRoute: router.onUnknownRoute,

      // Keep legacy named routes for existing screens
      routes: {
  Routes.login: (_) => const new_login.LoginScreen(),
        OnboardingScreen.route: (_) => const OnboardingScreen(),
  // Route alias for legacy '/home' now points to the improved home screen
  Routes.home: (_) => const ImprovedHomeScreen(),
        '/mental-health': (_) => const MentalHealthDashboard(),
        MoodScreen.route: (_) => const MoodScreen(),
        ExpressionScreen.route: (_) => const ExpressionScreen(),
        EnhancedMeditationScreen.route: (_) => const EnhancedMeditationScreen(),
        ActivitiesScreen.route: (_) => const ActivitiesScreen(),
  SelfHelpScreen.route: (_) => const SelfHelpScreen(),
        JournalListScreen.route: (_) => const JournalListScreen(),
        AnalyticsScreen.route: (_) => const UnifiedAnalyticsScreen(),
        ExercisesMainScreen.route: (_) => const ExercisesMainScreen(),
      },
    );
  }
}

/// Material 3 theming for SOUL with brand seed and subtle surface blends.
class AppTheme {
  static const Color _brandSeed = Color(0xFF2F3A5F); // brand navy
  static const Color _pastelBlue = Color(0xFFD0F0FD);
  static const Color _softTeal = Color(0xFFA8E6CF);
  static const Color _warmCoral = Color(0xFFFF8C94);

  static ThemeData get light {
    final base = ThemeData(
      colorSchemeSeed: _brandSeed,
      useMaterial3: true,
      brightness: Brightness.light,
      textTheme: GoogleFonts.poppinsTextTheme(),
    );

    return base.copyWith(
      appBarTheme: base.appBarTheme.copyWith(
        elevation: 0,
        centerTitle: false,
        titleTextStyle: base.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      inputDecorationTheme: base.inputDecorationTheme.copyWith(
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: base.colorScheme.surface.withValues(alpha: 0.9),
      ),
      cardTheme: base.cardTheme.copyWith(
        elevation: 0,
        surfaceTintColor: base.colorScheme.surface,
      ),
      scaffoldBackgroundColor: const Color(0xFFF7F9FC),
      extensions: <ThemeExtension<dynamic>>[
        const SoulGradients(
          pastel: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_pastelBlue, _softTeal, _warmCoral],
            stops: [0.0, 0.55, 1.0],
          ),
        ),
      ],
    );
  }

  static ThemeData get dark {
    final base = ThemeData(
      colorSchemeSeed: _brandSeed,
      useMaterial3: true,
      brightness: Brightness.dark,
      textTheme: GoogleFonts.poppinsTextTheme(
          ThemeData(brightness: Brightness.dark).textTheme,),
    );

    return base.copyWith(
      appBarTheme: base.appBarTheme.copyWith(
        elevation: 0,
        titleTextStyle: base.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      inputDecorationTheme: base.inputDecorationTheme.copyWith(
        border: const OutlineInputBorder(),
      ),
      extensions: <ThemeExtension<dynamic>>[
        const SoulGradients(
          pastel: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_pastelBlue, _softTeal, _warmCoral],
            stops: [0.0, 0.55, 1.0],
          ),
        ),
      ],
    );
  }
}

/// Custom theme extension to hold reusable gradients.
class SoulGradients extends ThemeExtension<SoulGradients> {
  final LinearGradient pastel;

  const SoulGradients({required this.pastel});

  @override
  SoulGradients copyWith({LinearGradient? pastel}) =>
      SoulGradients(pastel: pastel ?? this.pastel);

  @override
  ThemeExtension<SoulGradients> lerp(
    covariant ThemeExtension<SoulGradients>? other,
    double t,
  ) {
    if (other is! SoulGradients) return this;
    // LinearGradient has no default lerp; just pick this/other by t.
    return t < .5 ? this : other;
  }
}

/// The AuthGate watches the async auth controller:
/// - While loading: shows a splash.
/// - On error: shows a retry UI.
/// - On success: routes to Home if authenticated, else Login.
class _AuthGate extends ConsumerWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsync = ref.watch(authControllerProvider);

    return authAsync.when(
      loading: () => const _SplashScreen(),
      error: (e, _) => _ErrorScreen(
        message: 'Startup error: $e',
        onRetry: () => ref.invalidate(authControllerProvider),
      ),
    data: (state) => state.isAuthenticated
      ? const ImprovedHomeScreen()
      : const new_login.LoginScreen(),
    );
  }
}

/// Simple splash that can later be replaced by a branded animation.
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    final gradient = Theme.of(context).extension<SoulGradients>()!.pastel;
    return Container(
      decoration: BoxDecoration(gradient: gradient),
      child: const Center(
        child: CircularProgressIndicator.adaptive(),
      ),
    );
  }
}

class _ErrorScreen extends StatelessWidget {
  const _ErrorScreen({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48),
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// =============================
/// Placeholder Screens (MVP UI)
/// =============================

class LoginScreen extends ConsumerStatefulWidget {
  static const route = '/login';
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _sending = false;

  String? _error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Sign in')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Welcome to SOUL',
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in or create an account with email and password.',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'name@example.com',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _passwordCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    hintText: '••••••••',
                  ),
                ),
                const SizedBox(height: 12),
                if (_error != null)
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: _sending
                            ? null
                            : () async {
                                setState(() {
                                  _sending = true;
                                  _error = null;
                                });
                                try {
                                  // Signup flow
                                  final email = _emailCtrl.text.trim();
                                  final password = _passwordCtrl.text;
                                  final navigator = Navigator.of(context);
                                  if (skipOtp) {
                                    // For local dev, just set token and navigate
                                    await ref
                                        .read(authControllerProvider.notifier)
                                        .setToken('local-debug-token');
                                    if (!mounted) return;
                                    navigator.pushNamedAndRemoveUntil(
                                        Routes.home, (_) => false,);
                                  } else {
                                    await ref
                                        .read(authControllerProvider.notifier)
                                        .signup(email: email, password: password);
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    setState(() => _error = e.toString());
                                  }
                                } finally {
                                  if (mounted) setState(() => _sending = false);
                                }
                              },
                        child: const Text('Sign up'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _sending
                            ? null
                            : () async {
                                setState(() {
                                  _sending = true;
                                  _error = null;
                                });
                                try {
                                  final email = _emailCtrl.text.trim();
                                  final password = _passwordCtrl.text;
                                  final navigator = Navigator.of(context);
                                  if (skipOtp) {
                                    await ref
                                        .read(authControllerProvider.notifier)
                                        .setToken('local-debug-token');
                                    if (!mounted) return;
                                    navigator.pushNamedAndRemoveUntil(
                                        Routes.home, (_) => false,);
                                  } else {
                                    await ref
                                        .read(authControllerProvider.notifier)
                                        .login(email: email, password: password);
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    setState(() => _error = e.toString());
                                  }
                                } finally {
                                  if (mounted) setState(() => _sending = false);
                                }
                              },
                        child: const Text('Log in'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OtpScreen extends ConsumerStatefulWidget {
  static const route = '/otp';
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _otpCtrl = TextEditingController();

  bool _verifying = false;

  String? _error;

  @override
  Widget build(BuildContext context) {
    final email = ModalRoute.of(context)?.settings.arguments as String? ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Enter OTP')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text('OTP sent to $email'),
                const SizedBox(height: 12),
                TextField(
                  controller: _otpCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: '6-digit code'),
                ),
                const SizedBox(height: 12),
                if (_error != null)
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                const Spacer(),
                FilledButton(
                  onPressed: _verifying
                      ? null
                      : () async {
                          setState(() {
                            _verifying = true;

                            _error = null;
                          });

                          try {
                            final navigator = Navigator.of(context);
                            if (skipOtp) {
                              // Accept any code in local debug mode.
                              await ref
                                  .read(authControllerProvider.notifier)
                                  .setToken('local-debug-token');

                              if (!mounted) return;

                              navigator.pushNamedAndRemoveUntil(
                                Routes.home,
                                (_) => false,
                              );
                            } else {
                              await ref
                                  .read(authControllerProvider.notifier)
                                  .verifyOtp(
                                      email: email, code: _otpCtrl.text.trim(),);

                              if (!mounted) return;

                              navigator.pushNamedAndRemoveUntil(
                                Routes.home,
                                (_) => false,
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              setState(() => _error = e.toString());
                            }
                          } finally {
                            if (mounted) setState(() => _verifying = false);
                          }
                        },
                  child: _verifying
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Verify'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class MoodScreen extends StatelessWidget {
  static const route = '/mood';
  const MoodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log Mood')),
      body: const Center(
        child: Text('Mood logging UI will live here (slider + note + save).'),
      ),
    );
  }
}

// Journal list screen implemented in `lib/screens/journal_list.dart`.

class AnalyticsScreen extends ConsumerWidget {
  static const route = '/analytics';
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(mentalHealthTabProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: IndexedStack(
        index: currentTab,
        children: const [
          StressManagementScreen(),
          MoodTrackingScreen(),
          SleepTrackingScreen(),
          MindfulnessScreen(),
          AnxietyManagementScreen(),
          WellnessScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentTab,
        onTap: (index) {
          ref.read(mentalHealthTabProvider.notifier).state = index;
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.cardColor,
        selectedItemColor: const Color(0xFF6C5CE7),
        unselectedItemColor: AppColors.secondaryText,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.psychology),
            label: 'Stress',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mood),
            label: 'Mood',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bedtime),
            label: 'Sleep',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Mindfulness',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.track_changes),
            label: 'Anxiety',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: 'Wellness',
          ),
        ],
      ),
    );
  }
}
