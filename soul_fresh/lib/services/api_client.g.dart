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
      email: json['email'] as String,
    );

Map<String, dynamic> _$OtpRequestToJson(OtpRequest instance) =>
    <String, dynamic>{
      'email': instance.email,
    };

VerifyOtpRequest _$VerifyOtpRequestFromJson(Map<String, dynamic> json) =>
    VerifyOtpRequest(
      email: json['email'] as String,
      code: json['code'] as String,
    );

Map<String, dynamic> _$VerifyOtpRequestToJson(VerifyOtpRequest instance) =>
    <String, dynamic>{
      'email': instance.email,
      'code': instance.code,
    };

LoginRequest _$LoginRequestFromJson(Map<String, dynamic> json) => LoginRequest(
      email: json['email'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$LoginRequestToJson(LoginRequest instance) =>
    <String, dynamic>{
      'email': instance.email,
      'password': instance.password,
    };

SignupRequest _$SignupRequestFromJson(Map<String, dynamic> json) =>
    SignupRequest(
      email: json['email'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$SignupRequestToJson(SignupRequest instance) =>
    <String, dynamic>{
      'email': instance.email,
      'password': instance.password,
    };

UserRead _$UserReadFromJson(Map<String, dynamic> json) => UserRead(
      id: (json['id'] as num).toInt(),
      email: json['email'] as String,
    );

Map<String, dynamic> _$UserReadToJson(UserRead instance) => <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
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

ProfileRead _$ProfileReadFromJson(Map<String, dynamic> json) => ProfileRead(
      id: (json['id'] as num).toInt(),
      userId: (json['user_id'] as num).toInt(),
      displayName: json['display_name'] as String?,
      language: json['language'] as String?,
      timezone: json['timezone'] as String?,
      consentPrivacy: json['consent_privacy'] as bool?,
      notifyEmail: json['notify_email'] as bool?,
      notifyPush: json['notify_push'] as bool?,
      notifySms: json['notify_sms'] as bool?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      nextNotificationAt: json['next_notification_at'] == null
          ? null
          : DateTime.parse(json['next_notification_at'] as String),
      preferredNotifyStart: (json['preferred_notify_start'] as num?)?.toInt(),
      preferredNotifyEnd: (json['preferred_notify_end'] as num?)?.toInt(),
      lastNotificationSentAt: json['last_notification_sent_at'] == null
          ? null
          : DateTime.parse(json['last_notification_sent_at'] as String),
      engagementStatus: json['engagement_status'] as String?,
    );

Map<String, dynamic> _$ProfileReadToJson(ProfileRead instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'display_name': instance.displayName,
      'language': instance.language,
      'timezone': instance.timezone,
      'consent_privacy': instance.consentPrivacy,
      'notify_email': instance.notifyEmail,
      'notify_push': instance.notifyPush,
      'notify_sms': instance.notifySms,
      'created_at': instance.createdAt?.toIso8601String(),
      'next_notification_at': instance.nextNotificationAt?.toIso8601String(),
      'preferred_notify_start': instance.preferredNotifyStart,
      'preferred_notify_end': instance.preferredNotifyEnd,
      'last_notification_sent_at':
          instance.lastNotificationSentAt?.toIso8601String(),
      'engagement_status': instance.engagementStatus,
    };

ProfileUpdate _$ProfileUpdateFromJson(Map<String, dynamic> json) =>
    ProfileUpdate(
      displayName: json['display_name'] as String?,
      language: json['language'] as String?,
      timezone: json['timezone'] as String?,
      consentPrivacy: json['consent_privacy'] as bool?,
      notifyEmail: json['notify_email'] as bool?,
      notifyPush: json['notify_push'] as bool?,
      notifySms: json['notify_sms'] as bool?,
      nextNotificationAt: json['next_notification_at'] == null
          ? null
          : DateTime.parse(json['next_notification_at'] as String),
      preferredNotifyStart: (json['preferred_notify_start'] as num?)?.toInt(),
      preferredNotifyEnd: (json['preferred_notify_end'] as num?)?.toInt(),
      lastNotificationSentAt: json['last_notification_sent_at'] == null
          ? null
          : DateTime.parse(json['last_notification_sent_at'] as String),
      engagementStatus: json['engagement_status'] as String?,
    );

Map<String, dynamic> _$ProfileUpdateToJson(ProfileUpdate instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('display_name', instance.displayName);
  writeNotNull('language', instance.language);
  writeNotNull('timezone', instance.timezone);
  writeNotNull('consent_privacy', instance.consentPrivacy);
  writeNotNull('notify_email', instance.notifyEmail);
  writeNotNull('notify_push', instance.notifyPush);
  writeNotNull('notify_sms', instance.notifySms);
  writeNotNull(
      'next_notification_at', instance.nextNotificationAt?.toIso8601String());
  writeNotNull('preferred_notify_start', instance.preferredNotifyStart);
  writeNotNull('preferred_notify_end', instance.preferredNotifyEnd);
  writeNotNull('last_notification_sent_at',
      instance.lastNotificationSentAt?.toIso8601String());
  writeNotNull('engagement_status', instance.engagementStatus);
  return val;
}

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
  Future<AuthResponse> login(LoginRequest body) async {
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
          '/auth/login',
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
  Future<UserRead> signup(SignupRequest body) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(body.toJson());
    final _options = _setStreamType<UserRead>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
        .compose(
          _dio.options,
          '/auth/signup',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(
            baseUrl: _combineBaseUrls(
          _dio.options.baseUrl,
          baseUrl,
        )));
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late UserRead _value;
    try {
      _value = UserRead.fromJson(_result.data!);
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

  @override
  Future<ProfileRead> getProfile() async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<ProfileRead>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
        .compose(
          _dio.options,
          '/profile',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(
            baseUrl: _combineBaseUrls(
          _dio.options.baseUrl,
          baseUrl,
        )));
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ProfileRead _value;
    try {
      _value = ProfileRead.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<ProfileRead> updateProfile(ProfileUpdate body) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(body.toJson());
    final _options = _setStreamType<ProfileRead>(Options(
      method: 'PATCH',
      headers: _headers,
      extra: _extra,
    )
        .compose(
          _dio.options,
          '/profile',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(
            baseUrl: _combineBaseUrls(
          _dio.options.baseUrl,
          baseUrl,
        )));
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ProfileRead _value;
    try {
      _value = ProfileRead.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<Map<String, dynamic>> getInsights() async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<Map<String, dynamic>>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
        .compose(
          _dio.options,
          '/v1/insights',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(
            baseUrl: _combineBaseUrls(
          _dio.options.baseUrl,
          baseUrl,
        )));
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    final value = _result.data;
    if (value == null) {
      return <String, dynamic>{};
    }
    return value;
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
