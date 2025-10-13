import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../core/config.dart';

class RuntimeConfigController extends AsyncNotifier<String> {
  static const _storageKey = 'base_url';

  FlutterSecureStorage get _storage => const FlutterSecureStorage();

  @override
  Future<String> build() async {
    // Load persisted base URL if present, otherwise fall back to compile-time value.
    final saved = await _storage.read(key: _storageKey);
    return (saved != null && saved.isNotEmpty) ? saved : AppConfig.baseUrl;
  }

  Future<void> setBaseUrl(String url) async {
    await _storage.write(key: _storageKey, value: url);
    state = AsyncData(url);
  }

  Future<void> clear() async {
    await _storage.delete(key: _storageKey);
    state = AsyncData(AppConfig.baseUrl);
  }
}

final runtimeConfigProvider = AsyncNotifierProvider<RuntimeConfigController, String>(
  () => RuntimeConfigController(),
);
