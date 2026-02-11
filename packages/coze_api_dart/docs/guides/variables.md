# 变量管理指南

本文档详细介绍如何使用 Coze API Dart SDK 管理 Bot 和应用变量。

## 目录

- [概述](#概述)
- [更新变量](#更新变量)
- [获取变量](#获取变量)
- [最佳实践](#最佳实践)

---

## 概述

Variables API 用于管理 Bot 和应用中的用户变量。通过此 API，你可以：

- 设置变量值
- 获取变量值
- 管理用户特定的变量

---

## 更新变量

```dart
import 'package:coze_api_dart/coze_api_dart.dart';

void main() async {
  final client = CozeAPI(
    token: 'your_pat_token',
    baseURL: CozeURLs.comBaseURL,
  );

  await client.variables.update(
    UpdateVariablesRequest(
      botId: 'your_bot_id',  // Bot ID 或 appId 必须提供一个
      // appId: 'your_app_id',
      connectorId: '1024',  // 渠道 ID
      connectorUid: 'user_123',  // 用户 ID
      data: [
        VariableItem(
          keyword: 'user_name',
          value: '张三',
        ),
        VariableItem(
          keyword: 'user_level',
          value: 'VIP',
        ),
      ],
    ),
  );

  print('变量更新成功');
}
```

---

## 获取变量

```dart
final variables = await client.variables.retrieve(
  RetrieveVariablesRequest(
    botId: 'your_bot_id',
    connectorId: '1024',
    connectorUid: 'user_123',
    keywords: ['user_name', 'user_level'],  // 可选：指定变量名
  ),
);

for (final item in variables.items) {
  print('变量名: ${item.keyword}');
  print('变量值: ${item.value}');
  print('创建时间: ${item.createTime}');
  print('更新时间: ${item.updateTime}');
  print('---');
}
```

---

## 最佳实践

### 1. 变量管理器

```dart
class VariableManager {
  final CozeAPI client;
  final String botId;

  VariableManager(this.client, this.botId);

  Future<void> setUserVariable(
    String userId,
    String key,
    String value,
  ) async {
    await client.variables.update(
      UpdateVariablesRequest(
        botId: botId,
        connectorId: '1024',
        connectorUid: userId,
        data: [
          VariableItem(keyword: key, value: value),
        ],
      ),
    );
  }

  Future<String?> getUserVariable(
    String userId,
    String key,
  ) async {
    final variables = await client.variables.retrieve(
      RetrieveVariablesRequest(
        botId: botId,
        connectorId: '1024',
        connectorUid: userId,
        keywords: [key],
      ),
    );

    return variables.items.firstWhere(
      (item) => item.keyword == key,
      orElse: () => VariableItem(keyword: '', value: ''),
    ).value;
  }
}
```

---

## 下一步

- [Chat 对话指南](chat.md) - 在对话中使用变量
- [Bot 管理指南](bots.md) - 配置 Bot 变量
