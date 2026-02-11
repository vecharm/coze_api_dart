# Coze API Dart SDK

[![pub package](https://img.shields.io/pub/v/coze_api_dart.svg)](https://pub.dev/packages/coze_api_dart)
[![Dart SDK](https://img.shields.io/badge/Dart-3.2%2B-blue.svg)](https://dart.dev)

扣子 (Coze) API 的官方 Dart SDK。支持 Chat 对话、流式响应、WebSocket 实时通信、Bot 管理、工作流、文件上传等完整功能。兼容 Flutter 全平台和纯 Dart 后端。

## 特性

- 🌐 **全平台支持**: 纯 Dart 实现，支持 Flutter iOS/Android/Web/桌面、纯 Dart 后端
- 💬 **完整 Chat API**: 支持普通对话、流式对话、工具调用、多轮对话
- 🔄 **流式响应**: 支持 Server-Sent Events (SSE) 实时响应
- 🔌 **WebSocket 支持**: 实时语音对话、语音合成、语音识别
- 🔐 **多种认证方式**: PAT、OAuth 2.0、JWT、OAuth PKCE、Device Code Flow
- 📦 **文件上传**: 支持图片、文档等多种文件类型
- 🛠️ **Bot 管理**: 创建、配置、发布 Bot
- 🔄 **工作流**: 执行和管理工作流
- 📊 **数据集**: 文档管理和知识库操作
- 🎵 **音频处理**: 语音合成(TTS)、语音识别(STT)、语音克隆
- 🏢 **工作空间**: 多工作空间管理
- 📝 **详细文档**: 完整的中文文档和示例

## 📚 文档

完整文档请访问 [docs/](docs/) 目录：

- [📖 文档首页](docs/README.md) - 文档导航
- [🚀 快速开始](docs/getting-started/quick-start.md) - 5分钟上手
- [📖 功能指南](docs/guides/) - 详细使用指南
- [📋 API 参考](docs/api-reference/) - 完整 API 文档
- [💡 示例代码](docs/examples/) - 各种场景示例

## 安装

```yaml
dependencies:
  coze_api_dart: ^0.1.0
```

## 快速开始

### 1. 初始化客户端

```dart
import 'package:coze_api_dart/coze_api_dart.dart';

final client = CozeAPI(
  token: 'your_pat_token',  // 从 https://www.coze.com/open/oauth/pats 获取
  baseURL: CozeURLs.comBaseURL,  // 或 CozeURLs.cnBaseURL（中国版）
);
```

### 2. 简单对话

```dart
final result = await client.chat.createAndPoll(
  CreateChatRequest(
    botId: 'your_bot_id',
    additionalMessages: [
      Message.user(content: '你好！'),
    ],
  ),
);

print(result.messages.last.content);
```

### 3. 流式对话

```dart
final stream = client.chat.stream(
  CreateChatRequest(
    botId: 'your_bot_id',
    additionalMessages: [
      Message.user(content: '讲一个故事'),
    ],
  ),
);

await for (final event in stream) {
  if (event.event == ChatEventType.conversationMessageDelta) {
    stdout.write(event.data['content']);
  }
}
```

## 功能模块

| 模块 | 说明 | 文档 |
|------|------|------|
| **Chat** | 对话管理 | [chat.md](docs/guides/chat.md) |
| **认证** | 多种认证方式 | [authentication.md](docs/guides/authentication.md) |
| **WebSocket** | 实时通信 | [websocket.md](docs/guides/websocket.md) |
| **音频** | TTS/STT/克隆 | [audio.md](docs/guides/audio.md) |
| **Bots** | Bot 管理 | [bots.md](docs/guides/bots.md) |
| **工作流** | 工作流执行 | [workflows.md](docs/guides/workflows.md) |
| **文件** | 文件上传 | [files.md](docs/guides/files.md) |
| **数据集** | 数据管理 | [datasets.md](docs/guides/datasets.md) |
| **知识库** | 知识库管理 | [knowledge.md](docs/guides/knowledge.md) |
| **会话** | 会话管理 | [conversations.md](docs/guides/conversations.md) |
| **工作空间** | 空间管理 | [workspaces.md](docs/guides/workspaces.md) |
| **变量** | 变量管理 | [variables.md](docs/guides/variables.md) |

## 示例

查看 [example/](example/) 目录获取更多使用示例：

- `chat_example.dart` - Chat API 完整示例
- `stream_example.dart` - 流式对话示例
- `websocket_example.dart` - WebSocket 实时对话示例
- `auth_example.dart` - 各种认证方式示例
- `bot_management_example.dart` - Bot 管理示例
- `workflow_example.dart` - 工作流示例
- `file_upload_example.dart` - 文件上传示例
- `dataset_example.dart` - 数据集示例
- `knowledge_example.dart` - 知识库示例
- `audio_example.dart` - 音频处理示例

## 平台支持

| 平台 | 支持 |
|------|------|
| iOS | ✅ |
| Android | ✅ |
| Web | ✅ |
| macOS | ✅ |
| Windows | ✅ |
| Linux | ✅ |
| 纯 Dart | ✅ |

## 依赖

- `http: ^1.1.0` - HTTP 客户端
- `web_socket_channel: ^2.4.0` - WebSocket 支持
- `http_parser: ^4.0.2` - HTTP 解析

## 许可证

MIT License

## 相关链接

- [📖 完整文档](docs/README.md)
- [Coze 官方文档](https://www.coze.com/docs)
- [Coze 开发者平台](https://www.coze.com/open)
- [GitHub 仓库](https://github.com/vecharm/coze-flutter)

## 贡献

欢迎提交 Issue 和 Pull Request！
