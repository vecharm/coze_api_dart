# 重试策略配置

本文档介绍如何配置请求重试策略。

## 概述

SDK 支持自动重试机制，可以在请求失败时自动重试。

## 基础重试

```dart
final client = CozeAPI(
  token: 'your_pat_token',
  baseURL: CozeURLs.comBaseURL,
  config: CozeConfig(
    maxRetries: 3,
  ),
);
```

## 自定义重试

```dart
Future<T> retry<T>(
  Future<T> Function() operation, {
  int maxAttempts = 3,
  Duration delay = const Duration(seconds: 1),
}) async {
  int attempts = 0;

  while (attempts < maxAttempts) {
    try {
      return await operation();
    } catch (e) {
      attempts++;
      if (attempts >= maxAttempts) rethrow;
      await Future.delayed(delay * attempts);
    }
  }

  throw Exception('Max retries exceeded');
}
```

## 指数退避

```dart
Future<T> retryWithExponentialBackoff<T>(
  Future<T> Function() operation,
) async {
  const maxRetries = 3;
  var delay = const Duration(seconds: 1);

  for (var i = 0; i < maxRetries; i++) {
    try {
      return await operation();
    } catch (e) {
      if (i == maxRetries - 1) rethrow;
      await Future.delayed(delay);
      delay *= 2;
    }
  }

  throw Exception('Max retries exceeded');
}
```

## 相关链接

- [配置说明](../getting-started/configuration.md) - 客户端配置
