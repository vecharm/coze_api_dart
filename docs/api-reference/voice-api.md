# Voice API 参考

本文档详细介绍 Voice API（语音合成/识别）的所有类和方法。

## VoiceAPI 类

语音相关 API 的主类。

### 属性

#### speech → VoiceSpeechAPI

语音合成 API。

```dart
final speechAPI = client.voice.speech;
```

#### transcriptions → VoiceTranscriptionsAPI

语音识别 API。

```dart
final transcriptionsAPI = client.voice.transcriptions;
```

---

## VoiceSpeechAPI 类

语音合成 API。

### 方法

#### create()

语音合成。

```dart
Future<VoiceSpeechResponse> create(VoiceSpeechRequest request)
```

**参数：**

| 参数 | 类型 | 说明 |
|------|------|------|
| `request` | `VoiceSpeechRequest` | 合成请求 |

**返回：** `VoiceSpeechResponse` - 合成结果

**示例：**

```dart
final response = await client.voice.speech.create(
  VoiceSpeechRequest(
    input: '你好，这是语音合成测试',
    voiceId: 'voice_id',
    responseFormat: VoiceFormat.mp3,
  ),
);

// 保存音频
await File('output.mp3').writeAsBytes(response.data);
```

---

#### stream()

流式语音合成。

```dart
Stream<List<int>> stream(VoiceSpeechRequest request)
```

**返回：** `Stream<List<int>>` - 音频数据流

---

## VoiceTranscriptionsAPI 类

语音识别 API。

### 方法

#### create()

语音识别。

```dart
Future<VoiceTranscriptionsResponse> create(VoiceTranscriptionsRequest request)
```

**参数：**

| 参数 | 类型 | 说明 |
|------|------|------|
| `request` | `VoiceTranscriptionsRequest` | 识别请求 |

**返回：** `VoiceTranscriptionsResponse` - 识别结果

**示例：**

```dart
final audioData = await File('input.mp3').readAsBytes();

final response = await client.voice.transcriptions.create(
  VoiceTranscriptionsRequest(
    file: audioData,
    fileName: 'input.mp3',
    language: 'zh',
  ),
);

print('识别结果: ${response.text}');
```

---

## 数据类

### VoiceSpeechRequest

| 属性 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `input` | `String` | 是 | 要合成的文本 |
| `voiceId` | `String` | 是 | 语音 ID |
| `responseFormat` | `VoiceFormat?` | 否 | 输出格式 |
| `sampleRate` | `int?` | 否 | 采样率 |
| `speed` | `double?` | 否 | 语速 |
| `volume` | `double?` | 否 | 音量 |

### VoiceFormat 枚举

| 值 | 说明 |
|----|------|
| `mp3` | MP3 格式 |
| `wav` | WAV 格式 |
| `pcm` | PCM 格式 |
| `ogg` | OGG 格式 |

### VoiceTranscriptionsRequest

| 属性 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `file` | `List<int>` | 是 | 音频数据 |
| `fileName` | `String` | 是 | 文件名 |
| `language` | `String?` | 否 | 语言代码 |

---

## 相关链接

- [音频处理指南](../guides/audio.md) - 使用指南
