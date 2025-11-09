import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../core/config.dart';

class RuntimeConfigController extends AsyncNotifier<String> {
  static const _storageKey = 'base_url';

  FlutterSecureStorage get _storage => const FlutterSecureStorage();

  @override
  Future<String> build() async {
    // Load persisted base URL if present, otherwise fall back to the full API base (base + /api).
    final saved = await _storage.read(key: _storageKey);

    if (saved != null && saved.isNotEmpty) {
      // If the persisted value still points to the old production host while running locally,
      // override it so developers don't need to clear storage manually.
      if (saved.contains('soulapp.app') &&
          AppConfig.baseUrl.contains('10.0.2.2')) {
        return AppConfig.apiBaseUrl;
      }
      return saved;
    }

    return AppConfig.apiBaseUrl;
  }

  Future<void> setBaseUrl(String url) async {
    await _storage.write(key: _storageKey, value: url);
    state = AsyncData(url);
  }

  Future<void> clear() async {
    await _storage.delete(key: _storageKey);
    state = AsyncData(AppConfig.apiBaseUrl);
  }
}

final runtimeConfigProvider =
    AsyncNotifierProvider<RuntimeConfigController, String>(
  () => RuntimeConfigController(),
);
