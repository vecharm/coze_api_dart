# Variables API 参考

本文档详细介绍 Variables API 的所有类和方法。

## VariablesAPI 类

变量管理相关 API 的主类。

### 方法

#### update()

更新变量。

```dart
Future<void> update(UpdateVariablesRequest request)
```

**参数：**

| 参数 | 类型 | 说明 |
|------|------|------|
| `request` | `UpdateVariablesRequest` | 更新请求 |

**示例：**

```dart
await client.variables.update(
  UpdateVariablesRequest(
    botId: 'bot_id',
    connectorId: '1024',
    connectorUid: 'user_123',
    data: [
      VariableItem(keyword: 'name', value: '张三'),
    ],
  ),
);
```

---

#### retrieve()

获取变量。

```dart
Future<RetrieveVariablesResponse> retrieve(RetrieveVariablesRequest request)
```

**参数：**

| 参数 | 类型 | 说明 |
|------|------|------|
| `request` | `RetrieveVariablesRequest` | 获取请求 |

**返回：** `RetrieveVariablesResponse` - 变量响应

**示例：**

```dart
final response = await client.variables.retrieve(
  RetrieveVariablesRequest(
    botId: 'bot_id',
    connectorId: '1024',
    connectorUid: 'user_123',
  ),
);

for (final item in response.items) {
  print('${item.keyword}: ${item.value}');
}
```

---

## 数据类

### UpdateVariablesRequest

| 属性 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `botId` | `String?` | 否 | Bot ID |
| `appId` | `String?` | 否 | App ID |
| `connectorId` | `String` | 是 | 渠道 ID |
| `connectorUid` | `String` | 是 | 用户 ID |
| `data` | `List<VariableItem>` | 是 | 变量数据 |

### VariableItem

| 属性 | 类型 | 说明 |
|------|------|------|
| `keyword` | `String` | 变量名 |
| `value` | `String` | 变量值 |

---

## 相关链接

- [变量管理指南](../guides/variables.md) - 使用指南
