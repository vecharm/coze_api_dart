# 模板管理指南

本文档详细介绍如何使用 Coze API Dart SDK 管理模板。

## 目录

- [概述](#概述)
- [获取模板信息](#获取模板信息)
- [复制模板](#复制模板)
- [最佳实践](#最佳实践)

---

## 概述

Templates API 用于获取和复制 Bot 模板。

---

## 获取模板信息

```dart
import 'package:coze_api_dart/coze_api_dart.dart';

void main() async {
  final client = CozeAPI(
    token: 'your_pat_token',
    baseURL: CozeURLs.comBaseURL,
  );

  final template = await client.templates.retrieve(
    'template_id',
    spaceId: 'your_space_id',  // 可选
  );

  print('模板 ID: ${template.templateId}');
  print('模板名称: ${template.templateName}');
  print('描述: ${template.description}');
}
```

---

## 复制模板

```dart
final result = await client.templates.duplicate(
  DuplicateTemplateRequest(
    templateId: 'template_id',
    spaceId: 'your_space_id',
    name: '我的 Bot',  // 新 Bot 名称
    description: '基于模板创建的 Bot',  // 新 Bot 描述
  ),
);

print('Bot 创建成功: ${result.botId}');
```

---

## 最佳实践

### 1. 模板管理器

```dart
class TemplateManager {
  final CozeAPI client;

  TemplateManager(this.client);

  Future<String> createBotFromTemplate(
    String templateId,
    String spaceId, {
    required String name,
    String? description,
  }) async {
    final result = await client.templates.duplicate(
      DuplicateTemplateRequest(
        templateId: templateId,
        spaceId: spaceId,
        name: name,
        description: description,
      ),
    );

    return result.botId;
  }
}
```

---

## 下一步

- [Bot 管理指南](bots.md) - 管理创建的 Bot
