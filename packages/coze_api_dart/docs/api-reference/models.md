# 数据模型参考

本文档详细介绍 Coze API Dart SDK 中的核心数据模型。

## Message 类

对话消息。

### 构造函数

```dart
Message({
  required RoleType role,
  required String content,
  ContentType? contentType,
  List<ObjectStringItem>? objectContent,
  String? metaData,
})
```

### 便捷构造方法

```dart
Message.user({required String content, ...})
Message.assistant({required String content, ...})
Message.system({required String content})
```

---

## ChatResult 类

对话结果。

| 属性 | 类型 | 说明 |
|------|------|------|
| `id` | `String` | 对话 ID |
| `conversationId` | `String` | 会话 ID |
| `status` | `ChatStatus` | 状态 |
| `messages` | `List<Message>` | 消息列表 |

---

## TokenUsage 类

Token 使用情况。

| 属性 | 类型 | 说明 |
|------|------|------|
| `inputCount` | `int` | 输入 Token 数 |
| `outputCount` | `int` | 输出 Token 数 |
| `totalTokens` | `int` | 总 Token 数 |

---

## 相关链接

- [Chat API 参考](chat-api.md) - Chat 相关模型
