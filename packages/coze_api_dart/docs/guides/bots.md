# Bot 管理指南

本文档详细介绍如何使用 Coze API Dart SDK 进行 Bot 管理，包括创建、查询、更新、发布 Bot 等操作。

## 目录

- [概述](#概述)
- [获取 Bot 信息](#获取-bot-信息)
- [列出 Bot 列表](#列出-bot-列表)
- [创建 Bot](#创建-bot)
- [更新 Bot](#更新-bot)
- [发布 Bot](#发布-bot)
- [最佳实践](#最佳实践)

---

## 概述

Bot 是 Coze 平台的核心概念，代表一个 AI 助手。通过 Bots API，你可以：

- 获取 Bot 详细信息
- 列出空间中的所有 Bot
- 创建新的 Bot
- 更新 Bot 配置
- 发布 Bot 到生产环境

---

## 获取 Bot 信息

### 获取在线 Bot 信息

```dart
import 'package:coze_api_dart/coze_api_dart.dart';

void main() async {
  final client = CozeAPI(
    token: 'your_pat_token',
    baseURL: CozeURLs.comBaseURL,
  );

  try {
    final bot = await client.bots.retrieve(
      'your_bot_id',
      spaceId: 'your_space_id',  // 可选
    );

    print('Bot 名称: ${bot.name}');
    print('Bot 描述: ${bot.description}');
    print('发布状态: ${bot.publishStatus}');
    print('图标 URL: ${bot.iconUrl}');
  } catch (e) {
    print('获取 Bot 信息失败: $e');
  }
}
```

### 获取已发布的 Bot 信息

```dart
final bot = await client.bots.retrievePublished(
  'your_bot_id',
  spaceId: 'your_space_id',
);
```

### 获取 Bot 信息（新版 API）

```dart
final bot = await client.bots.retrieveNew(
  'your_bot_id',
  request: RetrieveBotNewRequest(
    spaceId: 'your_space_id',
  ),
);
```

---

## 列出 Bot 列表

### 基础列表

```dart
final response = await client.bots.list(
  ListBotsRequest(
    spaceId: 'your_space_id',
    pageNum: 1,
    pageSize: 20,
  ),
);

print('总数: ${response.total}');

for (final bot in response.botList) {
  print('ID: ${bot.botId}');
  print('名称: ${bot.botName}');
  print('描述: ${bot.description}');
  print('---');
}
```

### 列出已发布的 Bot

```dart
final response = await client.bots.listPublished(
  ListBotsRequest(
    spaceId: 'your_space_id',
    pageNum: 1,
    pageSize: 20,
  ),
);
```

### 列出 Bot（新版 API）

```dart
final response = await client.bots.listNew(
  ListBotsNewRequest(
    spaceId: 'your_space_id',
    page: 1,
    pageSize: 20,
  ),
);

for (final bot in response.bots) {
  print('ID: ${bot.id}');
  print('名称: ${bot.name}');
}
```

---

## 创建 Bot

```dart
final response = await client.bots.create(
  CreateBotRequest(
    spaceId: 'your_space_id',
    name: '我的新 Bot',
    description: '这是一个测试 Bot',
    iconFileId: 'icon_file_id',  // 可选：上传的图标文件 ID
    prompt: '''
你是一个 helpful assistant，擅长回答各种问题。
请用友好、专业的语气回答用户。
''',
    model: 'gpt-4',  // 模型选择
    temperature: 0.7,  // 温度参数
    maxTokens: 2000,  // 最大 Token 数
  ),
);

print('创建成功，Bot ID: ${response.botId}');
```

---

## 更新 Bot

```dart
await client.bots.update(
  UpdateBotRequest(
    botId: 'your_bot_id',
    name: '更新后的名称',
    description: '更新后的描述',
    prompt: '更新后的提示词',
    temperature: 0.8,
  ),
);

print('Bot 更新成功');
```

---

## 发布 Bot

```dart
await client.bots.publish(
  PublishBotRequest(
    botId: 'your_bot_id',
    connectorIds: ['1024'],  // 发布渠道，1024 表示 API
  ),
);

print('Bot 发布成功');
```

---

## 最佳实践

### 1. 错误处理

```dart
Future<void> safeBotOperation() async {
  try {
    final bot = await client.bots.retrieve('bot_id');
    // 处理 Bot 信息
  } on CozeException catch (e) {
    if (e.code == 'BOT_NOT_FOUND') {
      print('Bot 不存在');
    } else if (e.code == 'NO_PERMISSION') {
      print('没有权限访问此 Bot');
    } else {
      print('操作失败: ${e.message}');
    }
  }
}
```

### 2. 分页处理

```dart
Future<List<Bot>> getAllBots(String spaceId) async {
  final bots = <Bot>[];
  int pageNum = 1;
  const pageSize = 50;

  while (true) {
    final response = await client.bots.list(
      ListBotsRequest(
        spaceId: spaceId,
        pageNum: pageNum,
        pageSize: pageSize,
      ),
    );

    bots.addAll(response.botList);

    if (response.botList.length < pageSize) {
      break;
    }
    pageNum++;
  }

  return bots;
}
```

### 3. Bot 配置管理

```dart
class BotConfigManager {
  final CozeAPI client;

  BotConfigManager(this.client);

  Future<void> updateBotConfig(
    String botId, {
    String? prompt,
    double? temperature,
    int? maxTokens,
  }) async {
    await client.bots.update(
      UpdateBotRequest(
        botId: botId,
        prompt: prompt,
        temperature: temperature,
        maxTokens: maxTokens,
      ),
    );
  }

  Future<void> publishToAPI(String botId) async {
    await client.bots.publish(
      PublishBotRequest(
        botId: botId,
        connectorIds: ['1024'],  // API 渠道
      ),
    );
  }
}
```

---

## 下一步

- [Chat 对话指南](chat.md) - 使用 Bot 进行对话
- [工作流指南](workflows.md) - 配置 Bot 工作流
