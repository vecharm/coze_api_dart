
/// Chat API
///
/// 提供对话相关的所有 API 接口
library;

import 'dart:async';
import 'dart:convert';

import '../../client/http_client.dart';
import '../../models/enums.dart';
import '../../models/errors.dart';
import '../../utils/cancellation_token.dart';
import '../../utils/logger.dart';
import 'chat_models.dart';

/// Chat API 封装
///
/// 提供创建对话、流式对话、获取对话详情等功能
class ChatAPI {
  final HttpClient _client;

  /// 创建 Chat API 实例
  ChatAPI(this._client);

  /// 创建对话并轮询结果（简化版）
  ///
  /// [request] 创建对话请求
  /// [pollInterval] 轮询间隔（毫秒），默认 500ms
  /// [timeout] 超时时间（毫秒），默认 5 分钟
  ///
  /// 返回包含完整对话结果的对象
  Future<ChatResult> createAndPoll(
    CreateChatRequest request, {
    int pollInterval = 500,
    int timeout = 300000,
  }) async {
    // 创建对话
    final chat = await create(request);

    final startTime = DateTime.now();
    Chat currentChat = chat;

    // 轮询直到对话完成或失败
    while (currentChat.status == ChatStatus.created ||
        currentChat.status == ChatStatus.inProgress) {
      // 检查超时
      if (DateTime.now().difference(startTime).inMilliseconds > timeout) {
        throw TimeoutException(
          message: '对话轮询超时',
          timeoutMs: timeout,
        );
      }

      // 等待
      await Future.delayed(Duration(milliseconds: pollInterval));

      // 获取最新状态
      currentChat = await retrieve(
        currentChat.conversationId,
        currentChat.id,
      );

      logD('Chat status: ${currentChat.status.name}');
    }

    // 获取消息列表
    final messages = await _getMessages(
      currentChat.conversationId,
      currentChat.id,
    );

    return ChatResult(
      chat: currentChat,
      messages: messages,
    );
  }

  /// 创建对话
  ///
  /// [request] 创建对话请求
  ///
  /// 返回创建的对话对象
  Future<Chat> create(CreateChatRequest request) async {
    final response = await _client.post(
      '/v3/chat',
      body: request.toJson(),
    );

    final data = response.jsonBody['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw CozeException(
        message: '创建对话失败：响应数据为空',
      );
    }

    return Chat.fromJson(data);
  }

  /// 获取对话详情
  ///
  /// [conversationId] 会话 ID
  /// [chatId] 对话 ID
  ///
  /// 返回对话详情
  Future<Chat> retrieve(String conversationId, String chatId) async {
    final response = await _client.get(
      '/v3/chat/retrieve',
      queryParameters: {
        'conversation_id': conversationId,
        'chat_id': chatId,
      },
    );

    final data = response.jsonBody['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw CozeException(
        message: '获取对话详情失败：响应数据为空',
      );
    }

    return Chat.fromJson(data);
  }

  /// 流式对话
  ///
  /// [request] 创建对话请求
  /// [cancellationToken] 取消令牌，用于取消流式请求
  ///
  /// 返回事件流，可以监听实时响应
  Stream<ChatEvent> stream(
    CreateChatRequest request, {
    CancellationToken? cancellationToken,
  }) async* {
    // 检查是否已请求取消
    cancellationToken?.throwIfCancellationRequested();

    // 设置流式标志
    final streamRequest = CreateChatRequest(
      botId: request.botId,
      userId: request.userId,
      conversationId: request.conversationId,
      additionalMessages: request.additionalMessages,
      stream: true,
      customVariables: request.customVariables,
      autoSaveHistory: request.autoSaveHistory,
      metaData: request.metaData,
      plugins: request.plugins,
      toolChoice: request.toolChoice,
      tools: request.tools,
      extraParams: request.extraParams,
      spaceId: request.spaceId,
      contentType: request.contentType,
    );

    final stream = _client.stream(
      '/v3/chat',
      body: streamRequest.toJson(),
      cancellationToken: cancellationToken,
    );

    await for (final data in stream) {
      // 检查取消
      cancellationToken?.throwIfCancellationRequested();

      if (data == '[DONE]') {
        yield ChatEvent(
          event: ChatEventType.done,
          data: {},
        );
        return;
      }

      try {
        final json = jsonDecode(data) as Map<String, dynamic>;
        yield ChatEvent.fromJson(json);
      } catch (e) {
        logW('Failed to parse stream event: $data');
        // 继续处理下一个事件，不中断流
      }
    }
  }

  /// 提交工具输出
  ///
  /// [chatId] 对话 ID
  /// [conversationId] 会话 ID
  /// [request] 提交工具输出请求
  ///
  /// 返回更新后的对话对象
  Future<Chat> submitToolOutputs(
    String chatId,
    String conversationId,
    SubmitToolOutputsRequest request,
  ) async {
    final response = await _client.post(
      '/v3/chat/submit_tool_outputs',
      queryParameters: {
        'chat_id': chatId,
        'conversation_id': conversationId,
      },
      body: request.toJson(),
    );

    final data = response.jsonBody['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw CozeException(
        message: '提交工具输出失败：响应数据为空',
      );
    }

    return Chat.fromJson(data);
  }

  /// 取消对话
  ///
  /// [chatId] 对话 ID
  /// [conversationId] 会话 ID
  ///
  /// 返回取消后的对话对象
  Future<Chat> cancel(String chatId, String conversationId) async {
    final response = await _client.post(
      '/v3/chat/cancel',
      queryParameters: {
        'chat_id': chatId,
        'conversation_id': conversationId,
      },
    );

    final data = response.jsonBody['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw CozeException(
        message: '取消对话失败：响应数据为空',
      );
    }

    return Chat.fromJson(data);
  }

  /// 获取消息列表
  ///
  /// [conversationId] 会话 ID
  /// [chatId] 对话 ID
  ///
  /// 返回消息列表
  Future<List<Message>> _getMessages(
    String conversationId,
    String chatId,
  ) async {
    final response = await _client.get(
      '/v3/chat/message/list',
      queryParameters: {
        'conversation_id': conversationId,
        'chat_id': chatId,
      },
    );

    final data = response.jsonBody['data'] as List<dynamic>?;
    if (data == null) {
      return [];
    }

    return data
        .map((e) => Message.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// 获取消息列表（公开接口）
  ///
  /// [conversationId] 会话 ID
  /// [chatId] 对话 ID
  ///
  /// 返回消息列表
  Future<List<Message>> getMessages(
    String conversationId,
    String chatId,
  ) async {
    return _getMessages(conversationId, chatId);
  }
}
