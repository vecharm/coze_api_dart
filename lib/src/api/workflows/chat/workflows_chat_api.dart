/// Workflows Chat API
///
/// 提供工作流对话功能
library;

import 'dart:convert';

import '../../../client/http_client.dart';
import '../../../models/enums.dart';
import '../../../utils/logger.dart';
import '../../chat/chat_models.dart';

/// Workflows Chat API 封装
///
/// 提供工作流对话的流式执行功能
class WorkflowChatAPI {
  final HttpClient _client;

  /// 创建 Workflow Chat API 实例
  WorkflowChatAPI(this._client);

  /// 执行对话流（流式）
  ///
  /// [request] 对话流请求
  ///
  /// 返回对话事件流
  Stream<WorkflowChatEvent> stream(WorkflowChatRequest request) async* {
    final stream = _client.stream(
      '/v1/workflows/chat',
      body: request.toJson(),
    );

    await for (final chunk in stream) {
      // 解析 SSE 格式的数据
      for (final line in chunk.split('\n')) {
        final trimmed = line.trim();
        if (trimmed.isEmpty || !trimmed.startsWith('data:')) {
          continue;
        }

        final data = trimmed.substring(5).trim();
        if (data == '[DONE]') {
          yield WorkflowChatEvent(
            event: ChatEventType.done,
            data: '[DONE]',
          );
          return;
        }

        try {
          final json = jsonDecode(data) as Map<String, dynamic>;
          final eventType = _parseEventType(json['event'] as String?);
          yield WorkflowChatEvent(
            event: eventType,
            data: json,
          );
        } catch (e) {
          logW('Failed to parse workflow chat event: $data');
        }
      }
    }
  }

  /// 解析事件类型
  ChatEventType _parseEventType(String? event) {
    if (event == null) return ChatEventType.error;

    try {
      return ChatEventType.values.firstWhere(
        (e) => e.name == event,
        orElse: () => ChatEventType.error,
      );
    } catch (_) {
      return ChatEventType.error;
    }
  }
}

/// 工作流对话请求
class WorkflowChatRequest {
  /// 工作流 ID
  final String workflowId;

  /// 附加消息列表
  final List<Message> additionalMessages;

  /// 工作流执行参数
  final Map<String, dynamic>? parameters;

  /// 应用 ID
  final String? appId;

  /// Bot ID
  final String? botId;

  /// 会话 ID
  final String? conversationId;

  /// 附加信息
  final Map<String, String>? ext;

  WorkflowChatRequest({
    required this.workflowId,
    required this.additionalMessages,
    this.parameters,
    this.appId,
    this.botId,
    this.conversationId,
    this.ext,
  });

  Map<String, dynamic> toJson() {
    return {
      'workflow_id': workflowId,
      'additional_messages': additionalMessages.map((e) => e.toJson()).toList(),
      if (parameters != null) 'parameters': parameters,
      if (appId != null) 'app_id': appId,
      if (botId != null) 'bot_id': botId,
      if (conversationId != null) 'conversation_id': conversationId,
      if (ext != null) 'ext': ext,
    };
  }
}

/// 工作流对话事件
class WorkflowChatEvent {
  /// 事件类型
  final ChatEventType event;

  /// 事件数据
  final dynamic data;

  WorkflowChatEvent({
    required this.event,
    required this.data,
  });
}
