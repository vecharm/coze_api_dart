# Workspaces API 参考

本文档详细介绍 Workspaces API 的所有类和方法。

## WorkspacesAPI 类

工作空间管理相关 API 的主类。

### 方法

#### list()

列出工作空间。

```dart
Future<ListWorkspacesResponse> list(ListWorkspacesRequest request)
```

**参数：**

| 参数 | 类型 | 说明 |
|------|------|------|
| `request` | `ListWorkspacesRequest` | 列表请求 |

**返回：** `ListWorkspacesResponse` - 工作空间列表响应

**示例：**

```dart
final response = await client.workspaces.list(
  ListWorkspacesRequest(
    pageNum: 1,
    pageSize: 20,
  ),
);

for (final workspace in response.workspaces) {
  print('ID: ${workspace.id}');
  print('名称: ${workspace.name}');
}
```

---

## 数据类

### ListWorkspacesRequest

| 属性 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `pageNum` | `int?` | 否 | 页码 |
| `pageSize` | `int?` | 否 | 每页数量 |

### Workspace

| 属性 | 类型 | 说明 |
|------|------|------|
| `id` | `String` | 工作空间 ID |
| `name` | `String` | 工作空间名称 |
| `description` | `String?` | 描述 |
| `createdAt` | `int` | 创建时间 |

---

## 相关链接

- [工作空间指南](../guides/workspaces.md) - 使用指南
