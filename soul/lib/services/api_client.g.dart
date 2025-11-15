// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_client.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageResponse _$MessageResponseFromJson(Map<String, dynamic> json) =>
    MessageResponse(
      message: json['message'] as String,
    );

Map<String, dynamic> _$MessageResponseToJson(MessageResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
    };

OtpRequest _$OtpRequestFromJson(Map<String, dynamic> json) => OtpRequest(
      phone: json['phone'] as String,
    );

Map<String, dynamic> _$OtpRequestToJson(OtpRequest instance) =>
    <String, dynamic>{
      'phone': instance.phone,
    };

VerifyOtpRequest _$VerifyOtpRequestFromJson(Map<String, dynamic> json) =>
    VerifyOtpRequest(
      phone: json['phone'] as String,
      code: json['code'] as String,
    );

Map<String, dynamic> _$VerifyOtpRequestToJson(VerifyOtpRequest instance) =>
    <String, dynamic>{
      'phone': instance.phone,
      'code': instance.code,
    };

AuthResponse _$AuthResponseFromJson(Map<String, dynamic> json) => AuthResponse(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String?,
      tokenType: json['token_type'] as String?,
    );

Map<String, dynamic> _$AuthResponseToJson(AuthResponse instance) =>
    <String, dynamic>{
      'access_token': instance.accessToken,
      'refresh_token': instance.refreshToken,
      'token_type': instance.tokenType,
    };

