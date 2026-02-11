# WebSocket 实时通信指南

本文档详细介绍如何使用 Coze API Dart SDK 的 WebSocket 功能实现实时语音对话、语音合成和语音识别。

## 目录

- [概述](#概述)
- [WebSocket Chat](#websocket-chat)
- [WebSocket 语音合成](#websocket-语音合成)
- [WebSocket 语音识别](#websocket-语音识别)
- [事件处理](#事件处理)
- [最佳实践](#最佳实践)

---

## 概述

WebSocket 提供全双工通信通道，适合实时交互场景：

- **实时对话**: 低延迟的语音/文本对话
- **语音合成**: 实时文本转语音
- **语音识别**: 实时语音转文本

### 特点

| 特性 | 说明 |
|------|------|
| 实时性 | 毫秒级延迟 |
| 双向通信 | 同时发送和接收 |
| 流式处理 | 边接收边处理 |
| 低带宽 | 比 HTTP 轮询更高效 |

---

## WebSocket Chat

### 基础用法

```dart
import 'package:coze_api_dart/coze_api_dart.dart';

void main() async {
  final client = CozeAPI(
    token: 'your_pat_token',
    baseURL: CozeURLs.comBaseURL,
  );

  // 创建 WebSocket 连接
  final ws = await client.websocket.chat.create(
    CreateChatWsRequest(
      botId: 'your_bot_id',
      voiceId: 'your_voice_id',  // 可选：语音 ID
    ),
  );

  // 监听事件
  ws.events.listen((event) {
    switch (event.eventType) {
      case WebsocketsEventType.conversationChatCreated:
        print('对话已创建');
        break;

      case WebsocketsEventType.conversationMessageDelta:
        // 文本增量
        stdout.write(event.data['content']);
        break;

      case WebsocketsEventType.conversationAudioDelta:
        // 音频数据
        final audioData = base64Decode(event.data['audio']);
        playAudio(audioData);  // 播放音频
        break;

      case WebsocketsEventType.error:
        print('错误: ${event.data}');
        break;
    }
  });

  // 发送文本消息
  ws.sendText('你好，请介绍一下自己');

  // 发送音频（语音输入）
  final audioData = await recordAudio();
  ws.sendAudio(audioData);
}
```

### 完整实时对话示例

```dart
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:coze_api_dart/coze_api_dart.dart';

class RealtimeChat {
  final CozeAPI client;
  WebSocketChatConnection? _connection;
  final _audioBuffer = BytesBuilder();

  RealtimeChat({required this.client});

  Future<void> connect({
    required String botId,
    String? voiceId,
    String? conversationId,
  }) async {
    _connection = await client.websocket.chat.create(
      CreateChatWsRequest(
        botId: botId,
        voiceId: voiceId,
        conversationId: conversationId,
      ),
    );

    _connection!.events.listen(
      _handleEvent,
      onError: (error) => print('WebSocket 错误: $error'),
      onDone: () => print('WebSocket 连接关闭'),
    );
  }

  void _handleEvent(ChatWsEvent event) {
    switch (event.eventType) {
      case WebsocketsEventType.conversationChatCreated:
        print('✅ 对话已创建: ${event.data['id']}');
        break;

      case WebsocketsEventType.conversationMessageCreated:
        print('🤖 Bot 开始回复...');
        break;

      case WebsocketsEventType.conversationMessageDelta:
        final content = event.data['content'] as String?;
        if (content != null) {
          stdout.write(content);
        }
        break;

      case WebsocketsEventType.conversationMessageCompleted:
        print('\n✅ 消息完成');
        break;

      case WebsocketsEventType.conversationAudioDelta:
        // 接收音频增量
        final audioBase64 = event.data['audio'] as String?;
        if (audioBase64 != null) {
          final audioData = base64Decode(audioBase64);
          _audioBuffer.add(audioData);
        }
        break;

      case WebsocketsEventType.conversationAudioCompleted:
        // 音频完成，播放
        final completeAudio = _audioBuffer.toBytes();
        _audioBuffer.clear();
        playAudio(completeAudio);
        break;

      case WebsocketsEventType.inputAudioBufferSpeechStarted:
        print('🎤 检测到语音开始');
        break;

      case WebsocketsEventType.inputAudioBufferSpeechStopped:
        print('🎤 语音结束');
        break;

      case WebsocketsEventType.error:
        print('❌ 错误: ${event.data['error']}');
        break;

      default:
        print('事件: ${event.eventType}');
    }
  }

  void sendText(String text) {
    _connection?.sendText(text);
  }

  void sendAudio(Uint8List audioData) {
    _connection?.sendAudio(audioData);
  }

  void close() {
    _connection?.close();
    _connection = null;
  }
}

void main() async {
  final client = CozeAPI(
    token: 'your_pat_token',
    baseURL: CozeURLs.comBaseURL,
  );

  final chat = RealtimeChat(client: client);

  await chat.connect(
    botId: 'your_bot_id',
    voiceId: 'your_voice_id',
  );

  // 发送消息
  chat.sendText('你好！');

  // 保持程序运行
  await Future.delayed(Duration(minutes: 5));

  chat.close();
}
```

---

## WebSocket 语音合成

### 实时文本转语音

```dart
import 'dart:convert';
import 'package:coze_api_dart/coze_api_dart.dart';

void main() async {
  final client = CozeAPI(
    token: 'your_pat_token',
    baseURL: CozeURLs.comBaseURL,
  );

  // 创建语音合成 WebSocket
  final speech = await client.websocket.audio.speech.create(
    CreateSpeechRequest(
      entityType: 'bot',
      entityId: 'your_bot_id',
    ),
  );

  final audioChunks = <Uint8List>[];

  // 监听音频输出
  speech.events.listen((event) {
    switch (event.eventType) {
      case WebsocketsEventType.conversationAudioCompleted:
        // 接收音频数据
        final audioBase64 = event.data['audio'] as String?;
        if (audioBase64 != null) {
          audioChunks.add(base64Decode(audioBase64));
        }
        break;

      case WebsocketsEventType.conversationTtsMessageUpdate:
        // TTS 文本更新
        print('合成文本: ${event.data['text']}');
        break;

      case WebsocketsEventType.conversationChatCreated:
        print('语音合成会话已创建');
        break;

      case WebsocketsEventType.error:
        print('错误: ${event.data}');
        break;
    }
  });

  // 方式1：直接发送完整文本
  speech.sendTextUpdate('你好，这是一个语音合成测试。');

  // 方式2：流式发送文本（打字机效果）
  final text = '这是逐字发送的文本';
  for (final char in text.split('')) {
    speech.appendTextBuffer(char);
    await Future.delayed(Duration(milliseconds: 100));
  }
  speech.completeTextBuffer();

  // 等待音频接收完成
  await Future.delayed(Duration(seconds: 3));

  // 合并并播放音频
  final completeAudio = Uint8List.fromList(
    audioChunks.expand((e) => e).toList(),
  );
  await playAudio(completeAudio);

  speech.close();
}
```

### 语音合成事件处理

```dart
class SpeechSynthesizer {
  final WebSocketSpeechConnection _connection;
  final _audioBuffer = BytesBuilder();
  Completer<Uint8List>? _completer;

  SpeechSynthesizer(this._connection) {
    _connection.events.listen(_handleEvent);
  }

  void _handleEvent(SpeechEvent event) {
    switch (event.eventType) {
      case WebsocketsEventType.conversationChatCreated:
        print('🎵 语音合成已启动');
        break;

      case WebsocketsEventType.conversationAudioCompleted:
        final audioBase64 = event.data['audio'] as String?;
        if (audioBase64 != null) {
          _audioBuffer.add(base64Decode(audioBase64));
        }
        break;

      case WebsocketsEventType.conversationTtsMessageUpdate:
        // 可以在这里获取合成进度
        final text = event.data['text'] as String?;
        print('📝 合成进度: $text');
        break;

      case WebsocketsEventType.conversationChatCompleted:
        // 所有音频接收完成
        final completeAudio = _audioBuffer.toBytes();
        _audioBuffer.clear();
        _completer?.complete(completeAudio);
        break;

      case WebsocketsEventType.error:
        _completer?.completeError(event.data['error']);
        break;

      default:
        break;
    }
  }

  Future<Uint8List> synthesize(String text) async {
    _completer = Completer<Uint8List>();

    // 发送文本
    _connection.sendTextUpdate(text);

    // 等待完成
    return await _completer!.future;
  }

  void close() => _connection.close();
}
```

---

## WebSocket 语音识别

### 实时语音转文本

```dart
import 'dart:typed_data';
import 'package:coze_api_dart/coze_api_dart.dart';

void main() async {
  final client = CozeAPI(
    token: 'your_pat_token',
    baseURL: CozeURLs.comBaseURL,
  );

  // 创建语音识别 WebSocket
  final transcription = await client.websocket.audio.transcriptions.create(
    CreateTranscriptionsRequest(
      entityType: 'bot',
      entityId: 'your_bot_id',
    ),
  );

  final recognizedText = StringBuffer();

  // 监听识别结果
  transcription.events.listen((event) {
    switch (event.eventType) {
      case WebsocketsEventType.conversationSpeechToTextUpdated:
        // 增量识别结果
        final delta = event.data['delta'] as String?;
        if (delta != null) {
          recognizedText.write(delta);
          print('识别中: $recognizedText');
        }
        break;

      case WebsocketsEventType.conversationSpeechToTextCompleted:
        // 最终识别结果
        final text = event.data['text'] as String?;
        print('✅ 最终识别: $text');
        recognizedText.clear();
        break;

      case WebsocketsEventType.inputAudioBufferCompleted:
        print('🎤 音频输入完成');
        break;

      case WebsocketsEventType.inputAudioBufferCleared:
        print('🗑️ 音频缓冲区已清除');
        recognizedText.clear();
        break;

      case WebsocketsEventType.error:
        print('❌ 错误: ${event.data}');
        break;
    }
  });

  // 模拟音频输入（实际应从麦克风获取）
  final audioStream = getMicrophoneStream();

  await for (final audioChunk in audioStream) {
    // 发送音频数据
    transcription.appendAudioBuffer(audioChunk);
  }

  // 标记音频输入完成
  transcription.completeAudioBuffer();

  // 等待识别完成
  await Future.delayed(Duration(seconds: 2));

  transcription.close();
}

// 模拟麦克风音频流
Stream<Uint8List> getMicrophoneStream() async* {
  // 实际实现应使用 record 或 mic_stream 等包
  // 这里仅作示例
  for (int i = 0; i < 100; i++) {
    yield Uint8List(1024);  // 音频数据块
    await Future.delayed(Duration(milliseconds: 20));
  }
}
```

### 语音识别控制器

```dart
class SpeechRecognizer {
  WebSocketTranscriptionsConnection? _connection;
  final _recognizedText = StringBuffer();
  final _textController = StreamController<String>.broadcast();

  Stream<String> get textStream => _textController.stream;

  Future<void> start({
    required String entityType,
    required String entityId,
  }) async {
    final client = CozeAPI(/* ... */);

    _connection = await client.websocket.audio.transcriptions.create(
      CreateTranscriptionsRequest(
        entityType: entityType,
        entityId: entityId,
      ),
    );

    _connection!.events.listen(_handleEvent);
  }

  void _handleEvent(TranscriptionEvent event) {
    switch (event.eventType) {
      case WebsocketsEventType.conversationSpeechToTextUpdated:
        final delta = event.data['delta'] as String? ?? '';
        _recognizedText.write(delta);
        _textController.add(_recognizedText.toString());
        break;

      case WebsocketsEventType.conversationSpeechToTextCompleted:
        final text = event.data['text'] as String? ?? '';
        _textController.add('[完成] $text');
        _recognizedText.clear();
        break;

      default:
        break;
    }
  }

  void sendAudio(Uint8List audioData) {
    _connection?.appendAudioBuffer(audioData);
  }

  void stop() {
    _connection?.completeAudioBuffer();
  }

  void clear() {
    _connection?.clearAudioBuffer();
    _recognizedText.clear();
  }

  void dispose() {
    _connection?.close();
    _textController.close();
  }
}
```

---

## 事件处理

### 所有 WebSocket 事件类型

```dart
enum WebsocketsEventType {
  // 对话相关
  conversationChatCreated,      // 对话创建
  conversationChatInProgress,   // 对话进行中
  conversationChatCompleted,    // 对话完成
  conversationChatFailed,       // 对话失败
  conversationChatRequiresAction, // 需要操作

  // 消息相关
  conversationMessageCreated,   // 消息创建
  conversationMessageDelta,     // 消息增量
  conversationMessageCompleted, // 消息完成
  conversationMessageInProgress, // 消息进行中

  // 音频相关
  conversationAudioDelta,       // 音频增量
  conversationAudioCompleted,   // 音频完成
  conversationTtsMessageUpdate, // TTS 更新

  // 语音识别相关
  conversationSpeechToTextUpdated,   // STT 更新
  conversationSpeechToTextCompleted, // STT 完成

  // 输入音频相关
  inputAudioBufferCompleted,    // 音频输入完成
  inputAudioBufferCleared,      // 音频缓冲区清除
  inputAudioBufferSpeechStarted, // 检测到语音开始
  inputAudioBufferSpeechStopped, // 检测到语音结束

  // 错误
  error,
  done,
}
```

### 事件数据结构

```dart
// 对话创建事件
event.data = {
  'id': 'conversation_id',
  'bot_id': 'bot_id',
  'created_at': 1234567890,
};

// 消息增量事件
event.data = {
  'id': 'message_id',
  'role': 'assistant',
  'content': '增量文本',
  'content_type': 'text',
};

// 音频增量事件
event.data = {
  'audio': 'base64_encoded_audio_data',
  'format': 'pcm',
  'sample_rate': 24000,
};

// 语音识别更新事件
event.data = {
  'delta': '增量文本',
  'text': '当前完整文本',
};

// 错误事件
event.data = {
  'error': '错误信息',
  'code': 'error_code',
};
```

---

## 最佳实践

### 1. 连接管理

```dart
class WebSocketManager {
  WebSocketConnection? _connection;
  Timer? _pingTimer;
  bool _isReconnecting = false;

  Future<void> connect() async {
    _connection = await createConnection();

    // 设置心跳
    _pingTimer = Timer.periodic(Duration(seconds: 30), (_) {
      _connection?.ping();
    });

    // 监听连接关闭
    _connection!.events.listen(
      (event) {},
      onDone: () {
        _pingTimer?.cancel();
        if (!_isReconnecting) {
          _reconnect();
        }
      },
    );
  }

  Future<void> _reconnect() async {
    _isReconnecting = true;
    print('连接断开，正在重连...');

    await Future.delayed(Duration(seconds: 3));
    await connect();

    _isReconnecting = false;
  }

  void disconnect() {
    _pingTimer?.cancel();
    _connection?.close();
  }
}
```

### 2. 音频数据处理

```dart
class AudioProcessor {
  // 音频格式转换
  Uint8List convertToPCM16(Uint8List input, int sampleRate) {
    // 实现音频格式转换
    // 例如：从 Float32 转换为 Int16
    return input;
  }

  // 音频缓冲
  final _buffer = BytesBuilder();
  static const chunkSize = 3200;  // 100ms @ 16kHz, 16bit, mono

  void addAudio(Uint8List data) {
    _buffer.add(data);

    // 发送固定大小的块
    while (_buffer.length >= chunkSize) {
      final chunk = Uint8List.sublistView(
        Uint8List.fromList(_buffer.toBytes()),
        0,
        chunkSize,
      );
      sendAudioChunk(chunk);

      // 移除已发送的数据
      final remaining = _buffer.toBytes().sublist(chunkSize);
      _buffer.clear();
      _buffer.add(remaining);
    }
  }

  void flush() {
    if (_buffer.isNotEmpty) {
      sendAudioChunk(_buffer.toBytes());
      _buffer.clear();
    }
  }
}
```

### 3. 错误处理

```dart
void handleWebSocketError(dynamic error) {
  if (error is WebSocketException) {
    print('WebSocket 错误: ${error.message}');

    switch (error.code) {
      case 'CONNECTION_REFUSED':
        print('连接被拒绝，检查网络');
        break;
      case 'AUTHENTICATION_FAILED':
        print('认证失败，检查令牌');
        break;
      case 'RATE_LIMITED':
        print('请求过于频繁，稍后重试');
        break;
      default:
        print('未知错误: ${error.code}');
    }
  } else {
    print('其他错误: $error');
  }
}
```

### 4. Flutter 集成

```dart
class VoiceChatPage extends StatefulWidget {
  @override
  _VoiceChatPageState createState() => _VoiceChatPageState();
}

class _VoiceChatPageState extends State<VoiceChatPage> {
  RealtimeChat? _chat;
  bool _isConnected = false;
  bool _isListening = false;
  String _status = '点击开始';

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  Future<void> _initChat() async {
    final client = CozeAPI(
      token: 'your_pat_token',
      baseURL: CozeURLs.comBaseURL,
    );

    _chat = RealtimeChat(client: client);

    await _chat!.connect(
      botId: 'your_bot_id',
      voiceId: 'your_voice_id',
    );

    setState(() {
      _isConnected = true;
      _status = '已连接，点击说话';
    });
  }

  void _toggleListening() {
    setState(() {
      _isListening = !_isListening;
      _status = _isListening ? '正在听...' : '已暂停';
    });

    if (_isListening) {
      _startRecording();
    } else {
      _stopRecording();
    }
  }

  void _startRecording() {
    // 开始录音并发送到 WebSocket
    // 使用 record 包或其他录音库
  }

  void _stopRecording() {
    // 停止录音
  }

  @override
  void dispose() {
    _chat?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('语音对话')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_status),
            SizedBox(height: 20),
            FloatingActionButton(
              onPressed: _isConnected ? _toggleListening : null,
              child: Icon(_isListening ? Icons.mic : Icons.mic_none),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 常见问题

### Q: WebSocket 连接失败怎么办？

A: 检查以下几点：

```dart
// 1. 检查令牌
if (!isPersonalAccessToken(token)) {
  print('令牌格式不正确');
}

// 2. 检查网络
final client = CozeAPI(
  token: token,
  baseURL: CozeURLs.comBaseURL,
  config: CozeConfig(
    timeout: Duration(seconds: 30),
    enableLogging: true,  // 启用日志查看详情
  ),
);

// 3. 检查 Bot ID
// 确保 Bot 已发布且有 WebSocket 权限
```

### Q: 音频延迟高怎么办？

A: 优化音频处理：

```dart
// 1. 使用较小的音频块
const chunkDuration = Duration(milliseconds: 20);

// 2. 减少音频格式转换
// 直接使用 PCM 16bit, 16kHz, mono

// 3. 启用 opus 压缩（如果支持）
```

### Q: 如何实现语音唤醒？

A: 结合 VAD（语音活动检测）：

```dart
// 使用 vad 包检测语音
import 'package:vad/vad.dart';

final vad = VAD.create(
  mode: VADMode.aggressive,
  sampleRate: 16000,
);

vad.onSpeechStart = () {
  print('🎤 检测到语音');
  _chat?.startListening();
};

vad.onSpeechEnd = () {
  print('🎤 语音结束');
  _chat?.stopListening();
};
```

---

## 下一步

- [音频处理指南](audio.md) - 了解更多音频功能
- [错误处理](../advanced/error-handling.md) - 错误处理最佳实践
- [性能优化](../advanced/performance.md) - 优化实时性能
