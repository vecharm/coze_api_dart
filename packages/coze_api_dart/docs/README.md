# Coze API Dart SDK 文档

欢迎来到 Coze API Dart SDK 的官方文档！本文档提供完整的 API 参考和使用指南，帮助你快速上手并充分利用 SDK 的所有功能。

## 📚 文档导航

### 🚀 入门指南

| 文档 | 描述 |
|------|------|
| [安装指南](getting-started/installation.md) | 环境要求、依赖配置、版本兼容性 |
| [快速开始](getting-started/quick-start.md) | 5 分钟快速上手，完成第一个对话 |
| [配置说明](getting-started/configuration.md) | 客户端配置、超时设置、调试模式 |

### 📖 功能指南

#### 核心功能
| 文档 | 描述 |
|------|------|
| [认证方式](guides/authentication.md) | PAT、OAuth、JWT 等所有认证方式详解 |
| [Chat 对话](guides/chat.md) | 普通对话、多轮对话、工具调用 |
| [流式响应](guides/streaming.md) | SSE 流式对话实现 |
| [WebSocket 实时通信](guides/websocket.md) | 实时语音对话、语音合成、语音识别 |

#### Bot 与工作流
| 文档 | 描述 |
|------|------|
| [Bot 管理](guides/bots.md) | 创建、配置、发布 Bot |
| [工作流](guides/workflows.md) | 执行和管理工作流 |

#### 数据与文件
| 文档 | 描述 |
|------|------|
| [文件上传](guides/files.md) | 图片、文档等文件上传 |
| [数据集管理](guides/datasets.md) | 数据集和文档管理 |
| [知识库管理](guides/knowledge.md) | 知识库文档操作 |

#### 音频处理
| 文档 | 描述 |
|------|------|
| [音频处理](guides/audio.md) | 语音合成(TTS)、语音识别(STT)、语音克隆 |

#### 其他功能
| 文档 | 描述 |
|------|------|
| [会话管理](guides/conversations.md) | 会话和消息管理 |
| [工作空间](guides/workspaces.md) | 工作空间操作 |
| [变量管理](guides/variables.md) | Bot 变量管理 |

### 📋 API 参考

#### 核心 API
| 文档 | 描述 |
|------|------|
| [CozeClient](api-reference/client.md) | 客户端主类 |
| [Chat API](api-reference/chat-api.md) | 对话相关 API |
| [Bots API](api-reference/bots-api.md) | Bot 管理 API |
| [Workflows API](api-reference/workflows-api.md) | 工作流 API |

#### 数据与文件 API
| 文档 | 描述 |
|------|------|
| [Datasets API](api-reference/datasets-api.md) | 数据集 API |
| [Knowledge API](api-reference/knowledge-api.md) | 知识库 API |
| [Files API](api-reference/files-api.md) | 文件 API |

#### 音频 API
| 文档 | 描述 |
|------|------|
| [Voice API](api-reference/voice-api.md) | 语音合成/识别 API |
| [Audio API](api-reference/audio-api.md) | 音频处理 API |
| [WebSocket API](api-reference/websocket-api.md) | WebSocket 相关 API |

#### 其他 API
| 文档 | 描述 |
|------|------|
| [Conversations API](api-reference/conversations-api.md) | 会话 API |
| [Workspaces API](api-reference/workspaces-api.md) | 工作空间 API |
| [Variables API](api-reference/variables-api.md) | 变量 API |
| [Templates API](api-reference/templates-api.md) | 模板 API |
| [Users API](api-reference/users-api.md) | 用户 API |

#### 基础组件
| 文档 | 描述 |
|------|------|
| [认证类](api-reference/auth.md) | 所有认证方式类参考 |
| [数据模型](api-reference/models.md) | 请求/响应模型 |
| [枚举类型](api-reference/enums.md) | 所有枚举定义 |
| [异常处理](api-reference/exceptions.md) | 异常类参考 |
| [工具函数](api-reference/utils.md) | 工具函数参考 |

### 💡 示例代码

| 文档 | 描述 |
|------|------|
| [完整示例合集](examples/complete-examples.md) | 各种场景的完整示例 |
| [Flutter 示例](examples/flutter-example.md) | Flutter 应用完整示例 |
| [服务端示例](examples/server-example.md) | Dart 服务端示例 |

### 🔧 高级主题

| 文档 | 描述 |
|------|------|
| [错误处理](advanced/error-handling.md) | 错误处理最佳实践 |
| [重试策略](advanced/retry-policy.md) | 配置重试机制 |
| [请求取消](advanced/cancellation.md) | 取消正在进行的请求 |
| [日志配置](advanced/logging.md) | 日志记录和调试 |
| [性能优化](advanced/performance.md) | 性能优化建议 |

## 🎯 快速开始

### 安装

```yaml
dependencies:
  coze_api_dart: ^0.1.0
```

### 第一个对话

```dart
import 'package:coze_api_dart/coze_api_dart.dart';

void main() async {
  // 初始化客户端
  final client = CozeAPI(
    token: 'your_pat_token',
    baseURL: CozeURLs.comBaseURL,
  );

  // 发起对话
  final result = await client.chat.createAndPoll(
    CreateChatRequest(
      botId: 'your_bot_id',
      additionalMessages: [
        Message.user(content: '你好！'),
      ],
    ),
  );

  print(result.messages.last.content);
}
```

## 📦 版本信息

- **当前版本**: 0.1.0
- **Dart SDK**: >=3.2.0
- **Flutter**: 支持全平台

## 🔗 相关链接

- [Coze 官方文档](https://www.coze.com/docs)
- [Coze 开发者平台](https://www.coze.com/open)


## 📝 许可证

MIT License
