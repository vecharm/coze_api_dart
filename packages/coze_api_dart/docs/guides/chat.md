# Chat 对话指南

本文档详细介绍如何使用 Coze API Dart SDK 进行对话，包括普通对话、流式对话、多轮对话、工具调用等高级功能。

## 目录

- [基础对话](#基础对话)
- [流式对话](#流式对话)
- [多轮对话](#多轮对话)
- [工具调用](#工具调用)
- [图片和文件](#图片和文件)
- [高级功能](#高级功能)
- [最佳实践](#最佳实践)

---

## 基础对话

### 最简单的对话

使用 `createAndPoll` 方法发起对话并等待完整响应：

```dart
import 'package:coze_api_dart/coze_api_dart.dart';

void main() async {
  final client = CozeAPI(
    token: 'your_pat_token',
    baseURL: CozeURLs.comBaseURL,
  );

  try {
    final result = await client.chat.createAndPoll(
      CreateChatRequest(
        botId: 'your_bot_id',
        additionalMessages: [
          Message.user(content: '你好！'),
        ],
      ),
    );

    // 获取最后一条消息（Bot 的回复）
    final reply = result.messages.last;
    print('Bot: ${reply.content}');
  } catch (e) {
    print('错误: $e');
  }
}
```

### 理解响应结构

```dart
final result = await client.chat.createAndPoll(...);

// 对话信息
print('对话 ID: ${result.conversationId}');
print('消息 ID: ${result.id}');
print('状态: ${result.status}');

// 消息列表
for (final message in result.messages) {
  print('角色: ${message.role}');
  print('内容: ${message.content}');
  print('类型: ${message.type}');
}
```

### 设置对话参数

```dart
final result = await client.chat.createAndPoll(
  CreateChatRequest(
    botId: 'your_bot_id',
    conversationId: 'existing_conversation_id',  // 可选：继续已有对话
    userId: 'user_123',  // 可选：用户标识
    additionalMessages: [
      Message.user(content: '你好！'),
    ],
    customVariables: {
      'name': '张三',
      'age': '25',
    },
    autoSaveHistory: true,  // 自动保存对话历史
  ),
);
```

---

## 流式对话

流式对话可以实现打字机效果，提升用户体验。

### 基本流式对话

```dart
import 'dart:io';
import 'package:coze_api_dart/coze_api_dart.dart';

void main() async {
  final client = CozeAPI(
    token: 'your_pat_token',
    baseURL: CozeURLs.comBaseURL,
  );

  final stream = client.chat.stream(
    CreateChatRequest(
      botId: 'your_bot_id',
      additionalMessages: [
        Message.user(content: '讲一个科幻故事'),
      ],
    ),
  );

  await for (final event in stream) {
    switch (event.event) {
      case ChatEventType.conversationMessageDelta:
        // 增量内容 - 逐字输出
        stdout.write(event.data['content']);
        break;
        
      case ChatEventType.conversationMessageCompleted:
        // 单条消息完成
        print('\n--- 消息完成 ---');
        break;
        
      case ChatEventType.conversationChatCompleted:
        // 整个对话完成
        print('\n=== 对话完成 ===');
        break;
        
      case ChatEventType.error:
        // 错误
        print('\n错误: ${event.data}');
        break;
        
      default:
        break;
    }
  }
}
```

### 流式事件类型详解

```dart
await for (final event in stream) {
  switch (event.event) {
    // 对话创建成功
    case ChatEventType.conversationChatCreated:
      print('对话已创建: ${event.data['id']}');
      break;
      
    // 消息开始生成
    case ChatEventType.conversationMessageCreated:
      print('开始生成消息');
      break;
      
    // 消息内容增量更新
    case ChatEventType.conversationMessageDelta:
      final content = event.data['content'] as String? ?? '';
      final role = event.data['role'] as String?;
      
      if (role == 'assistant') {
        stdout.write(content);  // 逐字输出
      }
      break;
      
    // 消息生成完成
    case ChatEventType.conversationMessageCompleted:
      final message = Message.fromJson(event.data);
      print('\n完整消息: ${message.content}');
      break;
      
    // 对话完成
    case ChatEventType.conversationChatCompleted:
      print('对话已完成');
      break;
      
    // 需要用户授权
    case ChatEventType.conversationChatRequiresAction:
      print('需要用户操作: ${event.data}');
      break;
      
    // 错误
    case ChatEventType.error:
      print('发生错误: ${event.data['error']}');
      break;
      
    // 完成标记
    case ChatEventType.done:
      print('流已结束');
      break;
  }
}
```

### 带取消功能的流式对话

```dart
import 'package:coze_api_dart/coze_api_dart.dart';

void main() async {
  final client = CozeAPI(
    token: 'your_pat_token',
    baseURL: CozeURLs.comBaseURL,
  );

  // 创建取消令牌
  final cancellationToken = CancellationToken();

  // 5秒后取消
  Future.delayed(Duration(seconds: 5), () {
    print('取消请求...');
    cancellationToken.cancel();
  });

  try {
    final stream = client.chat.stream(
      CreateChatRequest(
        botId: 'your_bot_id',
        additionalMessages: [
          Message.user(content: '写一篇长文章...'),
        ],
      ),
      cancellationToken: cancellationToken,
    );

    await for (final event in stream) {
      if (event.event == ChatEventType.conversationMessageDelta) {
        stdout.write(event.data['content']);
      }
    }
  } on CancelledException {
    print('\n请求已取消');
  }
}
```

---

## 多轮对话

### 保持对话上下文

```dart
import 'package:coze_api_dart/coze_api_dart.dart';

class ChatSession {
  final CozeAPI client;
  final String botId;
  String? conversationId;
  final List<Message> history = [];

  ChatSession({
    required this.client,
    required this.botId,
  });

  Future<String> sendMessage(String content) async {
    // 添加用户消息到历史
    history.add(Message.user(content: content));

    // 发起对话
    final result = await client.chat.createAndPoll(
      CreateChatRequest(
        botId: botId,
        conversationId: conversationId,  // 使用已有对话 ID
        additionalMessages: history,
      ),
    );

    // 保存对话 ID
    conversationId = result.conversationId;

    // 获取 Bot 回复
    final reply = result.messages.lastWhere(
      (m) => m.role == RoleType.assistant,
    );

    // 添加回复到历史
    history.add(reply);

    return reply.content;
  }
}

void main() async {
  final client = CozeAPI(
    token: 'your_pat_token',
    baseURL: CozeURLs.comBaseURL,
  );

  final session = ChatSession(
    client: client,
    botId: 'your_bot_id',
  );

  // 多轮对话
  print('User: 你好，我叫张三');
  print('Bot: ${await session.sendMessage('你好，我叫张三')}');

  print('\nUser: 我叫什么名字？');
  print('Bot: ${await session.sendMessage('我叫什么名字？')}');

  print('\nUser: 给我讲个笑话');
  print('Bot: ${await session.sendMessage('给我讲个笑话')}');
}
```

### 使用 Conversation API 管理对话

```dart
import 'package:coze_api_dart/coze_api_dart.dart';

void main() async {
  final client = CozeAPI(
    token: 'your_pat_token',
    baseURL: CozeURLs.comBaseURL,
  );

  // 1. 创建新对话
  final conversation = await client.conversations.create(
    CreateConversationRequest(
      botId: 'your_bot_id',
      messages: [
        Message.system(content: '你是一个 helpful assistant'),
      ],
    ),
  );

  print('创建对话: ${conversation.id}');

  // 2. 在对话中发送消息
  final result = await client.chat.createAndPoll(
    CreateChatRequest(
      botId: 'your_bot_id',
      conversationId: conversation.id,
      additionalMessages: [
        Message.user(content: '你好！'),
      ],
    ),
  );

  print('Bot: ${result.messages.last.content}');

  // 3. 查看对话历史
  final messages = await client.conversations.messages.list(
    conversation.id,
  );

  print('\n对话历史:');
  for (final msg in messages.data) {
    print('${msg['role']}: ${msg['content']}');
  }

  // 4. 删除对话
  await client.conversations.delete(conversation.id);
}
```

---

## 工具调用

当 Bot 配置了插件或工作流时，可以通过工具调用扩展功能。

### 自动模式（推荐）

SDK 会自动处理工具调用：

```dart
import 'package:coze_api_dart/coze_api_dart.dart';

void main() async {
  final client = CozeAPI(
    token: 'your_pat_token',
    baseURL: CozeURLs.comBaseURL,
  );

  // 如果 Bot 配置了天气插件，会自动调用
  final result = await client.chat.createAndPoll(
    CreateChatRequest(
      botId: 'your_bot_id',  // 配置了天气插件的 Bot
      additionalMessages: [
        Message.user(content: '北京今天天气怎么样？'),
      ],
    ),
  );

  print(result.messages.last.content);
}
```

### 手动处理工具调用

如果需要自定义工具调用逻辑：

```dart
import 'package:coze_api_dart/coze_api_dart.dart';

void main() async {
  final client = CozeAPI(
    token: 'your_pat_token',
    baseURL: CozeURLs.comBaseURL,
  );

  // 第一步：发起对话
  final stream = client.chat.stream(
    CreateChatRequest(
      botId: 'your_bot_id',
      additionalMessages: [
        Message.user(content: '查询北京天气'),
      ],
    ),
  );

  List<ToolCall> pendingToolCalls = [];

  await for (final event in stream) {
    switch (event.event) {
      case ChatEventType.conversationMessageDelta:
        stdout.write(event.data['content']);
        break;

      case ChatEventType.conversationChatRequiresAction:
        // Bot 需要调用工具
        final toolCalls = (event.data['tool_calls'] as List)
            .map((t) => ToolCall.fromJson(t))
            .toList();

        pendingToolCalls = toolCalls;

        for (final toolCall in toolCalls) {
          print('\n需要调用工具: ${toolCall.function.name}');
          print('参数: ${toolCall.function.arguments}');
        }
        break;

      case ChatEventType.conversationChatCompleted:
        // 处理工具调用
        if (pendingToolCalls.isNotEmpty) {
          final toolOutputs = <ToolOutput>[];

          for (final toolCall in pendingToolCalls) {
            // 执行工具调用
            final result = await executeTool(toolCall);

            toolOutputs.add(ToolOutput(
              toolCallId: toolCall.id,
              output: result,
            ));
          }

          // 提交工具调用结果
          final finalResult = await client.chat.submitToolOutputs(
            conversationId: event.data['conversation_id'],
            chatId: event.data['id'],
            toolOutputs: toolOutputs,
          );

          print('\n最终结果: ${finalResult.messages.last.content}');
        }
        break;
    }
  }
}

// 执行工具调用
Future<String> executeTool(ToolCall toolCall) async {
  switch (toolCall.function.name) {
    case 'get_weather':
      final args = jsonDecode(toolCall.function.arguments);
      final city = args['city'];
      // 调用天气 API
      return await fetchWeather(city);

    case 'search_web':
      final args = jsonDecode(toolCall.function.arguments);
      final query = args['query'];
      // 执行搜索
      return await searchWeb(query);

    default:
      return '未知工具';
  }
}
```

---

## 图片和文件

### 发送图片

```dart
import 'package:coze_api_dart/coze_api_dart.dart';

void main() async {
  final client = CozeAPI(
    token: 'your_pat_token',
    baseURL: CozeURLs.comBaseURL,
  );

  // 方式1：使用图片 URL
  final result = await client.chat.createAndPoll(
    CreateChatRequest(
      botId: 'your_bot_id',
      additionalMessages: [
        Message.user(
          content: '描述这张图片',
          contentType: ContentType.objectString,
          objectContent: [
            ObjectStringItem.image(
              fileUrl: 'https://example.com/image.jpg',
            ),
          ],
        ),
      ],
    ),
  );

  print(result.messages.last.content);
}
```

### 上传并发送本地图片

```dart
import 'dart:io';
import 'package:coze_api_dart/coze_api_dart.dart';

void main() async {
  final client = CozeAPI(
    token: 'your_pat_token',
    baseURL: CozeURLs.comBaseURL,
  );

  // 1. 上传图片文件
  final file = File('path/to/image.jpg');
  final uploadedFile = await client.files.upload(
    UploadFileRequest(
      file: file,
    ),
  );

  print('文件上传成功: ${uploadedFile.id}');

  // 2. 发送包含图片的消息
  final result = await client.chat.createAndPoll(
    CreateChatRequest(
      botId: 'your_bot_id',
      additionalMessages: [
        Message.user(
          content: '分析这张图片',
          contentType: ContentType.objectString,
          objectContent: [
            ObjectStringItem.image(
              fileId: uploadedFile.id,
            ),
          ],
        ),
      ],
    ),
  );

  print(result.messages.last.content);
}
```

### 图文混排

```dart
final result = await client.chat.createAndPoll(
  CreateChatRequest(
    botId: 'your_bot_id',
    additionalMessages: [
      Message.user(
        contentType: ContentType.objectString,
        objectContent: [
          ObjectStringItem.text(text: '请分析以下图片：\n\n'),
          ObjectStringItem.image(fileUrl: 'https://example.com/image1.jpg'),
          ObjectStringItem.text(text: '\n和这张图片的区别：\n\n'),
          ObjectStringItem.image(fileUrl: 'https://example.com/image2.jpg'),
        ],
      ),
    ],
  ),
);
```

---

## 高级功能

### 自定义变量

```dart
final result = await client.chat.createAndPoll(
  CreateChatRequest(
    botId: 'your_bot_id',
    additionalMessages: [
      Message.user(content: '你好！'),
    ],
    customVariables: {
      'user_name': '张三',
      'user_level': 'VIP',
      'preferred_language': 'zh-CN',
    },
  ),
);
```

### 元数据

```dart
final result = await client.chat.createAndPoll(
  CreateChatRequest(
    botId: 'your_bot_id',
    additionalMessages: [
      Message(
        role: RoleType.user,
        content: '你好',
        metaData: {
          'device': 'iPhone',
          'location': 'Beijing',
          'timestamp': DateTime.now().toIso8601String(),
        },
      ),
    ],
  ),
);
```

### 短语音识别

```dart
import 'dart:io';
import 'package:coze_api_dart/coze_api_dart.dart';

void main() async {
  final client = CozeAPI(
    token: 'your_pat_token',
    baseURL: CozeURLs.comBaseURL,
  );

  // 上传音频文件
  final audioFile = File('path/to/audio.mp3');
  final uploadedFile = await client.files.upload(
    UploadFileRequest(file: audioFile),
  );

  // 使用语音识别
  final result = await client.chat.createAndPoll(
    CreateChatRequest(
      botId: 'your_bot_id',
      additionalMessages: [
        Message(
          role: RoleType.user,
          content: uploadedFile.id,
          contentType: ContentType.audio,
        ),
      ],
    ),
  );

  print('识别结果: ${result.messages.last.content}');
}
```

---

## 最佳实践

### 1. 错误处理

```dart
import 'package:coze_api_dart/coze_api_dart.dart';

Future<void> safeChat() async {
  try {
    final result = await client.chat.createAndPoll(...);
    // 处理结果
  } on CozeException catch (e) {
    // SDK 异常
    print('Coze 错误: ${e.message}');
    print('错误码: ${e.code}');
  } on SocketException catch (e) {
    // 网络错误
    print('网络错误: $e');
  } on TimeoutException catch (e) {
    // 超时
    print('请求超时');
  } catch (e) {
    // 其他错误
    print('未知错误: $e');
  }
}
```

### 2. 重试机制

```dart
import 'package:coze_api_dart/coze_api_dart.dart';

Future<ChatResult> chatWithRetry(CreateChatRequest request) async {
  int attempts = 0;
  const maxAttempts = 3;

  while (attempts < maxAttempts) {
    try {
      return await client.chat.createAndPoll(request);
    } on TimeoutException catch (e) {
      attempts++;
      if (attempts >= maxAttempts) rethrow;

      print('重试 $attempts/$maxAttempts...');
      await Future.delayed(Duration(seconds: attempts));
    }
  }

  throw Exception('Max retries exceeded');
}
```

### 3. 消息历史管理

```dart
class MessageHistory {
  final List<Message> messages = [];
  final int maxHistory;

  MessageHistory({this.maxHistory = 20});

  void add(Message message) {
    messages.add(message);

    // 限制历史长度
    if (messages.length > maxHistory) {
      messages.removeAt(0);
    }
  }

  List<Message> toList() => List.unmodifiable(messages);

  void clear() => messages.clear();
}
```

### 4. 对话状态管理

```dart
enum ChatState {
  idle,
  loading,
  streaming,
  error,
}

class ChatController extends ChangeNotifier {
  final CozeAPI client;
  final String botId;

  ChatState _state = ChatState.idle;
  String? _error;
  String _currentResponse = '';

  ChatState get state => _state;
  String? get error => _error;
  String get currentResponse => _currentResponse;

  Future<void> sendMessage(String content) async {
    _state = ChatState.loading;
    _error = null;
    _currentResponse = '';
    notifyListeners();

    try {
      final stream = client.chat.stream(
        CreateChatRequest(
          botId: botId,
          additionalMessages: [Message.user(content: content)],
        ),
      );

      _state = ChatState.streaming;
      notifyListeners();

      await for (final event in stream) {
        if (event.event == ChatEventType.conversationMessageDelta) {
          _currentResponse += event.data['content'] ?? '';
          notifyListeners();
        }
      }

      _state = ChatState.idle;
      notifyListeners();
    } catch (e) {
      _state = ChatState.error;
      _error = e.toString();
      notifyListeners();
    }
  }
}
```

---

## 常见问题

### Q: 对话历史太长怎么办？

A: 可以只保留最近 N 条消息，或使用 Conversation API 管理对话：

```dart
// 只保留最近 10 条消息
final recentMessages = history.skip(history.length - 10).toList();
```

### Q: 如何获取 Token 消耗？

A: 在响应中查看 usage 信息：

```dart
final result = await client.chat.createAndPoll(...);
print('输入 Token: ${result.usage?.inputCount}');
print('输出 Token: ${result.usage?.outputCount}');
print('总 Token: ${result.usage?.totalTokens}');
```

### Q: 流式对话如何显示 Markdown？

A: 使用 flutter_markdown 等库实时渲染：

```dart
MarkdownBody(
  data: controller.currentResponse,
  selectable: true,
)
```

---

## 下一步

- [流式响应指南](streaming.md) - 深入学习流式处理
- [WebSocket 实时通信](websocket.md) - 实时语音对话
- [错误处理](../advanced/error-handling.md) - 错误处理最佳实践
