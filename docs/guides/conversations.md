# 会话管理指南

本文档详细介绍如何使用 Coze API Dart SDK 管理会话和消息。

## 目录

- [概述](#概述)
- [创建会话](#创建会话)
- [获取会话信息](#获取会话信息)
- [列出会话](#列出会话)
- [删除会话](#删除会话)
- [消息管理](#消息管理)
- [最佳实践](#最佳实践)

---

## 概述

Conversations API 用于管理对话会话，包括：

- 创建新会话
- 获取会话信息
- 列出所有会话
- 删除会话
- 管理会话中的消息

---

## 创建会话

```dart
import 'package:coze_api_dart/coze_api_dart.dart';

void main() async {
  final client = CozeAPI(
    token: 'your_pat_token',
    baseURL: CozeURLs.comBaseURL,
  );

  // 创建新会话
  final conversation = await client.conversations.create(
    CreateConversationRequest(
      botId: 'your_bot_id',
      messages: [
        Message.system(content: '你是一个 helpful assistant'),
      ],
    ),
  );

  print('会话创建成功');
  print('会话 ID: ${conversation.id}');
  print('创建时间: ${conversation.createdAt}');
}
```

---

## 获取会话信息

```dart
final conversation = await client.conversations.retrieve(
  'conversation_id',
);

print('会话 ID: ${conversation.id}');
print('Bot ID: ${conversation.botId}');
print('创建时间: ${conversation.createdAt}');
```

---

## 列出会话

```dart
final response = await client.conversations.list(
  ListConversationsRequest(
    botId: 'your_bot_id',  // 可选：筛选特定 Bot 的会话
    pageNum: 1,
    pageSize: 20,
  ),
);

print('总会话数: ${response.total}');

for (final conversation in response.conversations) {
  print('ID: ${conversation.id}');
  print('创建时间: ${conversation.createdAt}');
  print('---');
}
```

---

## 删除会话

```dart
await client.conversations.delete('conversation_id');
print('会话已删除');
```

---

## 消息管理

### 创建消息

```dart
final message = await client.conversations.messages.create(
  'conversation_id',
  CreateMessageRequest(
    role: RoleType.user,
    content: '你好！',
    contentType: ContentType.text,
  ),
);

print('消息创建成功: ${message.id}');
```

### 获取消息

```dart
final message = await client.conversations.messages.retrieve(
  'conversation_id',
  'message_id',
);

print('角色: ${message.role}');
print('内容: ${message.content}');
print('类型: ${message.type}');
```

### 更新消息

```dart
await client.conversations.messages.update(
  'conversation_id',
  'message_id',
  UpdateMessageRequest(
    content: '更新后的内容',
    contentType: ContentType.text,
  ),
);
```

### 列出消息

```dart
final response = await client.conversations.messages.list(
  'conversation_id',
  ListMessagesRequest(
    order: 'desc',  // 倒序排列
    pageNum: 1,
    pageSize: 50,
  ),
);

for (final message in response.messages) {
  print('${message.role}: ${message.content}');
}
```

### 删除消息

```dart
await client.conversations.messages.delete(
  'conversation_id',
  'message_id',
);
```

---

## 最佳实践

### 1. 会话管理器

```dart
class ConversationManager {
  final CozeAPI client;
  final Map<String, String> _activeConversations = {};

  ConversationManager(this.client);

  Future<String> getOrCreateConversation(String botId) async {
    if (_activeConversations.containsKey(botId)) {
      return _activeConversations[botId]!;
    }

    final conversation = await client.conversations.create(
      CreateConversationRequest(botId: botId),
    );

    _activeConversations[botId] = conversation.id;
    return conversation.id;
  }

  Future<void> clearConversation(String botId) async {
    final conversationId = _activeConversations[botId];
    if (conversationId != null) {
      await client.conversations.delete(conversationId);
      _activeConversations.remove(botId);
    }
  }
}
```

### 2. 消息历史管理

```dart
class MessageHistory {
  final String conversationId;
  final CozeAPI client;
  List<Message> _messages = [];

  MessageHistory(this.conversationId, this.client);

  Future<void> loadHistory() async {
    final response = await client.conversations.messages.list(
      conversationId,
      ListMessagesRequest(pageNum: 1, pageSize: 100),
    );
    _messages = response.messages;
  }

  Future<void> addMessage(Message message) async {
    await client.conversations.messages.create(
      conversationId,
      CreateMessageRequest(
        role: message.role,
        content: message.content,
        contentType: message.contentType,
      ),
    );
    _messages.add(message);
  }

  List<Message> get messages => List.unmodifiable(_messages);
}
```

---

## 下一步

- [Chat 对话指南](chat.md) - 在会话中进行对话
- [错误处理](../advanced/error-handling.md) - 错误处理最佳实践
