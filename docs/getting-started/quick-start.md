# 快速开始

5 分钟快速上手 Coze API Dart SDK，完成你的第一个对话。

## 前提条件

- 已完成 [安装指南](installation.md)
- 拥有 Coze 账号和 PAT 令牌
- 已创建 Bot 并获取 Bot ID

## 获取 PAT 令牌

1. 访问 [Coze 开发者平台](https://www.coze.com/open/oauth/pats)
2. 点击 "Create a new PAT token"
3. 复制生成的令牌（格式以 `pat_` 开头）

## 获取 Bot ID

1. 进入你的 Bot 开发页面
2. 从 URL 中复制 Bot ID，例如：
   - URL: `https://www.coze.com/space/xxx/bot/123456789`
   - Bot ID: `123456789`

## 第一个对话

### 1. 创建 Dart 文件

创建 `first_chat.dart`：

```dart
import 'dart:io';
import 'package:coze_api_dart/coze_api_dart.dart';

void main() async {
  // 初始化客户端
  final client = CozeAPI(
    token: 'your_pat_token',  // 替换为你的 PAT 令牌
    baseURL: CozeURLs.comBaseURL,  // 国际版
    // baseURL: CozeURLs.cnBaseURL,  // 中国版
  );

  try {
    // 发起对话
    final result = await client.chat.createAndPoll(
      CreateChatRequest(
        botId: 'your_bot_id',  // 替换为你的 Bot ID
        additionalMessages: [
          Message.user(content: '你好！请介绍一下自己。'),
        ],
      ),
    );

    // 打印回复
    print('Bot 回复：');
    print(result.messages.last.content);
  } catch (e) {
    print('发生错误：$e');
  }
}
```

### 2. 运行代码

```bash
dart first_chat.dart
```

## 流式对话

实现打字机效果的流式输出：

```dart
import 'dart:io';
import 'package:coze_api_dart/coze_api_dart.dart';

void main() async {
  final client = CozeAPI(
    token: 'your_pat_token',
    baseURL: CozeURLs.comBaseURL,
  );

  // 创建流式对话
  final stream = client.chat.stream(
    CreateChatRequest(
      botId: 'your_bot_id',
      additionalMessages: [
        Message.user(content: '讲一个短故事'),
      ],
    ),
  );

  // 监听流式响应
  await for (final event in stream) {
    switch (event.event) {
      case ChatEventType.conversationMessageDelta:
        // 增量内容
        stdout.write(event.data['content']);
        break;
      case ChatEventType.conversationMessageCompleted:
        // 消息完成
        print('\n\n消息完成');
        break;
      case ChatEventType.error:
        // 错误
        print('\n错误：${event.data}');
        break;
      default:
        break;
    }
  }
}
```

## 多轮对话

保持对话上下文：

```dart
import 'package:coze_api_dart/coze_api_dart.dart';

void main() async {
  final client = CozeAPI(
    token: 'your_pat_token',
    baseURL: CozeURLs.comBaseURL,
  );

  // 保存对话历史
  final history = <Message>[];

  // 第一轮对话
  var result = await client.chat.createAndPoll(
    CreateChatRequest(
      botId: 'your_bot_id',
      additionalMessages: [
        Message.user(content: '我叫张三'),
      ],
    ),
  );
  
  history.addAll(result.messages);
  print('Bot: ${result.messages.last.content}');

  // 第二轮对话（携带历史）
  result = await client.chat.createAndPoll(
    CreateChatRequest(
      botId: 'your_bot_id',
      additionalMessages: [
        ...history,
        Message.user(content: '我叫什么名字？'),
      ],
    ),
  );
  
  print('Bot: ${result.messages.last.content}');
}
```

## 下一步

- [配置说明](configuration.md) - 了解高级配置
- [Chat 对话指南](../guides/chat.md) - 深入学习对话功能
- [认证方式](../guides/authentication.md) - 了解其他认证方式
