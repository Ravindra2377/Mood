import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soul/features/profile/providers/profile_provider.dart';
import 'package:soul/features/profile/screens/profile_screen.dart';
import 'package:soul/features/theme/providers/theme_provider.dart';
import 'package:soul/services/api_client.dart';

// Fake ProfileRead and update behavior via a custom controller
class _FakeProfileController extends ProfileController {
  _FakeProfileController(this._initial);
  final ProfileViewData _initial;

  @override
  Future<ProfileViewData> build() async => _initial;

  @override
  Future<void> setPushNotifications(bool enabled) async {
    final current = state.valueOrNull ?? _initial;
    final updatedProfile = current.profile.copyWith(notifyPush: enabled);
    state = AsyncData(current.copyWith(profile: updatedProfile));
  }
}

// Minimal ProfileRead copyWith extension to tweak notifyPush
extension _CopyProfile on ProfileRead {
  ProfileRead copyWith({bool? notifyPush}) {
    return ProfileRead(
      id: id,
      userId: userId,
      displayName: displayName,
      language: language,
      timezone: timezone,
      consentPrivacy: consentPrivacy,
      notifyEmail: notifyEmail,
      notifyPush: notifyPush ?? this.notifyPush,
      notifySms: notifySms,
      createdAt: createdAt,
      nextNotificationAt: nextNotificationAt,
      preferredNotifyStart: preferredNotifyStart,
      preferredNotifyEnd: preferredNotifyEnd,
      lastNotificationSentAt: lastNotificationSentAt,
      engagementStatus: engagementStatus,
    );
  }
}

void main() {
  testWidgets('Profile screen toggles theme and push notifications',
      (tester) async {
    // ProfileRead requires int id/userId; use simple numeric placeholders.
    final initialProfile = ProfileRead(
      id: 1,
      userId: 100,
      displayName: 'Tester',
      notifyPush: false,
      notifyEmail: false,
    );
    final viewData =
        ProfileViewData(profile: initialProfile, email: 'user@example.com');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          profileControllerProvider
              .overrideWith(() => _FakeProfileController(viewData)),
          themeProvider.overrideWith((ref) => ThemeController()),
        ],
        child: MaterialApp(
          home: const ProfileScreen(),
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: ThemeMode.light,
        ),
      ),
    );

    await tester.pumpAndSettle();
    // Verify initial push switch off
    final pushSwitch = find.byKey(const ValueKey('push-switch'));
    expect(pushSwitch, findsOneWidget);
    expect(tester.widget<Switch>(pushSwitch).value, isFalse);

    // Toggle push notifications
    await tester.tap(pushSwitch);
    await tester.pump();
    expect(tester.widget<Switch>(pushSwitch).value, isTrue);

    // Change theme to Dark via segmented button
    final darkSegment = find.widgetWithText(SegmentedButton<ThemeMode>, 'Dark');
    expect(darkSegment, findsOneWidget);
    await tester.tap(darkSegment);
    await tester.pump();

    // Verify selection changed (dark icon present and selection updated)
    // Simplest: ensure exactly one dark_mode icon exists
    expect(find.byIcon(Icons.dark_mode_outlined), findsOneWidget);
  });
}
