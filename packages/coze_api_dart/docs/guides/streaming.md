# 流式响应指南

本文档详细介绍如何使用 Coze API Dart SDK 处理流式响应（Server-Sent Events）。

## 目录

- [概述](#概述)
- [基础流式对话](#基础流式对话)
- [事件类型详解](#事件类型详解)
- [处理流式事件](#处理流式事件)
- [取消流式请求](#取消流式请求)
- [最佳实践](#最佳实践)

---

## 概述

流式响应（Streaming）允许你实时接收 AI 生成的内容，而不是等待完整响应。这提供了更好的用户体验，特别是生成长文本时。

### 特点

- ✅ **实时性**: 内容逐字/逐句返回
- ✅ **低延迟**: 用户无需等待完整响应
- ✅ **更好的 UX**: 类似打字机效果
- ✅ **可取消**: 随时可以中断请求

---

## 基础流式对话

### 最简单的流式对话

```dart
import 'dart:io';
import 'package:coze_api_dart/coze_api_dart.dart';

void main() async {
  final client = CozeAPI(
    token: 'your_pat_token',
    baseURL: CozeURLs.comBaseURL,
  );

  // 创建流式请求
  final stream = client.chat.stream(
    CreateChatRequest(
      botId: 'your_bot_id',
      additionalMessages: [
        Message.user(content: '讲一个科幻故事'),
      ],
    ),
  );

  // 监听流式响应
  await for (final event in stream) {
    if (event.event == ChatEventType.conversationMessageDelta) {
      // 输出增量内容
      stdout.write(event.data['content']);
    }
  }
}
```

### 完整的流式处理

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
        Message.user(content: '你好！'),
      ],
    ),
  );

  String fullResponse = '';

  await for (final event in stream) {
    switch (event.event) {
      case ChatEventType.conversationChatCreated:
        print('🚀 对话已创建');
        break;

      case ChatEventType.conversationMessageCreated:
        print('🤖 开始生成回复...');
        break;

      case ChatEventType.conversationMessageDelta:
        final content = event.data['content'] as String? ?? '';
        fullResponse += content;
        stdout.write(content);  // 实时输出
        break;

      case ChatEventType.conversationMessageCompleted:
        print('\n✅ 消息生成完成');
        break;

      case ChatEventType.conversationChatCompleted:
        print('🏁 对话完成');
        print('完整回复: $fullResponse');
        break;

      case ChatEventType.error:
        print('\n❌ 错误: ${event.data}');
        break;

      case ChatEventType.done:
        print('📴 流已结束');
        break;
    }
  }
}
```

---

## 事件类型详解

### ChatEventType 枚举

| 事件类型 | 说明 | 触发时机 |
|---------|------|---------|
| `conversationChatCreated` | 对话创建 | 对话开始时 |
| `conversationMessageCreated` | 消息创建 | 开始生成消息时 |
| `conversationMessageDelta` | 消息增量 | 有新内容生成时 |
| `conversationMessageCompleted` | 消息完成 | 单条消息生成完毕 |
| `conversationChatCompleted` | 对话完成 | 整个对话结束时 |
| `conversationChatRequiresAction` | 需要操作 | 需要工具调用时 |
| `error` | 错误 | 发生错误时 |
| `done` | 完成 | 流正常结束时 |

### 事件数据结构

```dart
// conversationChatCreated
event.data = {
  'id': 'conversation_id',
  'bot_id': 'bot_id',
  'created_at': 1234567890,
};

// conversationMessageDelta
event.data = {
  'id': 'message_id',
  'role': 'assistant',
  'content': '增量文本',
  'content_type': 'text',
};

// conversationMessageCompleted
event.data = {
  'id': 'message_id',
  'role': 'assistant',
  'content': '完整内容',
  'type': 'answer',
};

// error
event.data = {
  'error': '错误信息',
  'code': 'error_code',
};
```

---

## 处理流式事件

### 打字机效果

```dart
class TypewriterEffect {
  final Stream<ChatEvent> stream;

  TypewriterEffect(this.stream);

  Stream<String> get textStream async* {
    await for (final event in stream) {
      if (event.event == ChatEventType.conversationMessageDelta) {
        yield event.data['content'] ?? '';
      }
    }
  }

  Future<String> getFullText() async {
    final buffer = StringBuffer();
    await for (final text in textStream) {
      buffer.write(text);
    }
    return buffer.toString();
  }
}
```

### 带缓冲的流式处理

```dart
class BufferedStreamHandler {
  final List<String> _buffer = [];
  static const int bufferSize = 10;

  Stream<List<String>> getBufferedStream(Stream<ChatEvent> stream) async* {
    await for (final event in stream) {
      if (event.event == ChatEventType.conversationMessageDelta) {
        _buffer.add(event.data['content'] ?? '');

        if (_buffer.length >= bufferSize) {
          yield List.from(_buffer);
          _buffer.clear();
        }
      }
    }

    // 输出剩余内容
    if (_buffer.isNotEmpty) {
      yield List.from(_buffer);
    }
  }
}
```

---

## 取消流式请求

### 使用 CancellationToken

```dart
import 'package:coze_api_dart/coze_api_dart.dart';

void main() async {
  final client = CozeAPI(
    token: 'your_pat_token',
    baseURL: CozeURLs.comBaseURL,
  );

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

### 用户主动取消

```dart
class CancellableChat {
  CancellationToken? _token;

  Future<void> startChat(String message) async {
    _token = CancellationToken();

    final client = CozeAPI(/* ... */);

    try {
      final stream = client.chat.stream(
        CreateChatRequest(
          botId: 'your_bot_id',
          additionalMessages: [Message.user(content: message)],
        ),
        cancellationToken: _token,
      );

      await for (final event in stream) {
        // 处理事件
      }
    } on CancelledException {
      print('对话已取消');
    }
  }

  void cancel() {
    _token?.cancel();
  }
}
```

---

## 最佳实践

### 1. 错误处理

```dart
Future<void> safeStreaming() async {
  try {
    final stream = client.chat.stream(...);

    await for (final event in stream) {
      // 处理事件
    }
  } on CozeException catch (e) {
    print('Coze 错误: ${e.message}');
  } on TimeoutException catch (e) {
    print('请求超时');
  } on CancelledException catch (e) {
    print('请求已取消');
  } catch (e) {
    print('未知错误: $e');
  }
}
```

### 2. 连接断开重连

```dart
Future<void> streamingWithRetry() async {
  int retries = 0;
  const maxRetries = 3;

  while (retries < maxRetries) {
    try {
      final stream = client.chat.stream(...);
      await for (final event in stream) {
        // 处理事件
      }
      break;  // 成功，退出循环
    } on SocketException catch (e) {
      retries++;
      if (retries >= maxRetries) rethrow;

      print('连接断开，$retries 秒后重试...');
      await Future.delayed(Duration(seconds: retries));
    }
  }
}
```

### 3. Flutter 集成

```dart
class ChatController extends ChangeNotifier {
  final CozeAPI client;
  String _currentResponse = '';
  bool _isStreaming = false;

  String get currentResponse => _currentResponse;
  bool get isStreaming => _isStreaming;

  Future<void> sendMessage(String message) async {
    _isStreaming = true;
    _currentResponse = '';
    notifyListeners();

    final stream = client.chat.stream(
      CreateChatRequest(
        botId: 'your_bot_id',
        additionalMessages: [Message.user(content: message)],
      ),
    );

    await for (final event in stream) {
      if (event.event == ChatEventType.conversationMessageDelta) {
        _currentResponse += event.data['content'] ?? '';
        notifyListeners();
      }
    }

    _isStreaming = false;
    notifyListeners();
  }
}
```

---

## 下一步

- [Chat 对话指南](chat.md) - 了解更多对话功能
- [请求取消](../advanced/cancellation.md) - 深入了解取消机制
