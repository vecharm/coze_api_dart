# 枚举类型参考

本文档详细介绍 Coze API Dart SDK 中的所有枚举类型。

## RoleType

消息角色。

```dart
enum RoleType {
  user,       // 用户
  assistant,  // 助手
  system,     // 系统
  tool,       // 工具
}
```

---

## ContentType

内容类型。

```dart
enum ContentType {
  text,         // 文本
  objectString, // 对象字符串
  card,         // 卡片
  audio,        // 音频
}
```

---

## ChatStatus

对话状态。

```dart
enum ChatStatus {
  created,         // 已创建
  inProgress,      // 进行中
  completed,       // 已完成
  failed,          // 失败
  requiresAction,  // 需要操作
}
```

---

## ChatEventType

流式事件类型。

```dart
enum ChatEventType {
  conversationChatCreated,
  conversationChatInProgress,
  conversationChatCompleted,
  conversationChatFailed,
  conversationChatRequiresAction,
  conversationMessageCreated,
  conversationMessageInProgress,
  conversationMessageDelta,
  conversationMessageCompleted,
  error,
  done,
}
```

---

## MessageType

消息类型。

```dart
enum MessageType {
  question,  // 问题
  answer,    // 答案
  function,  // 函数调用
  tool,      // 工具
}
```

---

## 相关链接

- [数据模型参考](models.md) - 相关数据模型
