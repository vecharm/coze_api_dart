# CozeClient API 参考

本文档详细介绍 `CozeAPI` 客户端类的所有方法和属性。

## CozeAPI 类

主客户端类，提供对所有 API 的访问。

### 构造函数

#### CozeAPI()

创建 CozeAPI 客户端实例。

```dart
CozeAPI({
  String? token,
  FutureOr<String> Function()? getToken,
  required String baseURL,
  CozeConfig? config,
})
```

**参数说明：**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `token` | `String?` | 否 | 静态令牌（PAT 或 OAuth Token） |
| `getToken` | `FutureOr<String> Function()?` | 否 | 动态获取令牌的函数 |
| `baseURL` | `String` | 是 | API 基础 URL |
| `config` | `CozeConfig?` | 否 | 客户端配置 |

**示例：**

```dart
// 使用静态令牌
final client = CozeAPI(
  token: 'pat_xxx',
  baseURL: CozeURLs.comBaseURL,
);

// 使用动态令牌
final client = CozeAPI(
  getToken: () async => await fetchToken(),
  baseURL: CozeURLs.comBaseURL,
);

// 带配置
final client = CozeAPI(
  token: 'pat_xxx',
  baseURL: CozeURLs.comBaseURL,
  config: CozeConfig(
    timeout: Duration(seconds: 60),
    enableLogging: true,
  ),
);
```

---

### 属性

#### chat → ChatAPI

访问 Chat 相关 API。

```dart
final chatAPI = client.chat;
```

#### bots → BotsAPI

访问 Bots 管理 API。

```dart
final botsAPI = client.bots;
```

#### workflows → WorkflowsAPI

访问 Workflows 相关 API。

```dart
final workflowsAPI = client.workflows;
```

#### files → FilesAPI

访问 Files 相关 API。

```dart
final filesAPI = client.files;
```

#### datasets → DatasetsAPI

访问 Datasets 相关 API。

```dart
final datasetsAPI = client.datasets;
```

#### knowledge → KnowledgeDocumentsAPI

访问 Knowledge Documents API。

```dart
final knowledgeAPI = client.knowledge;
```

#### conversations → ConversationsAPI

访问 Conversations 相关 API。

```dart
final conversationsAPI = client.conversations;
```

#### workspaces → WorkspacesAPI

访问 Workspaces API。

```dart
final workspacesAPI = client.workspaces;
```

#### templates → TemplatesAPI

访问 Templates API。

```dart
final templatesAPI = client.templates;
```

#### users → UsersAPI

访问 Users API。

```dart
final usersAPI = client.users;
```

#### voice → VoiceAPI

访问 Voice 相关 API（TTS/STT）。

```dart
final voiceAPI = client.voice;
```

#### audio → AudioAPI

访问 Audio 相关 API（语音克隆、房间、声纹）。

```dart
final audioAPI = client.audio;
```

#### variables → VariablesAPI

访问 Variables API。

```dart
final variablesAPI = client.variables;
```

#### websocket → WebSocketAPI

访问 WebSocket 相关 API。

```dart
final wsAPI = client.websocket;
```

---

### 方法

#### makeRequest()

发起通用 HTTP 请求。

```dart
Future<HttpResponse> makeRequest(
  String method,
  String path, {
  Map<String, dynamic>? body,
  Map<String, String>? queryParameters,
  Map<String, String>? headers,
})
```

**参数说明：**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `method` | `String` | 是 | HTTP 方法（GET/POST/PUT/DELETE） |
| `path` | `String` | 是 | API 路径 |
| `body` | `Map<String, dynamic>?` | 否 | 请求体 |
| `queryParameters` | `Map<String, String>?` | 否 | 查询参数 |
| `headers` | `Map<String, String>?` | 否 | 自定义请求头 |

**示例：**

```dart
final response = await client.makeRequest(
  'POST',
  '/v1/custom/endpoint',
  body: {'key': 'value'},
);
```

---

## CozeConfig 类

客户端配置类。

### 构造函数

```dart
CozeConfig({
  Duration? timeout,
  Duration? streamTimeout,
  int? maxRetries,
  bool? enableLogging,
})
```

**参数说明：**

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `timeout` | `Duration?` | 30秒 | 普通请求超时时间 |
| `streamTimeout` | `Duration?` | 60秒 | 流式请求超时时间 |
| `maxRetries` | `int?` | 3 | 最大重试次数 |
| `enableLogging` | `bool?` | false | 是否启用日志 |

---

## CozeURLs 类

预定义的 API 基础 URL。

### 常量

#### comBaseURL

国际版 API 地址。

```dart
static const String comBaseURL = 'https://www.coze.com';
```

#### cnBaseURL

中国版 API 地址。

```dart
static const String cnBaseURL = 'https://www.coze.cn';
```

**示例：**

```dart
// 国际版
final client = CozeAPI(
  token: token,
  baseURL: CozeURLs.comBaseURL,
);

// 中国版
final client = CozeAPI(
  token: token,
  baseURL: CozeURLs.cnBaseURL,
);
```

---

## 完整示例

```dart
import 'package:coze_api_dart/coze_api_dart.dart';

void main() async {
  // 创建客户端
  final client = CozeAPI(
    token: 'pat_xxx',
    baseURL: CozeURLs.comBaseURL,
    config: CozeConfig(
      timeout: Duration(seconds: 60),
      enableLogging: true,
    ),
  );

  // 使用各种 API
  try {
    // Chat
    final chatResult = await client.chat.createAndPoll(...);

    // Bots
    final botList = await client.bots.list(...);

    // Files
    final uploadedFile = await client.files.upload(...);

    // Workflows
    final workflowResult = await client.workflows.run(...);

  } catch (e) {
    print('Error: $e');
  } finally {
    // 关闭客户端
    client.close();
  }
}
```

---

## 相关链接

- [Chat API](chat-api.md)
- [Bots API](bots-api.md)
- [认证方式](../guides/authentication.md)
