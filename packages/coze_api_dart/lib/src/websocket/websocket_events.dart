
/// WebSocket 事件定义
///
/// 定义 Coze WebSocket API 使用的所有事件类型
library;

import '../models/enums.dart';

/// WebSocket 事件
///
/// 所有 WebSocket 消息的基类
class WebsocketEvent {
  /// 事件 ID
  final String id;

  /// 事件类型
  final WebsocketsEventType eventType;

  /// 事件数据
  final Map<String, dynamic> data;

  /// 创建时间
  final DateTime createdAt;

  WebsocketEvent({
    required this.id,
    required this.eventType,
    required this.data,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// 从 JSON 创建事件
  factory WebsocketEvent.fromJson(Map<String, dynamic> json) {
    final eventTypeStr = json['event_type'] as String? ?? 'error';
    final eventType = WebsocketsEventType.values.firstWhere(
      (e) => e.name == eventTypeStr,
      orElse: () => WebsocketsEventType.error,
    );

    return WebsocketEvent(
      id: json['id'] as String? ?? '',
      eventType: eventType,
      data: json['data'] as Map<String, dynamic>? ?? {},
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event_type': eventType.name,
      'data': data,
    };
  }

  @override
  String toString() {
    return 'WebsocketEvent(id: $id, type: ${eventType.name})';
  }
}

/// 对话消息事件
class ConversationMessageEvent extends WebsocketEvent {
  /// 消息 ID
  final String? messageId;

  /// 角色
  final RoleType? role;

  /// 内容
  final String? content;

  /// 内容类型
  final ContentType? contentType;

  ConversationMessageEvent({
    required super.id,
    required super.eventType,
    required super.data,
    this.messageId,
    this.role,
    this.content,
    this.contentType,
  });

  factory ConversationMessageEvent.fromJson(Map<String, dynamic> json) {
    final baseEvent = WebsocketEvent.fromJson(json);
    final data = baseEvent.data;

    return ConversationMessageEvent(
      id: baseEvent.id,
      eventType: baseEvent.eventType,
      data: data,
      messageId: data['id'] as String?,
      role: data['role'] != null
          ? RoleType.values.firstWhere(
              (e) => e.name == data['role'],
              orElse: () => RoleType.assistant,
            )
          : null,
      content: data['content'] as String?,
      contentType: data['content_type'] != null
          ? ContentType.values.firstWhere(
              (e) => e.name == data['content_type'],
              orElse: () => ContentType.text,
            )
          : null,
    );
  }
}

/// 对话完成事件
class ConversationChatCompletedEvent extends WebsocketEvent {
  /// 对话 ID
  final String? chatId;

  /// 会话 ID
  final String? conversationId;

  /// Bot ID
  final String? botId;

  ConversationChatCompletedEvent({
    required super.id,
    required super.eventType,
    required super.data,
    this.chatId,
    this.conversationId,
    this.botId,
  });

  factory ConversationChatCompletedEvent.fromJson(Map<String, dynamic> json) {
    final baseEvent = WebsocketEvent.fromJson(json);
    final data = baseEvent.data;

    return ConversationChatCompletedEvent(
      id: baseEvent.id,
      eventType: baseEvent.eventType,
      data: data,
      chatId: data['chat_id'] as String?,
      conversationId: data['conversation_id'] as String?,
      botId: data['bot_id'] as String?,
    );
  }
}

/// 错误事件
class ErrorEvent extends WebsocketEvent {
  /// 错误码
  final int? code;

  /// 错误消息
  final String? message;

  ErrorEvent({
    required super.id,
    required super.eventType,
    required super.data,
    this.code,
    this.message,
  });

  factory ErrorEvent.fromJson(Map<String, dynamic> json) {
    final baseEvent = WebsocketEvent.fromJson(json);
    final data = baseEvent.data;

    return ErrorEvent(
      id: baseEvent.id,
      eventType: WebsocketsEventType.error,
      data: data,
      code: data['code'] as int?,
      message: data['msg'] as String? ?? data['message'] as String?,
    );
  }
}

/// 音频转录更新事件
class AudioTranscriptUpdateEvent extends WebsocketEvent {
  /// 转录文本
  final String? transcript;

  /// 是否完成
  final bool? isFinal;

  AudioTranscriptUpdateEvent({
    required super.id,
    required super.eventType,
    required super.data,
    this.transcript,
    this.isFinal,
  });

  factory AudioTranscriptUpdateEvent.fromJson(Map<String, dynamic> json) {
    final baseEvent = WebsocketEvent.fromJson(json);
    final data = baseEvent.data;

    return AudioTranscriptUpdateEvent(
      id: baseEvent.id,
      eventType: baseEvent.eventType,
      data: data,
      transcript: data['transcript'] as String?,
      isFinal: data['is_final'] as bool?,
    );
  }
}

/// 音频完成事件
class AudioCompletedEvent extends WebsocketEvent {
  /// 音频数据（Base64 编码）
  final String? audioData;

  /// 音频格式
  final String? format;

  AudioCompletedEvent({
    required super.id,
    required super.eventType,
    required super.data,
    this.audioData,
    this.format,
  });

  factory AudioCompletedEvent.fromJson(Map<String, dynamic> json) {
    final baseEvent = WebsocketEvent.fromJson(json);
    final data = baseEvent.data;

    return AudioCompletedEvent(
      id: baseEvent.id,
      eventType: baseEvent.eventType,
      data: data,
      audioData: data['audio'] as String?,
      format: data['format'] as String?,
    );
  }
}

/// Ping/Pong 事件
class PingPongEvent extends WebsocketEvent {
  PingPongEvent({
    required super.id,
    required super.eventType,
    required super.data,
  });

  factory PingPongEvent.ping() {
    return PingPongEvent(
      id: 'ping_${DateTime.now().millisecondsSinceEpoch}',
      eventType: WebsocketsEventType.ping,
      data: {},
    );
  }

  factory PingPongEvent.pong() {
    return PingPongEvent(
      id: 'pong_${DateTime.now().millisecondsSinceEpoch}',
      eventType: WebsocketsEventType.pong,
      data: {},
    );
  }
}
