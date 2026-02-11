# 认证类参考

本文档详细介绍 Coze API Dart SDK 中所有认证相关的类。

## PATAuth 类

个人访问令牌认证。

### 构造函数

```dart
PATAuth(String token)
```

**参数：**

| 参数 | 类型 | 说明 |
|------|------|------|
| `token` | `String` | PAT 令牌 |

**示例：**

```dart
final auth = PATAuth('pat_xxx');
```

---

## OAuthWebAuth 类

OAuth Web 应用认证。

### 构造函数

```dart
OAuthWebAuth(
  OAuthConfig config, {
  Token? token,
})
```

---

## OAuthPKCEAuth 类

OAuth PKCE 认证（适用于移动端）。

### 构造函数

```dart
OAuthPKCEAuth({
  required String clientId,
  required String redirectUri,
  List<String>? scopes,
  Token? token,
})
```

---

## JWTAuth 类

JWT 认证。

### 构造函数

```dart
JWTAuth({
  required String token,
  String? refreshToken,
  Function(String, String?)? onTokenRefresh,
})
```

---

## DeviceCodeAuth 类

设备码认证（适用于无浏览器设备）。

### 构造函数

```dart
DeviceCodeAuth({
  required String clientId,
  List<String>? scopes,
  Token? token,
})
```

---

## 相关链接

- [认证方式指南](../guides/authentication.md) - 使用指南