MoodEntry _$MoodEntryFromJson(Map<String, dynamic> json) => MoodEntry(
      id: json['id'] as String,
      score: (json['score'] as num).toInt(),
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$MoodEntryToJson(MoodEntry instance) => <String, dynamic>{
      'id': instance.id,
      'score': instance.score,
      'note': instance.note,
      'created_at': instance.createdAt.toIso8601String(),
    };

CreateMoodRequest _$CreateMoodRequestFromJson(Map<String, dynamic> json) =>
    CreateMoodRequest(
      score: (json['score'] as num).toInt(),
      note: json['note'] as String?,
    );

Map<String, dynamic> _$CreateMoodRequestToJson(CreateMoodRequest instance) =>
    <String, dynamic>{
      'score': instance.score,
      'note': instance.note,
    };

JournalEntry _$JournalEntryFromJson(Map<String, dynamic> json) => JournalEntry(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$JournalEntryToJson(JournalEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'content': instance.content,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

CreateJournalRequest _$CreateJournalRequestFromJson(
        Map<String, dynamic> json) =>
    CreateJournalRequest(
      title: json['title'] as String,
      content: json['content'] as String,
    );

Map<String, dynamic> _$CreateJournalRequestToJson(
        CreateJournalRequest instance) =>
    <String, dynamic>{
      'title': instance.title,
      'content': instance.content,
    };

UpdateJournalRequest _$UpdateJournalRequestFromJson(
        Map<String, dynamic> json) =>
    UpdateJournalRequest(
      title: json['title'] as String?,
      content: json['content'] as String?,
    );

Map<String, dynamic> _$UpdateJournalRequestToJson(
        UpdateJournalRequest instance) =>
    <String, dynamic>{
      'title': instance.title,
      'content': instance.content,
    };

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps,no_leading_underscores_for_local_identifiers,unused_element

class _ApiClient implements ApiClient {
  _ApiClient(
    this._dio, {
    this.baseUrl,
    this.errorLogger,
  });

  final Dio _dio;

  String? baseUrl;

  final ParseErrorLogger? errorLogger;

  @override
  Future<MessageResponse> requestOtp(OtpRequest body) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(body.toJson());
    final _options = _setStreamType<MessageResponse>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
        .compose(
          _dio.options,
          '/auth/otp/request',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(
            baseUrl: _combineBaseUrls(
          _dio.options.baseUrl,
          baseUrl,
        )));
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late MessageResponse _value;
    try {
      _value = MessageResponse.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<AuthResponse> verifyOtp(VerifyOtpRequest body) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(body.toJson());
    final _options = _setStreamType<AuthResponse>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
        .compose(
          _dio.options,
          '/auth/verify-otp',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(
            baseUrl: _combineBaseUrls(
          _dio.options.baseUrl,
          baseUrl,
        )));
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late AuthResponse _value;
    try {
      _value = AuthResponse.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<MessageResponse> logout() async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<MessageResponse>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
        .compose(
          _dio.options,
          '/auth/logout',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(
            baseUrl: _combineBaseUrls(
          _dio.options.baseUrl,
          baseUrl,
        )));
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late MessageResponse _value;
    try {
      _value = MessageResponse.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<List<MoodEntry>> listMoods({
    int? page,
    int? limit,
    String? fromIso,
    String? toIso,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'page': page,
      r'limit': limit,
      r'from': fromIso,
      r'to': toIso,
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<List<MoodEntry>>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
        .compose(
          _dio.options,
          '/moods',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(
            baseUrl: _combineBaseUrls(
          _dio.options.baseUrl,
          baseUrl,
        )));
    final _result = await _dio.fetch<List<dynamic>>(_options);
    late List<MoodEntry> _value;
    try {
      _value = _result.data!
          .map((dynamic i) => MoodEntry.fromJson(i as Map<String, dynamic>))
          .toList();
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<MoodEntry> createMood(CreateMoodRequest body) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(body.toJson());
    final _options = _setStreamType<MoodEntry>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
        .compose(
          _dio.options,
          '/moods',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(
            baseUrl: _combineBaseUrls(
          _dio.options.baseUrl,
          baseUrl,
        )));
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late MoodEntry _value;
    try {
      _value = MoodEntry.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<List<JournalEntry>> listJournals({
    int? page,
    int? limit,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'page': page,
      r'limit': limit,
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<List<JournalEntry>>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
        .compose(
          _dio.options,
          '/journals',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(
            baseUrl: _combineBaseUrls(
          _dio.options.baseUrl,
          baseUrl,
        )));
    final _result = await _dio.fetch<List<dynamic>>(_options);
    late List<JournalEntry> _value;
    try {
      _value = _result.data!
          .map((dynamic i) => JournalEntry.fromJson(i as Map<String, dynamic>))
          .toList();
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<JournalEntry> createJournal(CreateJournalRequest body) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(body.toJson());
    final _options = _setStreamType<JournalEntry>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
        .compose(
          _dio.options,
          '/journals',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(
            baseUrl: _combineBaseUrls(
          _dio.options.baseUrl,
          baseUrl,
        )));
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late JournalEntry _value;
    try {
      _value = JournalEntry.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<JournalEntry> updateJournal(
    String id,
    UpdateJournalRequest body,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(body.toJson());
    final _options = _setStreamType<JournalEntry>(Options(
      method: 'PUT',
      headers: _headers,
      extra: _extra,
    )
        .compose(
          _dio.options,
          '/journals/${id}',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(
            baseUrl: _combineBaseUrls(
          _dio.options.baseUrl,
          baseUrl,
        )));
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late JournalEntry _value;
    try {
      _value = JournalEntry.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<MessageResponse> deleteJournal(String id) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<MessageResponse>(Options(
      method: 'DELETE',
      headers: _headers,
      extra: _extra,
    )
        .compose(
          _dio.options,
          '/journals/${id}',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(
            baseUrl: _combineBaseUrls(
          _dio.options.baseUrl,
          baseUrl,
        )));
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late MessageResponse _value;
    try {
      _value = MessageResponse.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  RequestOptions _setStreamType<T>(RequestOptions requestOptions) {
    if (T != dynamic &&
        !(requestOptions.responseType == ResponseType.bytes ||
            requestOptions.responseType == ResponseType.stream)) {
      if (T == String) {
        requestOptions.responseType = ResponseType.plain;
      } else {
        requestOptions.responseType = ResponseType.json;
      }
    }
    return requestOptions;
  }

  String _combineBaseUrls(
    String dioBaseUrl,
    String? baseUrl,
  ) {
    if (baseUrl == null || baseUrl.trim().isEmpty) {
      return dioBaseUrl;
    }

    final url = Uri.parse(baseUrl);

    if (url.isAbsolute) {
      return url.toString();
    }

    return Uri.parse(dioBaseUrl).resolveUri(url).toString();
  }
}
