import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soul/screens/login_screen.dart';
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

class FailingAuthService extends AuthService {
  FailingAuthService() : super(_DummyStorage());
  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 10));
    throw 'Email or password is incorrect.'; // mimic friendly mapping
  }
}

void main() {
  testWidgets('Login shows error message on failure', (tester) async {
    final container = ProviderContainer(overrides: [
      authServiceProvider.overrideWithValue(FailingAuthService()),
    ]);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: LoginScreen()),
      ),
    );

    // Enter email / password
    await tester.enterText(find.byType(TextFormField).at(0), 'wrong@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'BadPass123!');

    // Tap login
    await tester.tap(find.text('Log In'));
    await tester.pump();

    // Loading overlay visible
    expect(find.text('Logging in...'), findsOneWidget);

    // Advance time for async login to finish
    await tester.pump(const Duration(milliseconds: 50));

    // Error container should show mapped message
    expect(find.text('Email or password is incorrect.'), findsOneWidget);
  });
}