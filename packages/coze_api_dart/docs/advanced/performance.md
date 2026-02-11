# 性能优化

本文档介绍如何优化 SDK 性能。

## 概述

通过合理配置和使用方式，可以提升 SDK 性能。

## 连接池

```dart
final client = CozeAPI(
  token: 'your_pat_token',
  baseURL: CozeURLs.comBaseURL,
  config: CozeConfig(
    maxConnections: 10,
    connectionTimeout: Duration(seconds: 10),
  ),
);
```

## 超时配置

```dart
final client = CozeAPI(
  token: 'your_pat_token',
  baseURL: CozeURLs.comBaseURL,
  config: CozeConfig(
    timeout: Duration(seconds: 30),
    streamTimeout: Duration(seconds: 60),
  ),
);
```

## 缓存策略

```dart
class TTSCache {
  final _cache = <String, List<int>>{};

  Future<List<int>> getOrCreate(
    String text,
    Future<List<int>> Function() create,
  ) async {
    if (_cache.containsKey(text)) {
      return _cache[text]!;
    }
    final result = await create();
    _cache[text] = result;
    return result;
  }
}
```

## 批量处理

```dart
Future<void> batchProcess(List<String> items) async {
  await Future.wait(
    items.map((item) => process(item)),
  );
}
```

## 相关链接

- [配置说明](../getting-started/configuration.md) - 客户端配置
