import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;

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

  runApp(const ProviderScope(child: SoulApp()));
}

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

      // WebShell presents the provided HTML UI as the app shell.
      home: const WebShell(),

      // Named routes used by the app. As features grow, prefer a Router API.
      routes: {
        LoginScreen.route: (_) => const LoginScreen(),
        OtpScreen.route: (_) => const OtpScreen(),
        HomeScreen.route: (_) => const HomeScreen(),
        MoodScreen.route: (_) => const MoodScreen(),
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
      data: (state) => state.isAuthenticated
          ? const HomeScreen()
          : const LoginScreen(),
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
  final _phoneCtrl = TextEditingController();
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
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter your phone number to receive a one-time code.',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone number',
                    hintText: '+1 555 123 4567',
                  ),
                ),
                const SizedBox(height: 12),
                if (_error != null)
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                const Spacer(),
                FilledButton(
                  onPressed: _sending
                      ? null
                      : () async {
                          setState(() {
                            _sending = true;
                            _error = null;
                          });
                          try {
                            await ref.read(authControllerProvider.notifier).sendOtp(
                                  _phoneCtrl.text.trim(),
                                );
                            if (!mounted) return;
                            Navigator.pushNamed(
                              context,
                              OtpScreen.route,
                              arguments: _phoneCtrl.text.trim(),
                            );
                          } catch (e) {
                            setState(() => _error = e.toString());
                          } finally {
                            if (mounted) setState(() => _sending = false);
                          }
                        },
                  child: _sending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Send OTP'),
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
    final phone = ModalRoute.of(context)?.settings.arguments as String? ?? '';
    return Scaffold(
      appBar: AppBar(title: const Text('Enter OTP')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text('OTP sent to $phone'),
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
                            await ref
                                .read(authControllerProvider.notifier)
                                .verifyOtp(phone: phone, code: _otpCtrl.text.trim());
                            if (!mounted) return;
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              HomeScreen.route,
                              (_) => false,
                            );
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

class HomeScreen extends ConsumerWidget {
  static const route = '/home';
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('SOUL'),
        actions: [
          IconButton(
            tooltip: 'Settings',
            onPressed: () => Navigator.pushNamed(context, SettingsScreen.route),
            icon: const Icon(Icons.settings_outlined),
          ),
          IconButton(
            tooltip: 'Logout',
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.mood_outlined),
              title: const Text('Log a Mood'),
              subtitle: const Text('Record your current feeling with a quick note'),
              onTap: () => Navigator.pushNamed(context, MoodScreen.route),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.menu_book_outlined),
              title: const Text('Journals'),
              subtitle: const Text('Reflect and keep notes'),
              onTap: () => Navigator.pushNamed(context, JournalListScreen.route),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.insights_outlined),
              title: const Text('Analytics'),
              subtitle: const Text('Trends and insights'),
              onTap: () => Navigator.pushNamed(context, AnalyticsScreen.route),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: Theme.of(context).extension<SoulGradients>()!.pastel,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Have a mindful day ✨',
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.black.withOpacity(0.7),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
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

class JournalListScreen extends StatelessWidget {
  static const route = '/journals';
  const JournalListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Journals')),
      body: const Center(
        child: Text('Journal list and CRUD coming soon.'),
      ),
    );
  }
}

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
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

/// WebShell loads the provided HTML UI (assets/web/soul_web.html) inside a WebView.
/// This preserves Riverpod/services while rendering your exact frontend.
class WebShell extends StatefulWidget {
  const WebShell({super.key});

  @override
  State<WebShell> createState() => _WebShellState();
}

class _WebShellState extends State<WebShell> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent);
    _loadHtml();
  }

  Future<void> _loadHtml() async {
    final html = await rootBundle.loadString('assets/web/soul_web.html');
    // baseUrl allows relative asset paths; using a dummy https origin for CSP compatibility.
    await _controller.loadHtmlString(html, baseUrl: 'https://app.local/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: WebViewWidget(controller: _controller),
      ),
    );
  }
}
