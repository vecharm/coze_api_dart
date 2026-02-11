# 音频处理指南

本文档详细介绍如何使用 Coze API Dart SDK 进行音频处理，包括语音合成（TTS）、语音识别（STT）、语音克隆等功能。

## 目录

- [概述](#概述)
- [语音合成 (TTS)](#语音合成-tts)
- [语音识别 (STT)](#语音识别-stt)
- [语音克隆](#语音克隆)
- [音频房间](#音频房间)
- [声纹管理](#声纹管理)
- [最佳实践](#最佳实践)

---

## 概述

Coze API Dart SDK 提供完整的音频处理能力：

| 功能 | 说明 | 适用场景 |
|------|------|----------|
| **语音合成 (TTS)** | 文本转语音 | 语音播报、智能客服 |
| **语音识别 (STT)** | 语音转文本 | 语音输入、语音助手 |
| **语音克隆** | 克隆特定音色 | 个性化语音 |
| **音频房间** | 实时音频通话 | 语音通话、直播 |
| **声纹管理** | 声纹识别 | 身份验证 |

---

## 语音合成 (TTS)

### 基础语音合成

```dart
import 'dart:io';
import 'package:coze_api_dart/coze_api_dart.dart';

void main() async {
  final client = CozeAPI(
    token: 'your_pat_token',
    baseURL: CozeURLs.comBaseURL,
  );

  // 语音合成
  final response = await client.voice.speech.create(
    VoiceSpeechRequest(
      input: '你好，这是语音合成测试。',
      voiceId: 'your_voice_id',
      responseFormat: VoiceFormat.mp3,
    ),
  );

  // 保存音频文件
  final file = File('output.mp3');
  await file.writeAsBytes(response.data);

  print('音频已保存: ${file.path}');
}
```

### 流式语音合成

```dart
import 'dart:io';
import 'package:coze_api_dart/coze_api_dart.dart';

void main() async {
  final client = CozeAPI(
    token: 'your_pat_token',
    baseURL: CozeURLs.comBaseURL,
  );

  // 创建流式合成请求
  final stream = client.voice.speech.stream(
    VoiceSpeechRequest(
      input: '这是一段很长的文本，需要流式合成...',
      voiceId: 'your_voice_id',
      responseFormat: VoiceFormat.pcm,
      sampleRate: 24000,
    ),
  );

  final audioChunks = <List<int>>[];

  await for (final chunk in stream) {
    audioChunks.add(chunk);
    print('接收音频块: ${chunk.length} bytes');
  }

  // 合并音频数据
  final completeAudio = audioChunks.expand((e) => e).toList();

  // 保存
  final file = File('output.pcm');
  await file.writeAsBytes(completeAudio);
}
```

### 长文本语音合成

```dart
import 'package:coze_api_dart/coze_api_dart.dart';

class LongTextTTS {
  final CozeAPI client;
  static const maxChunkLength = 500;  // 每次最大字符数

  LongTextTTS(this.client);

  Future<List<int>> synthesizeLongText(
    String text, {
    required String voiceId,
  }) async {
    // 分割长文本
    final chunks = _splitText(text, maxChunkLength);
    final audioChunks = <List<int>>[];

    for (var i = 0; i < chunks.length; i++) {
      print('合成第 ${i + 1}/${chunks.length} 段...');

      final response = await client.voice.speech.create(
        VoiceSpeechRequest(
          input: chunks[i],
          voiceId: voiceId,
          responseFormat: VoiceFormat.mp3,
        ),
      );

      audioChunks.add(response.data);
    }

    // 合并音频（注意：MP3 需要特殊处理）
    return audioChunks.expand((e) => e).toList();
  }

  List<String> _splitText(String text, int maxLength) {
    final chunks = <String>[];
    var currentChunk = StringBuffer();

    for (final sentence in text.split(RegExp(r'(?<=[。！？.!?])'))) {
      if (currentChunk.length + sentence.length > maxLength) {
        if (currentChunk.isNotEmpty) {
          chunks.add(currentChunk.toString());
          currentChunk.clear();
        }
      }
      currentChunk.write(sentence);
    }

    if (currentChunk.isNotEmpty) {
      chunks.add(currentChunk.toString());
    }

    return chunks;
  }
}
```

### 语音参数设置

```dart
final response = await client.voice.speech.create(
  VoiceSpeechRequest(
    input: '你好',
    voiceId: 'your_voice_id',
    responseFormat: VoiceFormat.mp3,  // mp3, wav, pcm, ogg
    sampleRate: 24000,  // 16000, 24000, 48000
    speed: 1.0,  // 语速：0.5-2.0
    volume: 1.0,  // 音量：0.0-2.0
  ),
);
```

---

## 语音识别 (STT)

### 短语音识别

```dart
import 'dart:io';
import 'package:coze_api_dart/coze_api_dart.dart';

void main() async {
  final client = CozeAPI(
    token: 'your_pat_token',
    baseURL: CozeURLs.comBaseURL,
  );

  // 读取音频文件
  final audioFile = File('input.mp3');
  final audioData = await audioFile.readAsBytes();

  // 语音识别
  final result = await client.voice.transcriptions.create(
    VoiceTranscriptionsRequest(
      file: audioData,
      fileName: 'input.mp3',
      language: 'zh',  // 语言代码
    ),
  );

  print('识别结果: ${result.text}');
}
```

### 带时间戳的识别

```dart
final result = await client.voice.transcriptions.create(
  VoiceTranscriptionsRequest(
    file: audioData,
    fileName: 'input.mp3',
    language: 'zh',
    timestampGranularities: ['word', 'segment'],  // 时间戳粒度
  ),
);

// 输出带时间戳的结果
for (final segment in result.segments) {
  print('${segment.startTime}s - ${segment.endTime}s: ${segment.text}');
}
```

### 实时语音识别

使用 WebSocket 实现实时语音识别：

```dart
import 'dart:async';
import 'dart:typed_data';
import 'package:coze_api_dart/coze_api_dart.dart';

class RealtimeSTT {
  WebSocketTranscriptionsConnection? _connection;
  final _textController = StreamController<String>.broadcast();

  Stream<String> get textStream => _textController.stream;

  Future<void> start() async {
    final client = CozeAPI(/* ... */);

    _connection = await client.websocket.audio.transcriptions.create();

    _connection!.events.listen((event) {
      switch (event.eventType) {
        case WebsocketsEventType.conversationSpeechToTextUpdated:
          final text = event.data['text'] as String?;
          if (text != null) {
            _textController.add(text);
          }
          break;

        case WebsocketsEventType.conversationSpeechToTextCompleted:
          final text = event.data['text'] as String?;
          _textController.add('[完成] $text');
          break;

        default:
          break;
      }
    });
  }

  void sendAudio(Uint8List audioData) {
    _connection?.appendAudioBuffer(audioData);
  }

  void stop() {
    _connection?.completeAudioBuffer();
  }

  void dispose() {
    _connection?.close();
    _textController.close();
  }
}
```

---

## 语音克隆

### 克隆语音

```dart
import 'dart:io';
import 'package:coze_api_dart/coze_api_dart.dart';

void main() async {
  final client = CozeAPI(
    token: 'your_pat_token',
    baseURL: CozeURLs.comBaseURL,
  );

  // 读取音频样本
  final sampleFile = File('voice_sample.mp3');
  final sampleData = await sampleFile.readAsBytes();

  // 克隆语音
  final result = await client.audio.voices.clone(
    CloneVoiceRequest(
      voiceName: '我的克隆声音',
      file: base64Encode(sampleData),
      audioFormat: 'mp3',
      language: 'zh',
      previewText: '你好，这是克隆的声音。',
    ),
  );

  print('克隆成功！语音 ID: ${result.voiceId}');
}
```

### 列出可用语音

```dart
final voices = await client.audio.voices.list(
  ListVoicesRequest(
    modelType: 'tts',  // 筛选 TTS 语音
    filterSystemVoice: false,  // 包含系统语音
    pageNum: 1,
    pageSize: 100,
  ),
);

for (final voice in voices.voiceList) {
  print('名称: ${voice.name}');
  print('ID: ${voice.voiceId}');
  print('语言: ${voice.languageName}');
  print('预览: ${voice.previewAudio}');
  print('---');
}
```

---

## 音频房间

### 创建音频房间

```dart
final room = await client.audio.rooms.create(
  CreateRoomRequest(
    botId: 'your_bot_id',
    connectorId: 'your_connector_id',
    voiceId: 'your_voice_id',
    config: RoomConfig(
      roomMode: RoomMode.s2s,  // 端到端模式
      turnDetection: TurnDetectionConfig(
        type: TurnDetectionType.serverVad,
      ),
    ),
  ),
);

print('房间 ID: ${room.roomId}');
print('Token: ${room.token}');
print('UID: ${room.uid}');
```

### 加入音频房间

```dart
// 使用返回的 token 和房间信息加入 RTC 房间
// 需要配合 RTC SDK（如声网 Agora）使用

final agoraEngine = createAgoraEngine();
await agoraEngine.joinChannel(
  token: room.token,
  channelId: room.roomId,
  uid: int.parse(room.uid),
);
```

---

## 声纹管理

### 创建声纹特征

```dart
import 'dart:io';
import 'package:coze_api_dart/coze_api_dart.dart';

void main() async {
  final client = CozeAPI(
    token: 'your_pat_token',
    baseURL: CozeURLs.comBaseURL,
  );

  // 读取音频样本
  final audioFile = File('speaker_sample.wav');
  final audioData = await audioFile.readAsBytes();

  // 创建声纹特征
  final result = await client.audio.voiceprint.createFeature(
    'voiceprint_group_id',
    CreateVoiceprintFeatureRequest(
      file: base64Encode(audioData),
      name: '张三的声纹',
      desc: '用于身份验证',
    ),
  );

  print('声纹特征创建成功: ${result.id}');
}
```

### 说话人识别

```dart
// 识别说话人
final identifyResult = await client.audio.voiceprint.speakerIdentify(
  'voiceprint_group_id',
  SpeakerIdentifyRequest(
    file: base64Encode(audioData),
    topK: 3,  // 返回前3个最匹配的结果
  ),
);

for (final score in identifyResult.featureScoreList) {
  print('特征: ${score.featureName}');
  print('匹配度: ${score.score}');
  print('---');
}
```

### 管理声纹特征

```dart
// 列出声纹特征
final features = await client.audio.voiceprint.listFeatures(
  'voiceprint_group_id',
  ListVoiceprintFeatureRequest(
    pageNum: 1,
    pageSize: 50,
  ),
);

// 更新声纹特征
await client.audio.voiceprint.updateFeature(
  'voiceprint_group_id',
  'feature_id',
  UpdateVoiceprintFeatureRequest(
    name: '新名称',
    desc: '新描述',
  ),
);

// 删除声纹特征
await client.audio.voiceprint.deleteFeature(
  'voiceprint_group_id',
  'feature_id',
);
```

---

## 最佳实践

### 1. 音频格式选择

```dart
// 语音合成
// - MP3: 通用格式，文件小
// - WAV: 无损格式，音质好
// - PCM: 原始数据，适合实时处理

// 语音识别
// - 推荐: MP3, WAV, PCM
// - 采样率: 16kHz 或更高
// - 声道: 单声道
```

### 2. 音频预处理

```dart
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';

Future<List<int>> preprocessAudio(String inputPath) async {
  final outputPath = '${inputPath}_processed.wav';

  // 转换为标准格式
  await FFmpegKit.execute(
    '-i $inputPath '
    '-ar 16000 '  // 采样率 16kHz
    '-ac 1 '      // 单声道
    '-acodec pcm_s16le '  // 16bit PCM
    '$outputPath',
  );

  return await File(outputPath).readAsBytes();
}
```

### 3. 错误处理

```dart
Future<void> safeTTS(String text) async {
  try {
    final result = await client.voice.speech.create(
      VoiceSpeechRequest(
        input: text,
        voiceId: voiceId,
      ),
    );

    await playAudio(result.data);
  } on CozeException catch (e) {
    if (e.code == 'VOICE_NOT_FOUND') {
      print('语音 ID 不存在');
    } else if (e.code == 'TEXT_TOO_LONG') {
      print('文本过长，请分段处理');
    } else {
      print('TTS 错误: ${e.message}');
    }
  }
}
```

### 4. 缓存策略

```dart
class TTSCache {
  final _cache = <String, List<int>>{};
  final maxCacheSize = 50;  // 最大缓存数量

  Future<List<int>> getOrCreate(
    String text,
    String voiceId,
    Future<List<int>> Function() create,
  ) async {
    final key = '${voiceId}_$text';

    if (_cache.containsKey(key)) {
      return _cache[key]!;
    }

    final audio = await create();

    // 缓存管理
    if (_cache.length >= maxCacheSize) {
      _cache.remove(_cache.keys.first);
    }
    _cache[key] = audio;

    return audio;
  }
}
```

---

## 常见问题

### Q: 语音合成支持哪些语言？

A: 支持中文、英文、日文等多种语言，具体取决于语音 ID 的配置。

### Q: 如何提高语音识别准确率？

A: 
1. 使用高质量麦克风
2. 减少背景噪音
3. 使用合适的采样率（16kHz+）
4. 选择合适的语言参数

### Q: 语音克隆需要多长的音频样本？

A: 通常需要 10-30 秒的清晰语音样本，越长效果越好。

---

## 下一步

- [WebSocket 实时通信](websocket.md) - 实时音频处理
- [错误处理](../advanced/error-handling.md) - 错误处理最佳实践
