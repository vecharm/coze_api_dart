
/// Chat API 使用示例
///
/// 展示如何使用 Coze Dart SDK 进行对话
library;

import 'dart:io';

import 'package:coze_api_dart/coze_api_dart.dart';

/// 简单对话示例
Future<void> simpleChatExample() async {
  // 初始化客户端
  final client = CozeAPI(
    token: 'your_pat_token', // 替换为你的 PAT
    baseURL: CozeURLs.comBaseURL, // 或 CozeURLs.cnBaseURL
    config: const CozeConfig(
      baseURL: CozeURLs.comBaseURL,
      debug: true, // 启用调试日志
    ),
  );

  try {
    // 发起简单对话
    final result = await client.chat.createAndPoll(
      CreateChatRequest(
        botId: 'your_bot_id', // 替换为你的 Bot ID
        additionalMessages: [
          Message.user(content: '你好！请介绍一下自己。'),
        ],
        autoSaveHistory: true,
      ),
    );

    // 打印对话结果
    print('对话状态: ${result.chat.status.name}');
    print('Token 使用: ${result.chat.usage?.tokenCount ?? 0}');
    
    // 打印所有消息
    for (final message in result.messages) {
      print('[${message.role.name}]: ${message.content}');
    }

    // 获取助手的回复
    final assistantMessages = result.messages
        .where((m) => m.role == RoleType.assistant)
        .toList();
    
    if (assistantMessages.isNotEmpty) {
      print('\n助手回复: ${assistantMessages.last.content}');
    }
  } catch (e) {
    print('错误: $e');
  } finally {
    client.close();
  }
}

/// 流式对话示例
Future<void> streamChatExample() async {
  final client = CozeAPI(
    token: 'your_pat_token',
    baseURL: CozeURLs.comBaseURL,
  );

  try {
    // 发起流式对话
    final stream = client.chat.stream(
      CreateChatRequest(
        botId: 'your_bot_id',
        additionalMessages: [
          Message.user(content: '讲一个有趣的科幻故事。'),
        ],
      ),
    );

    // 监听流式响应
    await for (final event in stream) {
      switch (event.event) {
        case ChatEventType.conversationMessageDelta:
          // 实时打印消息增量
          if (event.data.containsKey('content')) {
            stdout.write(event.data['content']);
          }
          break;
        case ChatEventType.conversationMessageCompleted:
          print('\n\n消息完成');
          break;
        case ChatEventType.conversationChatCompleted:
          print('\n对话完成');
          break;
        case ChatEventType.error:
          print('\n错误: ${event.data}');
          break;
        case ChatEventType.done:
          print('\n流结束');
          break;
        default:
          print('事件: ${event.event.name}');
      }
    }
  } catch (e) {
    print('错误: $e');
  } finally {
    client.close();
  }
}

/// 多轮对话示例
Future<void> multiTurnChatExample() async {
  final client = CozeAPI(
    token: 'your_pat_token',
    baseURL: CozeURLs.comBaseURL,
  );

  // 维护对话历史
  final history = <Message>[];

  try {
    // 第一轮对话
    var result = await client.chat.createAndPoll(
      CreateChatRequest(
        botId: 'your_bot_id',
        additionalMessages: [
          Message.user(content: '你好！我叫张三。'),
        ],
      ),
    );

    // 保存历史
    history.addAll(result.messages);
    print('助手: ${result.messages.lastWhere((m) => m.role == RoleType.assistant).content}');

    // 第二轮对话（包含历史）
    result = await client.chat.createAndPoll(
      CreateChatRequest(
        botId: 'your_bot_id',
        additionalMessages: [
          ...history,
          Message.user(content: '我叫什么名字？'),
        ],
      ),
    );

    print('助手: ${result.messages.lastWhere((m) => m.role == RoleType.assistant).content}');
  } catch (e) {
    print('错误: $e');
  } finally {
    client.close();
  }
}

/// 带文件上传的对话示例
Future<void> chatWithFileExample() async {
  final client = CozeAPI(
    token: 'your_pat_token',
    baseURL: CozeURLs.comBaseURL,
  );

  try {
    // 创建带文件的消息
    final result = await client.chat.createAndPoll(
      CreateChatRequest(
        botId: 'your_bot_id',
        additionalMessages: [
          Message(
            role: RoleType.user,
            content: '请分析这张图片',
            contentType: ContentType.objectString,
            fileInfos: [
              FileInfo(
                id: 'file_id', // 文件 ID
                name: 'image.png',
                url: 'https://example.com/image.png',
              ),
            ],
          ),
        ],
      ),
    );

    print('助手回复: ${result.messages.last.content}');
  } catch (e) {
    print('错误: $e');
  } finally {
    client.close();
  }
}

/// 工具调用示例
Future<void> toolCallExample() async {
  final client = CozeAPI(
    token: 'your_pat_token',
    baseURL: CozeURLs.comBaseURL,
  );

  try {
    // 创建对话
    var chat = await client.chat.create(
      CreateChatRequest(
        botId: 'your_bot_id',
        additionalMessages: [
          Message.user(content: '查询北京的天气'),
        ],
      ),
    );

    // 轮询直到需要操作或完成
    while (chat.status == ChatStatus.created ||
        chat.status == ChatStatus.inProgress) {
      await Future.delayed(const Duration(milliseconds: 500));
      chat = await client.chat.retrieve(chat.id, chat.conversationId);

      // 如果需要提交工具输出
      if (chat.status == ChatStatus.requiresAction) {
        final toolCalls = chat.requiredAction?.submitToolOutputs?.toolCalls;
        
        if (toolCalls != null) {
          final toolOutputs = <ToolOutput>[];

          for (final toolCall in toolCalls) {
            // 执行工具调用
            final result = await executeToolCall(toolCall);
            
            toolOutputs.add(ToolOutput(
              toolCallId: toolCall.id,
              output: result,
            ));
          }

          // 提交工具输出
          chat = await client.chat.submitToolOutputs(
            chat.id,
            chat.conversationId,
            SubmitToolOutputsRequest(toolOutputs: toolOutputs),
          );
        }
      }
    }

    // 获取最终结果
    final messages = await client.chat.getMessages(
      chat.conversationId,
      chat.id,
    );

    print('助手回复: ${messages.last.content}');
  } catch (e) {
    print('错误: $e');
  } finally {
    client.close();
  }
}

/// 执行工具调用（示例）
Future<String> executeToolCall(ToolCall toolCall) async {
  // 这里应该根据 toolCall.function.name 执行相应的操作
  // 示例：查询天气
  if (toolCall.function.name == 'get_weather') {
    final args = toolCall.function.parsedArguments;
    final city = args['city'] as String?;
    return '{"temperature": 25, "condition": "晴朗", "city": "$city"}';
  }
  
  return '{}';
}

/// 主函数
void main() async {
  // 初始化日志
  Logger.initialize(level: LogLevel.debug);

  print('=== 简单对话示例 ===');
  await simpleChatExample();

  print('\n=== 流式对话示例 ===');
  await streamChatExample();

  print('\n=== 多轮对话示例 ===');
  await multiTurnChatExample();
}
