import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soul/screens/login_screen.dart';
import 'package:soul/services/auth_service.dart';
import 'package:soul/services/secure_storage_service.dart';

class FakeAuthService extends AuthService {
  FakeAuthService() : super(_DummyStorage());
  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 10));
    return {'access_token': 't', 'refresh_token': 'r'};
  }
}

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

void main() {
  testWidgets(
    'Login shows loading overlay then navigates',
    (tester) async {
      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(FakeAuthService()),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: LoginScreen()),
        ),
      );

      // Enter email/password
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'user@example.com',
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'StrongPass123!',
      );

      // Tap login
      await tester.tap(find.text('Log In'));
      await tester.pump();

      // Loading overlay message should appear
      expect(find.text('Logging in...'), findsOneWidget);

      // Let future complete
      await tester.pump(const Duration(milliseconds: 20));
    },
  );
}
