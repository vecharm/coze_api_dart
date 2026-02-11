# Flutter 示例

本文档展示如何在 Flutter 应用中使用 Coze API Dart SDK。

## 完整聊天应用

```dart
import 'package:flutter/material.dart';
import 'package:coze_api_dart/coze_api_dart.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coze Chat',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ChatPage(),
    );
  }
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _client = CozeAPI(
    token: 'your_pat_token',
    baseURL: CozeURLs.comBaseURL,
  );

  final _messages = <Message>[];
  final _controller = TextEditingController();
  bool _isLoading = false;

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(Message.user(content: text));
      _isLoading = true;
      _controller.clear();
    });

    try {
      final result = await _client.chat.createAndPoll(
        CreateChatRequest(
          botId: 'your_bot_id',
          additionalMessages: _messages,
        ),
      );

      setState(() {
        _messages.add(result.messages.last);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('错误: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Coze Chat')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg.role == RoleType.user;

                return ListTile(
                  title: Text(
                    msg.content,
                    style: TextStyle(
                      color: isUser ? Colors.blue : Colors.black,
                    ),
                  ),
                  subtitle: Text(isUser ? '用户' : 'Bot'),
                );
              },
            ),
          ),
          if (_isLoading) const LinearProgressIndicator(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: '输入消息...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## 流式聊天界面

```dart
class StreamingChatPage extends StatefulWidget {
  const StreamingChatPage({super.key});

  @override
  State<StreamingChatPage> createState() => _StreamingChatPageState();
}

class _StreamingChatPageState extends State<StreamingChatPage> {
  final _client = CozeAPI(
    token: 'your_pat_token',
    baseURL: CozeURLs.comBaseURL,
  );

  String _response = '';
  bool _isStreaming = false;

  Future<void> _sendMessage(String text) async {
    setState(() {
      _response = '';
      _isStreaming = true;
    });

    final stream = _client.chat.stream(
      CreateChatRequest(
        botId: 'your_bot_id',
        additionalMessages: [Message.user(content: text)],
      ),
    );

    await for (final event in stream) {
      if (event.event == ChatEventType.conversationMessageDelta) {
        setState(() {
          _response += event.data['content'] ?? '';
        });
      }
    }

    setState(() => _isStreaming = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('流式聊天')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Text(_response),
            ),
          ),
          if (_isStreaming) const LinearProgressIndicator(),
        ],
      ),
    );
  }
}
```

---

## 相关链接

- [完整示例合集](complete-examples.md) - 更多示例
- [服务端示例](server-example.md) - 服务端代码
