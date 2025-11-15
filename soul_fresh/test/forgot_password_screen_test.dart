import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soul/screens/forgot_password_screen.dart';
import 'package:soul/services/auth_service.dart';
import 'package:soul/services/secure_storage_service.dart';

class _DummyStorage implements SecureStorageService {
  @override
  Future<void> clearAll() async {}
  @override
  Future<String?> getAccessToken() async => null;
  @override
  Future<String?> getRefreshToken() async => null;
  @override
  Future<bool> isLoggedIn() async => false;
  @override
  Future<void> saveAccessToken(String token) async {}
  @override
  Future<void> saveRefreshToken(String token) async {}
  @override
  Future<void> saveUserEmail(String email) async {}
  @override
  Future<String?> getUserEmail() async => null;
  @override
  Future<void> saveUserId(String userId) async {}
  @override
  Future<String?> getUserId() async => null;
}

class FakeAuthService429 extends AuthService {
  FakeAuthService429() : super(_DummyStorage());
  @override
  Future<String?> requestPasswordResetOtp(String email) async {
    // Simulate server 429 mapping from AuthService._handleError
    throw 'Too many attempts. Try again in 60s. Attempts left: 0';
  }
}

void main() {
  testWidgets(
    'ForgotPassword shows countdown and disables button on 429',
    (tester) async {
      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(FakeAuthService429()),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: ForgotPasswordScreen()),
        ),
      );

      // Enter a valid email
      await tester.enterText(
        find.byType(TextFormField).first,
        'user@example.com',
      );

      // Tap Send Code -> triggers 429
      await tester.tap(find.text('Send Code'));
      await tester.pump();

      // Advance time to allow Timer.periodic tick
      await tester.pump(const Duration(seconds: 1));

      // Expect countdown text
      expect(find.textContaining('Retry in'), findsOneWidget);

      // Button should be disabled
      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);
    },
  );
}
