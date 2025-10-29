/// Chat models for AI-powered mental health conversations.
/// Includes message, session, and crisis response models.

enum MessageRole { user, assistant, system }

class ChatMessage {
  final String id;
  final String sessionId;
  final MessageRole role;
  final String content;
  final DateTime createdAt;
  final bool isStreaming;
  final int? responseTimeMs;

  ChatMessage({
    required this.id,
    required this.sessionId,
    required this.role,
    required this.content,
    required this.createdAt,
    this.isStreaming = false,
    this.responseTimeMs,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      sessionId: json['session_id'],
      role: MessageRole.values.firstWhere(
        (e) => e.toString().split('.').last == json['role'],
        orElse: () => MessageRole.assistant,
      ),
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
      responseTimeMs: json['response_time_ms'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'session_id': sessionId,
      'role': role.toString().split('.').last,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'response_time_ms': responseTimeMs,
    };
  }

  ChatMessage copyWith({
    String? id,
    String? sessionId,
    MessageRole? role,
    String? content,
    DateTime? createdAt,
    bool? isStreaming,
    int? responseTimeMs,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      role: role ?? this.role,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      isStreaming: isStreaming ?? this.isStreaming,
      responseTimeMs: responseTimeMs ?? this.responseTimeMs,
    );
  }
}

class ChatSession {
  final String id;
  final int userId;
  final DateTime startedAt;
  final DateTime? endedAt;
  final bool isActive;
  final String? sessionMood;
  final int? sessionIntensity;
  final List<String> sessionTriggers;
  final int totalMessages;
  final bool isCrisisEscalated;

  ChatSession({
    required this.id,
    required this.userId,
    required this.startedAt,
    this.endedAt,
    this.isActive = true,
    this.sessionMood,
    this.sessionIntensity,
    this.sessionTriggers = const [],
    this.totalMessages = 0,
    this.isCrisisEscalated = false,
  });

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['id'],
      userId: json['user_id'],
      startedAt: DateTime.parse(json['started_at']),
      endedAt: json['ended_at'] != null ? DateTime.parse(json['ended_at']) : null,
      isActive: json['is_active'] ?? true,
      sessionMood: json['session_mood'],
      sessionIntensity: json['session_intensity'],
      sessionTriggers: List<String>.from(json['session_triggers'] ?? []),
      totalMessages: json['total_messages'] ?? 0,
      isCrisisEscalated: json['is_crisis_escalated'] ?? false,
    );
  }
}

class CrisisResponse {
  final bool isCrisis;
  final String message;
  final Map<String, dynamic> resources;
  final List<String> immediateActions;

  CrisisResponse({
    required this.isCrisis,
    required this.message,
    required this.resources,
    required this.immediateActions,
  });

  factory CrisisResponse.fromJson(Map<String, dynamic> json) {
    return CrisisResponse(
      isCrisis: json['is_crisis'],
      message: json['message'],
      resources: Map<String, dynamic>.from(json['resources']),
      immediateActions: List<String>.from(json['immediate_actions']),
    );
  }
}
