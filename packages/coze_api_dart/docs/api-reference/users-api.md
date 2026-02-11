# Users API 参考

本文档详细介绍 Users API 的所有类和方法。

## UsersAPI 类

用户管理相关 API 的主类。

### 方法

#### retrieve()

获取当前用户信息。

```dart
Future<User> retrieve()
```

**返回：** `User` - 用户信息

**示例：**

```dart
final user = await client.users.retrieve();

print('用户 ID: ${user.userId}');
print('用户名: ${user.userName}');
print('头像: ${user.avatarUrl}');
```

---

## 数据类

### User

| 属性 | 类型 | 说明 |
|------|------|------|
| `userId` | `String` | 用户 ID |
| `userName` | `String` | 用户名 |
| `avatarUrl` | `String?` | 头像 URL |
| `description` | `String?` | 描述 |

---

## 相关链接

- [用户管理指南](../guides/users.md) - 使用指南
