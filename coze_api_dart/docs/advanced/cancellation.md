# 请求取消

本文档介绍如何取消正在进行的请求。

## 概述

SDK 支持取消正在进行的请求，适用于：

- 用户主动取消
- 页面切换时取消
- 超时取消

## 基础取消

```dart
final cancellationToken = CancellationToken();

Future.delayed(Duration(seconds: 5), () {
  cancellationToken.cancel();
});

try {
  final stream = client.chat.stream(
    CreateChatRequest(...),
    cancellationToken: cancellationToken,
  );
  // ...
} on CancelledException {
  print('请求已取消');
}
```

## Flutter 集成

```dart
class ChatController {
  CancellationToken? _token;

  void startChat() {
    _token = CancellationToken();
    // ...
  }

  void cancel() {
    _token?.cancel();
  }
}
```

## 相关链接

- [流式响应指南](../guides/streaming.md) - 流式请求取消
