# 服务端示例

本文档展示如何在 Dart 服务端使用 Coze API Dart SDK。

## 基础服务器

```dart
import 'dart:io';
import 'package:coze_api_dart/coze_api_dart.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

void main() async {
  final client = CozeAPI(
    token: Platform.environment['COZE_TOKEN']!,
    baseURL: CozeURLs.comBaseURL,
  );

  final app = Router();

  // 健康检查
  app.get('/health', (Request request) {
    return Response.ok('OK');
  });

  // 聊天接口
  app.post('/chat', (Request request) async {
    final body = await request.readAsString();
    final data = jsonDecode(body);

    try {
      final result = await client.chat.createAndPoll(
        CreateChatRequest(
          botId: data['bot_id'],
          additionalMessages: [
            Message.user(content: data['message']),
          ],
        ),
      );

      return Response.ok(
        jsonEncode({'response': result.messages.last.content}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
      );
    }
  });

  // 流式聊天接口
  app.get('/chat/stream', (Request request) {
    final message = request.url.queryParameters['message'];

    final stream = client.chat.stream(
      CreateChatRequest(
        botId: 'your_bot_id',
        additionalMessages: [Message.user(content: message!)],
      ),
    );

    return Response.ok(
      stream.map((event) {
        if (event.event == ChatEventType.conversationMessageDelta) {
          return event.data['content'];
        }
        return '';
      }),
    );
  });

  final server = await io.serve(app, 'localhost', 8080);
  print('服务器运行在 http://localhost:8080');
}
```

---

## CLI 工具

```dart
import 'dart:io';
import 'package:coze_api_dart/coze_api_dart.dart';

void main(List<String> args) async {
  if (args.isEmpty) {
    print('用法: dart cli.dart <消息>');
    return;
  }

  final client = CozeAPI(
    token: Platform.environment['COZE_TOKEN']!,
    baseURL: CozeURLs.comBaseURL,
  );

  final message = args.join(' ');

  final stream = client.chat.stream(
    CreateChatRequest(
      botId: 'your_bot_id',
      additionalMessages: [Message.user(content: message)],
    ),
  );

  await for (final event in stream) {
    if (event.event == ChatEventType.conversationMessageDelta) {
      stdout.write(event.data['content']);
    }
  }

  print('');
}
```

---

## 相关链接

- [完整示例合集](complete-examples.md) - 更多示例
- [Flutter 示例](flutter-example.md) - Flutter 应用
