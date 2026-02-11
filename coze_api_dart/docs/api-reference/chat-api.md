# Chat API 参考

本文档详细介绍 Chat API 的所有类和方法。

## ChatAPI 类

对话相关 API 的主类。

### 方法

#### create()

创建对话（非流式）。

```dart
Future<ChatResult> create(CreateChatRequest request)
```

**参数：**

| 参数 | 类型 | 说明 |
|------|------|------|
| `request` | `CreateChatRequest` | 创建对话请求 |

**返回：** `ChatResult` - 对话结果

**示例：**

```dart
final result = await client.chat.create(
  CreateChatRequest(
    botId: 'your_bot_id',
    additionalMessages: [
      Message.user(content: '你好'),
    ],
  ),
);
```

---

#### createAndPoll()

创建对话并轮询结果（推荐）。

```dart
Future<ChatResult> createAndPoll(
  CreateChatRequest request, {
  int? timeout,
})
```

**参数：**

| 参数 | 类型 | 说明 |
|------|------|------|
| `request` | `CreateChatRequest` | 创建对话请求 |
| `timeout` | `int?` | 超时时间（毫秒） |

**返回：** `ChatResult` - 对话结果

**示例：**

```dart
final result = await client.chat.createAndPoll(
  CreateChatRequest(
    botId: 'your_bot_id',
    additionalMessages: [
      Message.user(content: '你好'),
    ],
  ),
  timeout: 60000,  // 60秒超时
);
```

---

#### stream()

创建流式对话。

```dart
Stream<ChatEvent> stream(
  CreateChatRequest request, {
  CancellationToken? cancellationToken,
})
```

**参数：**

| 参数 | 类型 | 说明 |
|------|------|------|
| `request` | `CreateChatRequest` | 创建对话请求 |
| `cancellationToken` | `CancellationToken?` | 取消令牌 |

**返回：** `Stream<ChatEvent>` - 流式事件

**示例：**

```dart
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
    print(event.data['content']);
  }
}
```

---

#### submitToolOutputs()

提交工具调用结果。

```dart
Future<ChatResult> submitToolOutputs({
  required String conversationId,
  required String chatId,
  required List<ToolOutput> toolOutputs,
})
```

**参数：**

| 参数 | 类型 | 说明 |
|------|------|------|
| `conversationId` | `String` | 会话 ID |
| `chatId` | `String` | 对话 ID |
| `toolOutputs` | `List<ToolOutput>` | 工具输出列表 |

**返回：** `ChatResult` - 对话结果

**示例：**

```dart
final result = await client.chat.submitToolOutputs(
  conversationId: 'conversation_id',
  chatId: 'chat_id',
  toolOutputs: [
    ToolOutput(
      toolCallId: 'tool_call_id',
      output: '工具执行结果',
    ),
  ],
);
```

---

## CreateChatRequest 类

创建对话请求。

### 构造函数

```dart
CreateChatRequest({
  required String botId,
  String? conversationId,
  String? userId,
  List<Message>? additionalMessages,
  Map<String, dynamic>? customVariables,
  bool? autoSaveHistory,
  String? metaData,
})
```

**参数：**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `botId` | `String` | 是 | Bot ID |
| `conversationId` | `String?` | 否 | 会话 ID（继续已有对话） |
| `userId` | `String?` | 否 | 用户 ID |
| `additionalMessages` | `List<Message>?` | 否 | 附加消息列表 |
| `customVariables` | `Map<String, dynamic>?` | 否 | 自定义变量 |
| `autoSaveHistory` | `bool?` | 否 | 是否自动保存历史 |
| `metaData` | `String?` | 否 | 元数据 |

---

## ChatResult 类

对话结果。

### 属性

| 属性 | 类型 | 说明 |
|------|------|------|
| `id` | `String` | 对话 ID |
| `conversationId` | `String` | 会话 ID |
| `botId` | `String` | Bot ID |
| `status` | `ChatStatus` | 对话状态 |
| `messages` | `List<Message>` | 消息列表 |
| `usage` | `TokenUsage?` | Token 使用情况 |
| `createdAt` | `int` | 创建时间 |
| `completedAt` | `int?` | 完成时间 |

---

## ChatEvent 类

流式对话事件。

### 属性

| 属性 | 类型 | 说明 |
|------|------|------|
| `event` | `ChatEventType` | 事件类型 |
| `data` | `Map<String, dynamic>` | 事件数据 |

---

## ChatEventType 枚举

流式事件类型。

| 值 | 说明 |
|----|------|
| `conversationChatCreated` | 对话创建 |
| `conversationChatInProgress` | 对话进行中 |
| `conversationChatCompleted` | 对话完成 |
| `conversationChatFailed` | 对话失败 |
| `conversationChatRequiresAction` | 需要操作 |
| `conversationMessageCreated` | 消息创建 |
| `conversationMessageInProgress` | 消息进行中 |
| `conversationMessageDelta` | 消息增量 |
| `conversationMessageCompleted` | 消息完成 |
| `error` | 错误 |
| `done` | 完成 |

---

## Message 类

消息。

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
// 用户消息
Message.user({
  required String content,
  ContentType? contentType,
  List<ObjectStringItem>? objectContent,
})

// 助手消息
Message.assistant({
  required String content,
  ContentType? contentType,
})

// 系统消息
Message.system({
  required String content,
})
```

### 属性

| 属性 | 类型 | 说明 |
|------|------|------|
| `role` | `RoleType` | 角色 |
| `content` | `String` | 内容 |
| `contentType` | `ContentType?` | 内容类型 |
| `type` | `MessageType?` | 消息类型 |

---

## RoleType 枚举

消息角色。

| 值 | 说明 |
|----|------|
| `user` | 用户 |
| `assistant` | 助手 |
| `system` | 系统 |
| `tool` | 工具 |

---

## ContentType 枚举

内容类型。

| 值 | 说明 |
|----|------|
| `text` | 文本 |
| `objectString` | 对象字符串（图文混排） |
| `card` | 卡片 |
| `audio` | 音频 |

---

## ChatStatus 枚举

对话状态。

| 值 | 说明 |
|----|------|
| `created` | 已创建 |
| `inProgress` | 进行中 |
| `completed` | 已完成 |
| `failed` | 失败 |
| `requiresAction` | 需要操作 |

---

## 相关链接

- [Chat 对话指南](../guides/chat.md) - 使用指南
- [流式响应指南](../guides/streaming.md) - 流式处理
