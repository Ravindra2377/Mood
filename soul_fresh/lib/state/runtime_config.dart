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
    return (saved != null && saved.isNotEmpty) ? saved : AppConfig.apiBaseUrl;
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
