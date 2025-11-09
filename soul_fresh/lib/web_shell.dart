import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:flutter/services.dart' show rootBundle;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:webview_flutter/webview_flutter.dart';

import 'core/config.dart';

import 'services/api_client.dart';

import 'state/app_state.dart';

/// WebView shell that renders the provided HTML UI (assets/web/soul_web.html)

/// and bridges OTP actions to the native Flutter backend client.

///

/// This preserves your exact HTML/CSS UI while delegating network requests

/// (request OTP / verify OTP) to the existing Dio/Retrofit client.

///

/// Requirements:

/// - Add to pubspec.yaml:

///     dependencies:

///       webview_flutter: ^4.7.0

/// - Ensure the asset is declared (already added by previous edits):

///     assets:

///       - assets/web/soul_web.html

class SoulWebShell extends ConsumerStatefulWidget {
  const SoulWebShell({super.key});

  @override
  ConsumerState<SoulWebShell> createState() => _SoulWebShellState();
}

class _SoulWebShellState extends ConsumerState<SoulWebShell> {
  late final WebViewController _controller;

  bool _isLoading = true;

  ApiClient get _api => ref.read(apiClientProvider);

  TokenRepository get _tokens => ref.read(tokenRepositoryProvider);

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel('SoulNative', onMessageReceived: _onJsMessage)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) async {
            await _injectBridgeJs();

            if (mounted) setState(() => _isLoading = false);
          },
        ),
      );

    _loadHtml();
  }

  Future<void> _loadHtml() async {
    final html = await rootBundle.loadString('assets/web/soul_web.html');

    // Provide BASE_URL to the page if it needs to read it (optional).

    final injectedHead = '''

      <script>

        window.__SOUL_BASE_URL__ = ${jsonEncode(AppConfig.baseUrl)};

      </script>

    ''';

    final content = html.replaceFirst('</head>', '$injectedHead</head>');

    await _controller.loadHtmlString(content, baseUrl: AppConfig.baseUrl);
  }

  /// Inject a small bridge that:

  /// - Exposes window.SoulBridge.call(action, payload) -> Promise

  /// - Overrides handleSignup() and verifyOtp() in the provided HTML to

  ///   call the native bridge instead of Firebase.

  Future<void> _injectBridgeJs() async {
    const js = r'''

(function() {

  if (window.SoulBridge) return;



  const callbacks = {};

  function uid() { return Math.random().toString(36).slice(2) + Date.now().toString(36); }



  window.SoulBridge = {

    call(action, payload) {

      return new Promise((resolve, reject) => {

        const id = uid();

        callbacks[id] = { resolve, reject };

        const msg = JSON.stringify({ id, action, payload: payload || {} });

        if (window.SoulNative && window.SoulNative.postMessage) {

          window.SoulNative.postMessage(msg);

        } else {

          reject('Native bridge not available');

        }

      });

    },

    _resolve(id, data) {

      const cb = callbacks[id];

      if (!cb) return;

      cb.resolve(data);

      delete callbacks[id];

    },

    _reject(id, err) {

      const cb = callbacks[id];

      if (!cb) return;

      cb.reject(err);

      delete callbacks[id];

    }

  };



  // Helper DOM utilities

  function $(sel){ return document.querySelector(sel); }



  // Nudge the existing HTML to prefer email over phone when possible.
  // - Make login first input an email field
  const loginFirstInput = document.querySelector('#login-screen input[type="tel"], #login-screen input');
  if (loginFirstInput) {
    loginFirstInput.type = 'email';
    if (!loginFirstInput.placeholder || /phone/i.test(loginFirstInput.placeholder)) {
      loginFirstInput.placeholder = 'Email address';
    }
  }
  // - Promote signup phone input to email (if present)
  const signupEmailEl = document.getElementById('signup-email') || document.getElementById('signup-phone');
  if (signupEmailEl) {
    signupEmailEl.type = 'email';
    signupEmailEl.id = 'signup-email';
    if (!signupEmailEl.placeholder || /phone/i.test(signupEmailEl.placeholder)) {
      signupEmailEl.placeholder = 'Email address';
    }
  }
  // - Update OTP screen copy
  const otpTitle = document.querySelector('#otp-screen h1');
  if (otpTitle) otpTitle.textContent = 'Verify Email';
  const otpDesc = document.querySelector('#otp-screen p');
  if (otpDesc) otpDesc.textContent = 'Enter the OTP sent to your email.';

  // Override Signup and OTP verification flows to call native backend.

  // This keeps the original UI intact while switching to email-based OTP.

  window.handleSignup = async function() {

    try {

      const emailInput = $('#signup-email') || $('#signup-phone');
      const email = (emailInput?.value || '').trim();

      const username = ($('#signup-username')?.value || '').trim();

      const age = ($('#signup-age')?.value || '').trim();

      const password = ($('#signup-password')?.value || '').trim();



      if (!email) { alert('Please enter a valid email address'); return; }

      // Persist the email across screens
      window.__SOUL_EMAIL__ = email;

      // Request OTP via native backend

      await window.SoulBridge.call('requestOtp', { email });

      // Navigate to OTP screen

      if (typeof window.navigateTo === 'function') {

        window.navigateTo('otp-screen');

      } else {

        alert('navigateTo not found in page.');

      }

    } catch (e) {

      console.error('Signup/OTP request error:', e);

      alert('Failed to request OTP. ' + (e?.message || e));

    }

  };



  window.verifyOtp = async function() {

    try {

      const code = ($('#otp-input')?.value || '').trim();

      const email = window.__SOUL_EMAIL__ || ($('#signup-email')?.value || $('#signup-phone')?.value || '').trim();



      if (!email || !code || code.length < 4) { alert('Enter valid email and 6-digit OTP.'); return; }



      const result = await window.SoulBridge.call('verifyOtp', { email, code });

      // If success, token is returned, switch to home

      if (typeof window.navigateTo === 'function') {

        window.navigateTo('home-screen');

        const bottomNav = document.getElementById('bottom-nav');

        if (bottomNav) bottomNav.style.display = 'block';

        const greet = document.getElementById('user-greeting');

        if (greet) greet.textContent = 'Hi, there';

      } else {

        alert('Login successful (token stored).');

      }

    } catch (e) {

      console.error('OTP verify error:', e);

      alert('Failed to verify OTP. ' + (e?.message || e));

    }

  };



  console.log('[SOUL] Bridge injected (email-based).');

})();

''';

    await _controller.runJavaScript(js);
  }

  Future<void> _onJsMessage(JavaScriptMessage message) async {
    try {
      final data = jsonDecode(message.message) as Map<String, dynamic>;

      final id = data['id'] as String?;

      final action = data['action'] as String?;

      final payload = (data['payload'] as Map?)?.cast<String, dynamic>() ??
          <String, dynamic>{};

      if (id == null || action == null) return;

      switch (action) {
        case 'requestOtp':
          await _handleRequestOtp(id, payload);

          break;

        case 'verifyOtp':
          await _handleVerifyOtp(id, payload);

          break;

        default:
          await _rejectJs(id, 'Unknown action: $action');
      }
    } catch (e) {
      // If parsing fails, we cannot correlate to an id; best effort log in JS

      await _controller.runJavaScript(
        "console.error('[SOUL] Bridge message error:', ${jsonEncode(e.toString())});",
      );
    }
  }

  Future<void> _handleRequestOtp(
    String id,
    Map<String, dynamic> payload,
  ) async {
    final email = (payload['email'] as String?)?.trim() ??
        (payload['phone'] as String?)?.trim();

    if (email == null || email.isEmpty) {
      await _rejectJs(id, 'Email is required');
      return;
    }

    try {
      await _api.requestOtp(OtpRequest(email: email));
      await _resolveJs(id, {'status': 'ok'});
    } catch (e) {
      await _rejectJs(id, e.toString());
    }
  }

  Future<void> _handleVerifyOtp(String id, Map<String, dynamic> payload) async {
    final email = (payload['email'] as String?)?.trim() ??
        (payload['phone'] as String?)?.trim();

    final code = (payload['code'] as String?)?.trim();

    if (email == null || email.isEmpty || code == null || code.isEmpty) {
      await _rejectJs(id, 'Email and code are required');

      return;
    }

    try {
      final res =
          await _api.verifyOtp(VerifyOtpRequest(email: email, code: code));
      // Persist token in secure storage via the controller

      await _tokens.saveAccessToken(res.accessToken);

      // Notify Riverpod auth state

      await ref.read(authControllerProvider.notifier).setToken(res.accessToken);

      await _resolveJs(id, {'status': 'ok', 'access_token': res.accessToken});
    } catch (e) {
      await _rejectJs(id, e.toString());
    }
  }

  Future<void> _resolveJs(String id, Map<String, dynamic> data) async {
    final arg = jsonEncode(data);

    await _controller.runJavaScript(
      'window.SoulBridge && window.SoulBridge._resolve(${jsonEncode(id)}, $arg);',
    );
  }

  Future<void> _rejectJs(String id, String error) async {
    final arg = jsonEncode(error);

    await _controller.runJavaScript(
      'window.SoulBridge && window.SoulBridge._reject(${jsonEncode(id)}, $arg);',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Use SafeArea to avoid cutouts

          Positioned.fill(
            child: SafeArea(
              child: WebViewWidget(controller: _controller),
            ),
          ),

          if (_isLoading)
            const Positioned.fill(
              child: ColoredBox(
                color: Colors.white,
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }
}
