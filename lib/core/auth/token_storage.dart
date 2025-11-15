import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  const TokenStorage();

  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userEmailKey = 'user_email';
  static const String userIdKey = 'user_id';

  Future<String?> readAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(accessTokenKey);
  }

  Future<void> writeAccessToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(accessTokenKey, token);
  }

  Future<void> clearAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(accessTokenKey);
  }

  Future<void> writeRefreshToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(refreshTokenKey, token);
  }

  Future<String?> readRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(refreshTokenKey);
  }

  Future<void> clearRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(refreshTokenKey);
  }

  Future<void> writeUserEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(userEmailKey, email);
  }

  Future<String?> readUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(userEmailKey);
  }

  Future<void> clearUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(userEmailKey);
  }

  Future<void> writeUserId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(userIdKey, id);
  }

  Future<String?> readUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(userIdKey);
  }

  Future<void> clearUserId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(userIdKey);
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(accessTokenKey);
    await prefs.remove(refreshTokenKey);
    await prefs.remove(userEmailKey);
    await prefs.remove(userIdKey);
  }
}

typedef AccessTokenLoader = Future<String?> Function();

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return const TokenStorage();
});

final accessTokenLoaderProvider = Provider<AccessTokenLoader>((ref) {
  final storage = ref.watch(tokenStorageProvider);
  return storage.readAccessToken;
});
