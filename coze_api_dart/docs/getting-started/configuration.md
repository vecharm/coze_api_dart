# 配置说明

本文档介绍 Coze API Dart SDK 的高级配置选项。

## 基础配置

### 初始化客户端

```dart
import 'package:coze_api_dart/coze_api_dart.dart';

final client = CozeAPI(
  token: 'your_pat_token',
  baseURL: CozeURLs.comBaseURL,
  config: CozeConfig(
    timeout: Duration(seconds: 60),
    streamTimeout: Duration(seconds: 120),
    maxRetries: 3,
    enableLogging: true,
  ),
);
```

### 配置参数说明

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `timeout` | `Duration` | 30秒 | HTTP 请求超时时间 |
| `streamTimeout` | `Duration` | 60秒 | 流式请求超时时间 |
| `maxRetries` | `int` | 3 | 请求失败时的最大重试次数 |
| `enableLogging` | `bool` | false | 是否启用调试日志 |

## 动态令牌

当令牌需要动态获取时（如从服务器获取）：

```dart
final client = CozeAPI(
  token: () async {
    // 从安全存储或服务器获取令牌
    return await getTokenFromServer();
  },
  baseURL: CozeURLs.comBaseURL,
);
```

## 自定义 HTTP 客户端

```dart
final httpClient = HttpClient(
  auth: PATAuth('your_pat_token'),
  config: HttpClientConfig(
    baseURL: CozeURLs.comBaseURL,
    timeout: Duration(seconds: 60),
    defaultHeaders: {
      'X-Custom-Header': 'value',
    },
  ),
);

final client = CozeAPI.fromClient(httpClient);
```

## 区域配置

### 国际版

```dart
final client = CozeAPI(
  token: 'your_pat_token',
  baseURL: CozeURLs.comBaseURL,  // https://www.coze.com
);
```

### 中国版

```dart
final client = CozeAPI(
  token: 'your_pat_token',
  baseURL: CozeURLs.cnBaseURL,  // https://www.coze.cn
);
```

### 自定义域名

```dart
final client = CozeAPI(
  token: 'your_pat_token',
  baseURL: 'https://your-custom-domain.com',
);
```

## 日志配置

### 启用调试日志

```dart
final client = CozeAPI(
  token: 'your_pat_token',
  baseURL: CozeURLs.comBaseURL,
  config: CozeConfig(enableLogging: true),
);
```

### 自定义日志

```dart
import 'package:coze_api_dart/coze_api_dart.dart';

// 设置日志级别
Logger.setLevel(LogLevel.debug);

// 自定义日志输出
Logger.setOutput((level, message) {
  print('[${level.name}] $message');
});
```

## 代理配置

```dart
final client = CozeAPI(
  token: 'your_pat_token',
  baseURL: CozeURLs.comBaseURL,
  config: CozeConfig(
    proxy: 'http://proxy.example.com:8080',
  ),
);
```

## 连接池配置

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

## 完整配置示例

```dart
import 'package:coze_api_dart/coze_api_dart.dart';

void main() {
  final client = CozeAPI(
    token: 'your_pat_token',
    baseURL: CozeURLs.comBaseURL,
    config: CozeConfig(
      // 超时配置
      timeout: Duration(seconds: 60),
      streamTimeout: Duration(seconds: 120),
      
      // 重试配置
      maxRetries: 3,
      retryDelay: Duration(seconds: 1),
      
      // 日志配置
      enableLogging: true,
      
      // 连接配置
      maxConnections: 10,
      connectionTimeout: Duration(seconds: 10),
      
      // 代理配置
      proxy: 'http://proxy.example.com:8080',
      
      // 自定义请求头
      defaultHeaders: {
        'X-Custom-Header': 'value',
      },
    ),
  );
  
  // 使用客户端...
}
```

## 最佳实践

1. **超时设置**: 根据网络环境调整超时时间
2. **重试策略**: 合理设置重试次数，避免过度重试
3. **日志级别**: 生产环境建议关闭调试日志
4. **连接池**: 高并发场景适当增加连接数

## 下一步

- [认证方式](../guides/authentication.md) - 了解各种认证方式
- [错误处理](../advanced/error-handling.md) - 学习错误处理最佳实践
