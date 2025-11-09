import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../core/auth/token_storage.dart';
import '../../../core/network/app_config.dart';
import '../../../core/network/http_client_provider.dart';
import '../models/journal_entry.dart';

class JournalService {
  JournalService({
    required http.Client client,
    required AccessTokenLoader tokenLoader,
    String? baseUrl,
  })  : _client = client,
        _tokenLoader = tokenLoader,
        _baseUrl = baseUrl ?? AppConfig.apiBaseUrl;

  final http.Client _client;
  final AccessTokenLoader _tokenLoader;
  final String _baseUrl;

  Uri _buildUri(String path, {Map<String, dynamic>? queryParameters}) {
    final normalizedBase = _baseUrl.endsWith('/')
        ? _baseUrl.substring(0, _baseUrl.length - 1)
        : _baseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$normalizedBase$normalizedPath').replace(
      queryParameters: queryParameters?.map(
        (key, value) => MapEntry(key, value?.toString()),
      ),
    );
  }

  Future<List<JournalEntry>> fetchEntries() async {
    final uri = _buildUri('/journals');
    final headers = await _buildHeaders();
    final response = await _client.get(uri, headers: headers);
    _ensureSuccess(response, uri);

    final payload = json.decode(response.body) as List<dynamic>;
    return payload
        .map((item) => JournalEntry.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<JournalEntry> createEntry({
    String? title,
    required String body,
    String mood = 'neutral',
  }) async {
    final uri = _buildUri('/journals');
    final headers = await _buildHeaders();
    final response = await _client.post(
      uri,
      headers: {
        ...headers,
        'Content-Type': 'application/json',
      },
      body: json.encode({
        if (title?.isNotEmpty ?? false) 'title': title,
        'content': body,
        'mood': mood,
      }),
    );
    _ensureSuccess(response, uri);
    final jsonMap = json.decode(response.body) as Map<String, dynamic>;
    return JournalEntry.fromJson(jsonMap);
  }

  Future<void> deleteEntry(String id) async {
    final uri = _buildUri('/journals/$id');
    final headers = await _buildHeaders();
    final response = await _client.delete(uri, headers: headers);
    if (response.statusCode == 204) {
      return;
    }
    _ensureSuccess(response, uri);
  }

  Future<Map<String, String>> _buildHeaders() async {
    final token = await _tokenLoader();
    final headers = <String, String>{};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  void _ensureSuccess(http.Response response, Uri uri) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    final message = 'Journal API request failed (${response.statusCode}) for ${uri.path}';
    throw JournalApiException(
      statusCode: response.statusCode,
      uri: uri,
      body: response.body,
      message: message,
    );
  }
}

class JournalApiException implements Exception {
  JournalApiException({
    required this.statusCode,
    required this.uri,
    this.body,
    this.message,
  });

  final int statusCode;
  final Uri uri;
  final String? body;
  final String? message;

  @override
  String toString() {
    return 'JournalApiException(statusCode: $statusCode, uri: $uri, message: $message, body: $body)';
  }
}

final journalServiceProvider = Provider<JournalService>((ref) {
  final client = ref.watch(httpClientProvider);
  final tokenLoader = ref.watch(accessTokenLoaderProvider);
  return JournalService(client: client, tokenLoader: tokenLoader);
});
