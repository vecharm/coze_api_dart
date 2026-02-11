# 用户管理指南

本文档详细介绍如何使用 Coze API Dart SDK 获取用户信息。

## 目录

- [概述](#概述)
- [获取用户信息](#获取用户信息)
- [最佳实践](#最佳实践)

---

## 概述

Users API 用于获取当前登录用户的信息。

---

## 获取用户信息

```dart
import 'package:coze_api_dart/coze_api_dart.dart';

void main() async {
  final client = CozeAPI(
    token: 'your_pat_token',
    baseURL: CozeURLs.comBaseURL,
  );

  try {
    final user = await client.users.retrieve();

    print('用户 ID: ${user.userId}');
    print('用户名: ${user.userName}');
    print('头像 URL: ${user.avatarUrl}');
    print('描述: ${user.description}');
  } catch (e) {
    print('获取用户信息失败: $e');
  }
}
```

---

## 最佳实践

### 1. 用户信息缓存

```dart
class UserCache {
  final CozeAPI client;
  User? _cache;
  DateTime? _lastUpdate;

  UserCache(this.client);

  Future<User> getUser() async {
    // 检查缓存是否有效（1小时内）
    if (_cache != null &&
        _lastUpdate != null &&
        DateTime.now().difference(_lastUpdate!) < Duration(hours: 1)) {
      return _cache!;
    }

    _cache = await client.users.retrieve();
    _lastUpdate = DateTime.now();

    return _cache!;
  }

  void invalidate() {
    _cache = null;
    _lastUpdate = null;
  }
}
```

---

## 下一步

- [认证方式](authentication.md) - 了解用户认证
