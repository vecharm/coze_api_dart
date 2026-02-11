# Conversations API 参考

本文档详细介绍 Conversations API 的所有类和方法。

## ConversationsAPI 类

会话管理相关 API 的主类。

### 方法

#### create()

创建会话。

```dart
Future<Conversation> create(CreateConversationRequest request)
```

#### retrieve()

获取会话信息。

```dart
Future<Conversation> retrieve(String conversationId)
```

#### list()

列出会话。

```dart
Future<ListConversationsResponse> list(ListConversationsRequest request)
```

#### delete()

删除会话。

```dart
Future<void> delete(String conversationId)
```

---

## ConversationsMessagesAPI 类

会话消息管理 API。

### 方法

#### create()

创建消息。

```dart
Future<Message> create(
  String conversationId,
  CreateMessageRequest request,
)
```

#### retrieve()

获取消息。

```dart
Future<Message> retrieve(
  String conversationId,
  String messageId,
)
```

#### update()

更新消息。

```dart
Future<void> update(
  String conversationId,
  String messageId,
  UpdateMessageRequest request,
)
```

#### list()

列出消息。

```dart
Future<ListMessagesResponse> list(
  String conversationId, {
  ListMessagesRequest? request,
})
```

#### delete()

删除消息。

```dart
Future<void> delete(
  String conversationId,
  String messageId,
)
```

---

## 相关链接

- [会话管理指南](../guides/conversations.md) - 使用指南
