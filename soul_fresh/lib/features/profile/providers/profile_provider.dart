import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/api_client.dart';
import '../../../services/secure_storage_service.dart';
import '../../../services/user_service.dart';

class ProfileViewData {
  ProfileViewData({required this.profile, required this.email});

  final ProfileRead profile;
  final String? email;

  String get displayEmail => email ?? 'you@soul.app';

  String get displayName {
    final name = profile.displayName?.trim();
    if (name != null && name.isNotEmpty) {
      return name;
    }
    final emailValue = displayEmail.trim();
    final atIndex = emailValue.indexOf('@');
    if (atIndex > 0) {
      final candidate = emailValue.substring(0, atIndex).trim();
      if (candidate.isNotEmpty) {
        return _capitalize(candidate);
      }
    }
    return 'Soul member';
  }

  String get avatarInitial {
    final name = displayName.trim();
    if (name.isEmpty) {
      return 'S';
    }
    final codeUnit = name.codeUnitAt(0);
    return String.fromCharCode(codeUnit).toUpperCase();
  }

  bool get notifyPushEnabled => profile.notifyPush ?? false;
  bool get notifyEmailEnabled => profile.notifyEmail ?? false;

  ProfileViewData copyWith({ProfileRead? profile, String? email}) {
    return ProfileViewData(
      profile: profile ?? this.profile,
      email: email ?? this.email,
    );
  }

  static String _capitalize(String value) {
    if (value.isEmpty) {
      return value;
    }
    return value[0].toUpperCase() + value.substring(1);
  }
}

final profileControllerProvider =
    AsyncNotifierProvider<ProfileController, ProfileViewData>(
  ProfileController.new,
);

class ProfileController extends AsyncNotifier<ProfileViewData> {
  UserService get _service => ref.read(userServiceProvider);
  SecureStorageService get _secure => ref.read(secureStorageServiceProvider);

  @override
  Future<ProfileViewData> build() => _loadProfile();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_loadProfile);
  }

  Future<void> setPushNotifications(bool enabled) async {
    final previous = state.valueOrNull;
    state = AsyncValue.loading(previous: state);
    state = await AsyncValue.guard(() async {
      final updated = await _service.updateUserProfile(
        ProfileUpdate(notifyPush: enabled),
      );
      final email = previous?.email ?? await _secure.getUserEmail();
      return ProfileViewData(profile: updated, email: email);
    });
  }

  Future<ProfileViewData> _loadProfile() async {
    final profile = await _service.getUserProfile();
    final email = await _secure.getUserEmail();
    return ProfileViewData(profile: profile, email: email);
  }
}
