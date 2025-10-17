import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'state/app_state.dart';
import 'state/runtime_config.dart';
import 'state/ui_state.dart';
import 'screens/journal_list.dart';
import 'screens/meditation.dart';
import 'screens/onboarding_screen.dart';
import 'screens/expression_screen.dart';
import 'screens/enhanced_meditation_screen.dart';
import 'screens/activities_screen.dart';
import 'screens/resources_screen.dart';
import 'widgets/mood_widgets.dart';
import 'widgets/mood_selector.dart';
import 'widgets/time_filter_pills.dart';
import 'widgets/activity_card.dart';
import 'models/journal_entry_adapter.dart';
import 'models/app_models.dart';
import 'data/appMockData.dart';

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

  runApp(const ProviderScope(child: SoulApp()));
}

// Toggle this during local testing to bypass the OTP network flow.
// When true the app will directly set a dummy access token and navigate
// to the Home screen so you can test signup/login UI without a backend.
const bool skipOtp = false;

class SoulApp extends ConsumerWidget {
  const SoulApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'SOUL',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,

  // Use the AuthGate to decide between Login and Home based on token state.
  home: const _AuthGate(),

      // Named routes used by the app. As features grow, prefer a Router API.
      routes: {
        LoginScreen.route: (_) => const LoginScreen(),
        OnboardingScreen.route: (_) => const OnboardingScreen(),
        HomeScreen.route: (_) => const HomeScreen(),
        MoodScreen.route: (_) => const MoodScreen(),
        ExpressionScreen.route: (_) => const ExpressionScreen(),
        EnhancedMeditationScreen.route: (_) => const EnhancedMeditationScreen(),
        ActivitiesScreen.route: (_) => const ActivitiesScreen(),
        ResourcesScreen.route: (_) => const ResourcesScreen(),
        JournalListScreen.route: (_) => const JournalListScreen(),
        AnalyticsScreen.route: (_) => const AnalyticsScreen(),
        SettingsScreen.route: (_) => const SettingsScreen(),
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
        fillColor: base.colorScheme.surface.withOpacity(0.9),
      ),
      cardTheme: base.cardTheme.copyWith(
        elevation: 0,
        surfaceTintColor: base.colorScheme.surface,
      ),
      scaffoldBackgroundColor: const Color(0xFFF7F9FC),
      extensions: <ThemeExtension<dynamic>>[
        SoulGradients(
          pastel: const LinearGradient(
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
          ThemeData(brightness: Brightness.dark).textTheme),
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
        SoulGradients(
          pastel: const LinearGradient(
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
      data: (state) =>
          state.isAuthenticated ? const HomeScreen() : const LoginScreen(),
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
                                  if (skipOtp) {
                                    // For local dev, just set token and navigate
                                    await ref
                                        .read(authControllerProvider.notifier)
                                        .setToken('local-debug-token');
                                    if (!mounted) return;
                                    Navigator.pushNamedAndRemoveUntil(
                                        context, HomeScreen.route, (_) => false);
                                  } else {
                                    await ref
                                        .read(authControllerProvider.notifier)
                                        .signup(email: email, password: password);
                                  }
                                } catch (e) {
                                  setState(() => _error = e.toString());
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
                                  if (skipOtp) {
                                    await ref
                                        .read(authControllerProvider.notifier)
                                        .setToken('local-debug-token');
                                    if (!mounted) return;
                                    Navigator.pushNamedAndRemoveUntil(
                                        context, HomeScreen.route, (_) => false);
                                  } else {
                                    await ref
                                        .read(authControllerProvider.notifier)
                                        .login(email: email, password: password);
                                  }
                                } catch (e) {
                                  setState(() => _error = e.toString());
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
                            if (skipOtp) {
                              // Accept any code in local debug mode.
                              await ref
                                  .read(authControllerProvider.notifier)
                                  .setToken('local-debug-token');

                              if (!mounted) return;

                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                HomeScreen.route,
                                (_) => false,
                              );
                            } else {
                              await ref
                                  .read(authControllerProvider.notifier)
                                  .verifyOtp(
                                      email: email, code: _otpCtrl.text.trim());

                              if (!mounted) return;

                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                HomeScreen.route,
                                (_) => false,
                              );
                            }
                          } catch (e) {
                            setState(() => _error = e.toString());
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

class HomeScreen extends ConsumerStatefulWidget {
  static const route = '/home';
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  void _onNavTap(int index) {
    setState(() => _selectedIndex = index);
    switch (index) {
      case 1:
        Navigator.pushNamed(context, JournalListScreen.route);
        break;
      case 2:
        Navigator.pushNamed(context, AnalyticsScreen.route);
        break;
      case 3:
        Navigator.pushNamed(context, SettingsScreen.route);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final gradient = Theme.of(context).extension<SoulGradients>()?.pastel ??
        const LinearGradient(colors: [Colors.blue, Colors.teal]);
    final selectedMood = ref.watch(selectedMoodProvider);
    final selectedFilter = ref.watch(timeFilterProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: gradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundImage: NetworkImage(AppMockData.userAvatarUrl),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hi, ${AppMockData.userName}',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Text(
                            'How are you doing today?',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.notifications_outlined),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Time filter pills
                TimeFilterPills(
                  selectedFilter: selectedFilter,
                  onFilterSelected: (filter) {
                    ref.read(timeFilterProvider.notifier).state = filter;
                  },
                ),
                const SizedBox(height: 16),
                // Search bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const TextField(
                    decoration: InputDecoration(
                      hintText: 'Search',
                      border: InputBorder.none,
                      icon: Icon(Icons.search, size: 20),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Daily mood section
                const Text(
                  'Daily mood',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                MoodSelector(
                  selectedMood: selectedMood,
                  onMoodSelected: (mood) {
                    ref.read(selectedMoodProvider.notifier).state = mood;
                  },
                ),
                const SizedBox(height: 24),
                // Activities section
                const Text(
                  'Activities',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 110,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: AppMockData.activities.length,
                    itemBuilder: (context, index) {
                      final activity = AppMockData.activities[index];
                      return ActivityCard(
                        activity: activity,
                        onTap: () {
                          if (activity.type == ActivityType.yoga) {
                            Navigator.pushNamed(context, EnhancedMeditationScreen.route);
                          } else if (activity.type == ActivityType.journal) {
                            Navigator.pushNamed(context, ExpressionScreen.route);
                          }
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                // Quick actions
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, ActivitiesScreen.route);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.all(16),
                        ),
                        child: const Text('View Activities'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, ResourcesScreen.route);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.all(16),
                        ),
                        child: const Text('Self Help'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: () => _onNavTap(0),
                icon: CircleAvatar(
                  radius: 18,
                  backgroundColor: _selectedIndex == 0 ? Colors.black : Colors.white,
                  child: Icon(
                    Icons.home,
                    color: _selectedIndex == 0 ? Colors.white : Colors.black,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _onNavTap(1),
                icon: CircleAvatar(
                  radius: 18,
                  backgroundColor: _selectedIndex == 1 ? Colors.black : Colors.white,
                  child: Icon(
                    Icons.menu_book_outlined,
                    color: _selectedIndex == 1 ? Colors.white : Colors.black,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _onNavTap(2),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _selectedIndex == 2 ? Colors.black : Colors.white,
                  ),
                  child: Icon(
                    Icons.bar_chart,
                    color: _selectedIndex == 2 ? Colors.white : Colors.black,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _onNavTap(3),
                icon: CircleAvatar(
                  radius: 18,
                  backgroundColor: _selectedIndex == 3 ? Colors.black : Colors.white,
                  child: Icon(
                    Icons.settings,
                    color: _selectedIndex == 3 ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ],
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

class AnalyticsScreen extends StatelessWidget {
  static const route = '/analytics';
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: const Center(
        child: Text('Charts and insights will be rendered here.'),
      ),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  static const route = '/settings';
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  ThemeMode _mode = ThemeMode.system;
  final _controller = TextEditingController();
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          const ListTile(
            title: Text('Appearance'),
            subtitle: Text('Light / Dark will follow system for now'),
          ),
          RadioListTile<ThemeMode>(
            title: const Text('System'),
            value: ThemeMode.system,
            groupValue: _mode,
            onChanged: (v) => setState(() => _mode = v ?? ThemeMode.system),
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Light'),
            value: ThemeMode.light,
            groupValue: _mode,
            onChanged: (v) => setState(() => _mode = v ?? ThemeMode.system),
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Dark'),
            value: ThemeMode.dark,
            groupValue: _mode,
            onChanged: (v) => setState(() => _mode = v ?? ThemeMode.system),
          ),
          const Divider(),
          const ListTile(
            title: Text('Notifications'),
            subtitle: Text('Preferences coming soon'),
          ),
          const Divider(),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'More settings will be added as features land (consent, data export, etc.)',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Consumer(
              builder: (context, ref, child) {
                final cfg = ref.watch(runtimeConfigProvider);
                return cfg.when(
                  data: (v) {
                    _controller.text = v;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('API Base URL',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _controller,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder()),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: _saving
                                  ? null
                                  : () async {
                                      setState(() => _saving = true);
                                      await ref
                                          .read(runtimeConfigProvider.notifier)
                                          .setBaseUrl(_controller.text.trim());
                                      setState(() => _saving = false);
                                    },
                              child: _saving
                                  ? const SizedBox(
                                      height: 16,
                                      width: 16,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2))
                                  : const Text('Save'),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton(
                              onPressed: _saving
                                  ? null
                                  : () async {
                                      setState(() => _saving = true);
                                      await ref
                                          .read(runtimeConfigProvider.notifier)
                                          .clear();
                                      setState(() => _saving = false);
                                    },
                              child: const Text('Reset to default'),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, st) => Text('Error loading config: $e'),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
