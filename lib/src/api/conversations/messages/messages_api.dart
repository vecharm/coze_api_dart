/// Conversations Messages API
///
/// 提供会话消息管理功能
library;

import '../../../client/http_client.dart';
import '../../../models/errors.dart';
import '../../chat/chat_models.dart';
import 'messages_models.dart';

/// Conversations Messages API 封装
///
/// 提供会话消息的创建、修改、查询、删除功能
class ConversationMessagesAPI {
  final HttpClient _client;

  /// 创建 Conversation Messages API 实例
  ConversationMessagesAPI(this._client);

  /// 创建消息
  ///
  /// [conversationId] 会话 ID
  /// [request] 创建消息请求
  ///
  /// 返回创建的消息
  Future<Message> create(
    String conversationId,
    CreateMessageRequest request,
  ) async {
    final response = await _client.post(
      '/v1/conversation/message/create',
      queryParameters: {'conversation_id': conversationId},
      body: request.toJson(),
    );

    final data = response.jsonBody['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw CozeException(
        message: '创建消息失败：响应数据为空',
      );
    }

    return Message.fromJson(data);
  }

  /// 修改消息
  ///
  /// [conversationId] 会话 ID
  /// [messageId] 消息 ID
  /// [request] 修改消息请求
  ///
  /// 返回修改后的消息
  Future<Message> update(
    String conversationId,
    String messageId,
    UpdateMessageRequest request,
  ) async {
    final response = await _client.post(
      '/v1/conversation/message/modify',
      queryParameters: {
        'conversation_id': conversationId,
        'message_id': messageId,
      },
      body: request.toJson(),
    );

    final data = response.jsonBody['message'] as Map<String, dynamic>?;
    if (data == null) {
      throw CozeException(
        message: '修改消息失败：响应数据为空',
      );
    }

    return Message.fromJson(data);
  }

  /// 获取消息详情
  ///
  /// [conversationId] 会话 ID
  /// [messageId] 消息 ID
  ///
  /// 返回消息详情
  Future<Message> retrieve(
    String conversationId,
    String messageId,
  ) async {
    final response = await _client.get(
      '/v1/conversation/message/retrieve',
      queryParameters: {
        'conversation_id': conversationId,
        'message_id': messageId,
      },
    );

    final data = response.jsonBody['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw CozeException(
        message: '获取消息详情失败：响应数据为空',
      );
    }

    return Message.fromJson(data);
  }

  /// 列出会话消息
  ///
  /// [conversationId] 会话 ID
  /// [request] 列出消息请求（可选）
  ///
  /// 返回消息列表
  Future<ListMessagesResponse> list(
    String conversationId, {
    ListMessagesRequest? request,
  }) async {
    final response = await _client.post(
      '/v1/conversation/message/list',
      queryParameters: {'conversation_id': conversationId},
      body: request?.toJson(),
    );

    return ListMessagesResponse.fromJson(response.jsonBody);
  }

  /// 删除消息
  ///
  /// [conversationId] 会话 ID
  /// [messageId] 消息 ID
  ///
  /// 返回删除的消息
  Future<Message> delete(
    String conversationId,
    String messageId,
  ) async {
    final response = await _client.post(
      '/v1/conversation/message/delete',
      queryParameters: {
        'conversation_id': conversationId,
        'message_id': messageId,
      },
    );

    final data = response.jsonBody['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw CozeException(
        message: '删除消息失败：响应数据为空',
      );
    }

    return Message.fromJson(data);
  }
}
