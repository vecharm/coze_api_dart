# WebSocket API 参考

本文档详细介绍 WebSocket API 的所有类和方法。

## WebSocketAPI 类

WebSocket 相关 API 的主类。

### 属性

#### chat → WebSocketChatAPI

WebSocket Chat API。

#### audio → WebSocketAudioAPI

WebSocket 音频 API。

---

## WebSocketChatAPI 类

WebSocket 对话 API。

### 方法

#### create()

创建 WebSocket 对话连接。

```dart
Future<WebSocketChatConnection> create(CreateChatWsRequest request)
```

---

## WebSocketAudioAPI 类

WebSocket 音频 API。

### 属性

#### speech → WebSocketSpeechAPI

WebSocket 语音合成 API。

#### transcriptions → WebSocketTranscriptionsAPI

WebSocket 语音识别 API。

---

## WebSocketSpeechAPI 类

### 方法

#### create()

创建语音合成 WebSocket 连接。

```dart
Future<WebSocketSpeechConnection> create(CreateSpeechRequest request)
```

---

## WebSocketTranscriptionsAPI 类

### 方法

#### create()

创建语音识别 WebSocket 连接。

```dart
Future<WebSocketTranscriptionsConnection> create(CreateTranscriptionsRequest request)
```

---

## 相关链接

- [WebSocket 实时通信指南](../guides/websocket.md) - 使用指南
