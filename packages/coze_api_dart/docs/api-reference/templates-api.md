# Templates API 参考

本文档详细介绍 Templates API 的所有类和方法。

## TemplatesAPI 类

模板管理相关 API 的主类。

### 方法

#### retrieve()

获取模板信息。

```dart
Future<Template> retrieve(
  String templateId, {
  String? spaceId,
})
```

**参数：**

| 参数 | 类型 | 说明 |
|------|------|------|
| `templateId` | `String` | 模板 ID |
| `spaceId` | `String?` | 工作空间 ID |

**返回：** `Template` - 模板信息

---

#### duplicate()

复制模板。

```dart
Future<DuplicateTemplateResponse> duplicate(DuplicateTemplateRequest request)
```

**参数：**

| 参数 | 类型 | 说明 |
|------|------|------|
| `request` | `DuplicateTemplateRequest` | 复制请求 |

**返回：** `DuplicateTemplateResponse` - 复制响应

**示例：**

```dart
final response = await client.templates.duplicate(
  DuplicateTemplateRequest(
    templateId: 'template_id',
    spaceId: 'space_id',
    name: '我的 Bot',
  ),
);

print('Bot ID: ${response.botId}');
```

---

## 数据类

### DuplicateTemplateRequest

| 属性 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `templateId` | `String` | 是 | 模板 ID |
| `spaceId` | `String` | 是 | 工作空间 ID |
| `name` | `String` | 是 | 新 Bot 名称 |
| `description` | `String?` | 否 | 新 Bot 描述 |

### DuplicateTemplateResponse

| 属性 | 类型 | 说明 |
|------|------|------|
| `botId` | `String` | 创建的 Bot ID |

---

## 相关链接

- [模板管理指南](../guides/templates.md) - 使用指南
