# 错误处理最佳实践

本文档介绍如何在 Coze API Dart SDK 中正确处理错误。

## 概述

SDK 提供了多种异常类型，帮助你处理不同的错误场景：

- `CozeException` - SDK 基础异常
- `CancelledException` - 请求取消
- `TimeoutException` - 请求超时

## 基础错误处理

```dart
try {
  final result = await client.chat.createAndPoll(...);
} on CozeException catch (e) {
  print('Coze 错误: ${e.message}');
} on CancelledException catch (e) {
  print('请求已取消');
} on TimeoutException catch (e) {
  print('请求超时');
} catch (e) {
  print('未知错误: $e');
}
```

## 错误码处理

```dart
try {
  final result = await client.chat.createAndPoll(...);
} on CozeException catch (e) {
  switch (e.code) {
    case 'BOT_NOT_FOUND':
      print('Bot 不存在');
      break;
    case 'NO_PERMISSION':
      print('没有权限');
      break;
    default:
      print('错误: ${e.message}');
  }
}
```

## 全局错误处理

```dart
class ErrorHandler {
  static void handle(Object error) {
    if (error is CozeException) {
      print('Coze 错误: ${error.message}');
    } else {
      print('系统错误: $error');
    }
  }
}
```

## 相关链接

- [异常处理参考](../api-reference/exceptions.md) - 异常类详情
