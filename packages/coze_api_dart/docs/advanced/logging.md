# 日志配置

本文档介绍如何配置 SDK 日志。

## 概述

SDK 提供了日志功能，帮助调试和排查问题。

## 启用日志

```dart
final client = CozeAPI(
  token: 'your_pat_token',
  baseURL: CozeURLs.comBaseURL,
  config: CozeConfig(
    enableLogging: true,
  ),
);
```

## 自定义日志输出

```dart
Logger.setLevel(LogLevel.debug);

Logger.setOutput((level, message) {
  print('[${level.name}] $message');
});
```

## 日志级别

```dart
enum LogLevel {
  debug,
  info,
  warning,
  error,
}
```

## 相关链接

- [配置说明](../getting-started/configuration.md) - 客户端配置
