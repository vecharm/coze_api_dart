
/// 会话管理 API
///
/// 提供会话的创建、查询、管理等接口
library;

import '../../client/http_client.dart';
import '../../models/errors.dart';
import 'conversations_models.dart';

/// 会话管理 API 封装
///
/// 提供创建会话、获取会话信息、列出会话等功能
class ConversationsAPI {
  final HttpClient _client;

  /// 创建 Conversations API 实例
  ConversationsAPI(this._client);

  /// 创建会话
  ///
  /// [request] 创建会话请求
  ///
  /// 返回创建的会话对象
  Future<Conversation> create(CreateConversationRequest request) async {
    final response = await _client.post(
      '/v1/conversation/create',
      body: request.toJson(),
    );

    final data = response.jsonBody['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw CozeException(
        message: '创建会话失败：响应数据为空',
      );
    }

    return Conversation.fromJson(data);
  }

  /// 获取会话信息
  ///
  /// [conversationId] 会话 ID
  ///
  /// 返回会话详情
  Future<Conversation> retrieve(String conversationId) async {
    final response = await _client.get(
      '/v1/conversation/retrieve',
      queryParameters: {
        'conversation_id': conversationId,
      },
    );

    final data = response.jsonBody['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw CozeException(
        message: '获取会话信息失败：响应数据为空',
      );
    }

    return Conversation.fromJson(data);
  }

  /// 列出会话列表
  ///
  /// [request] 列出会话请求
  ///
  /// 返回会话列表和分页信息
  Future<ListConversationsResponse> list(ListConversationsRequest request) async {
    final response = await _client.post(
      '/v1/conversations',
      body: request.toJson(),
    );

    return ListConversationsResponse.fromJson(response.jsonBody);
  }

  /// 清空会话消息
  ///
  /// [request] 清空会话消息请求
  ///
  /// 返回清空后的会话信息
  Future<Conversation> clearMessages(ClearConversationMessagesRequest request) async {
    final response = await _client.post(
      '/v1/conversation/clear_messages',
      body: request.toJson(),
    );

    final data = response.jsonBody['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw CozeException(
        message: '清空会话消息失败：响应数据为空',
      );
    }

    return Conversation.fromJson(data);
  }
}
