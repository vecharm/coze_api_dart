# Bots API 参考

本文档详细介绍 Bots API 的所有类和方法。

## BotsAPI 类

Bot 管理相关 API 的主类。

### 方法

#### retrieve()

获取 Bot 详细信息。

```dart
Future<Bot> retrieve(
  String botId, {
  String? spaceId,
})
```

**参数：**

| 参数 | 类型 | 说明 |
|------|------|------|
| `botId` | `String` | Bot ID |
| `spaceId` | `String?` | 工作空间 ID |

**返回：** `Bot` - Bot 信息

**示例：**

```dart
final bot = await client.bots.retrieve('bot_id');
print('Bot 名称: ${bot.name}');
```

---

#### retrievePublished()

获取已发布的 Bot 信息。

```dart
Future<Bot> retrievePublished(
  String botId, {
  String? spaceId,
})
```

---

#### retrieveNew()

获取 Bot 信息（新版 API）。

```dart
Future<BotNew> retrieveNew(
  String botId, {
  RetrieveBotNewRequest? request,
})
```

---

#### list()

列出 Bot 列表。

```dart
Future<ListBotsResponse> list(ListBotsRequest request)
```

**参数：**

| 参数 | 类型 | 说明 |
|------|------|------|
| `request` | `ListBotsRequest` | 列表请求 |

**返回：** `ListBotsResponse` - Bot 列表响应

**示例：**

```dart
final response = await client.bots.list(
  ListBotsRequest(
    spaceId: 'space_id',
    pageNum: 1,
    pageSize: 20,
  ),
);
```

---

#### listPublished()

列出已发布的 Bot。

```dart
Future<ListBotsResponse> listPublished(ListBotsRequest request)
```

---

#### listNew()

列出 Bot（新版 API）。

```dart
Future<ListBotsNewResponse> listNew(ListBotsNewRequest request)
```

---

#### create()

创建 Bot。

```dart
Future<CreateBotResponse> create(CreateBotRequest request)
```

**参数：**

| 参数 | 类型 | 说明 |
|------|------|------|
| `request` | `CreateBotRequest` | 创建请求 |

**返回：** `CreateBotResponse` - 创建响应

**示例：**

```dart
final response = await client.bots.create(
  CreateBotRequest(
    spaceId: 'space_id',
    name: '我的 Bot',
    description: 'Bot 描述',
    prompt: '你是一个 helpful assistant',
  ),
);
```

---

#### update()

更新 Bot。

```dart
Future<void> update(UpdateBotRequest request)
```

**参数：**

| 参数 | 类型 | 说明 |
|------|------|------|
| `request` | `UpdateBotRequest` | 更新请求 |

**示例：**

```dart
await client.bots.update(
  UpdateBotRequest(
    botId: 'bot_id',
    name: '新名称',
    prompt: '新提示词',
  ),
);
```

---

#### publish()

发布 Bot。

```dart
Future<void> publish(PublishBotRequest request)
```

**参数：**

| 参数 | 类型 | 说明 |
|------|------|------|
| `request` | `PublishBotRequest` | 发布请求 |

**示例：**

```dart
await client.bots.publish(
  PublishBotRequest(
    botId: 'bot_id',
    connectorIds: ['1024'],
  ),
);
```

---

## 数据类

### Bot

Bot 信息。

| 属性 | 类型 | 说明 |
|------|------|------|
| `botId` | `String` | Bot ID |
| `name` | `String` | Bot 名称 |
| `description` | `String?` | Bot 描述 |
| `iconUrl` | `String?` | 图标 URL |
| `publishStatus` | `int` | 发布状态 |

### CreateBotRequest

创建 Bot 请求。

| 属性 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `spaceId` | `String` | 是 | 工作空间 ID |
| `name` | `String` | 是 | Bot 名称 |
| `description` | `String?` | 否 | Bot 描述 |
| `iconFileId` | `String?` | 否 | 图标文件 ID |
| `prompt` | `String?` | 否 | 提示词 |
| `model` | `String?` | 否 | 模型 |
| `temperature` | `double?` | 否 | 温度参数 |
| `maxTokens` | `int?` | 否 | 最大 Token 数 |

### UpdateBotRequest

更新 Bot 请求。

| 属性 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `botId` | `String` | 是 | Bot ID |
| `name` | `String?` | 否 | Bot 名称 |
| `description` | `String?` | 否 | Bot 描述 |
| `prompt` | `String?` | 否 | 提示词 |
| `temperature` | `double?` | 否 | 温度参数 |
| `maxTokens` | `int?` | 否 | 最大 Token 数 |

---

## 相关链接

- [Bot 管理指南](../guides/bots.md) - 使用指南
