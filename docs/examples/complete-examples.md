# 完整示例合集

本文档汇总各种使用场景的完整代码示例。

## 目录

- [基础对话](#基础对话)
- [流式对话](#流式对话)
- [多轮对话](#多轮对话)
- [文件上传](#文件上传)
- [工作流执行](#工作流执行)
- [Bot 管理](#bot-管理)

---

## 基础对话

```dart
import 'package:coze_api_dart/coze_api_dart.dart';

void main() async {
  final client = CozeAPI(
    token: 'your_pat_token',
    baseURL: CozeURLs.comBaseURL,
  );

  final result = await client.chat.createAndPoll(
    CreateChatRequest(
      botId: 'your_bot_id',
      additionalMessages: [
        Message.user(content: '你好！'),
      ],
    ),
  );

  print(result.messages.last.content);
}
```

---

## 流式对话

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
        Message.user(content: '讲一个故事'),
      ],
    ),
  );

  await for (final event in stream) {
    if (event.event == ChatEventType.conversationMessageDelta) {
      stdout.write(event.data['content']);
    }
  }
}
```

---

## 多轮对话

```dart
import 'package:coze_api_dart/coze_api_dart.dart';

class ChatSession {
  final CozeAPI client;
  final String botId;
  final List<Message> history = [];

  ChatSession(this.client, this.botId);

  Future<String> send(String message) async {
    history.add(Message.user(content: message));

    final result = await client.chat.createAndPoll(
      CreateChatRequest(
        botId: botId,
        additionalMessages: history,
      ),
    );

    final reply = result.messages.last;
    history.add(reply);

    return reply.content;
  }
}

void main() async {
  final client = CozeAPI(
    token: 'your_pat_token',
    baseURL: CozeURLs.comBaseURL,
  );

  final session = ChatSession(client, 'your_bot_id');

  print(await session.send('你好'));
  print(await session.send('刚才我说了什么？'));
}
```

---

## 文件上传

```dart
import 'dart:io';
import 'package:coze_api_dart/coze_api_dart.dart';

void main() async {
  final client = CozeAPI(
    token: 'your_pat_token',
    baseURL: CozeURLs.comBaseURL,
  );

  final file = File('image.jpg');
  final uploaded = await client.files.upload(
    UploadFileRequest(file: file),
  );

  final result = await client.chat.createAndPoll(
    CreateChatRequest(
      botId: 'your_bot_id',
      additionalMessages: [
        Message.user(
          content: '描述图片',
          contentType: ContentType.objectString,
          objectContent: [
            ObjectStringItem.image(fileId: uploaded.id),
          ],
        ),
      ],
    ),
  );

  print(result.messages.last.content);
}
```

---

## 工作流执行

```dart
import 'package:coze_api_dart/coze_api_dart.dart';

void main() async {
  final client = CozeAPI(
    token: 'your_pat_token',
    baseURL: CozeURLs.comBaseURL,
  );

  final result = await client.workflows.run(
    WorkflowRunRequest(
      workflowId: 'your_workflow_id',
      parameters: {'input': '测试'},
    ),
  );

  print('状态: ${result.status}');
  print('数据: ${result.data}');
}
```

---

## Bot 管理

```dart
import 'package:coze_api_dart/coze_api_dart.dart';

void main() async {
  final client = CozeAPI(
    token: 'your_pat_token',
    baseURL: CozeURLs.comBaseURL,
  );

  // 创建 Bot
  final created = await client.bots.create(
    CreateBotRequest(
      spaceId: 'your_space_id',
      name: '测试 Bot',
      prompt: '你是一个 helpful assistant',
    ),
  );

  print('创建成功: ${created.botId}');

  // 发布 Bot
  await client.bots.publish(
    PublishBotRequest(
      botId: created.botId,
      connectorIds: ['1024'],
    ),
  );

  print('发布成功');
}
```

---

## 相关链接

- [Flutter 示例](flutter-example.md) - Flutter 应用示例
- [服务端示例](server-example.md) - Dart 服务端示例
