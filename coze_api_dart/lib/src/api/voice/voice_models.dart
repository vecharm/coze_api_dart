/// Voice API 数据模型
///
/// 包含语音合成、语音识别相关的所有数据模型定义
library;

import '../../models/enums.dart';

/// 语音合成请求
class TTSRequest {
  /// 要合成的文本内容
  /// JS 版使用 'input' 字段
  final String input;

  /// 语音 ID
  final String voiceId;

  /// 语速，范围 0.2-3.0，默认 1.0
  final double? speed;

  /// 音量，范围 0.0-2.0，默认 1.0
  final double? volume;

  /// 音频格式
  final AudioFormat? format;

  /// 采样率，默认 24000，支持 8000, 16000, 24000, 32000, 44100, 48000
  final int? sampleRate;

  /// 情感
  final String? emotion;

  /// 情感强度，[1,5]，默认为4
  final double? emotionScale;

  TTSRequest({
    required this.input,
    required this.voiceId,
    this.speed,
    this.volume,
    this.format,
    this.sampleRate,
    this.emotion,
    this.emotionScale,
  });

  Map<String, dynamic> toJson() {
    return {
      'input': input,
      'voice_id': voiceId,
      if (speed != null) 'speed': speed,
      if (volume != null) 'volume': volume,
      if (format != null) 'response_format': format!.name,
      'sample_rate': sampleRate ?? 24000,
      if (emotion != null) 'emotion': emotion,
      if (emotionScale != null) 'emotion_scale': emotionScale,
    };
  }
}

/// 语音合成响应
class TTSResponse {
  /// 音频数据（Base64 编码）
  final String audioData;

  /// 音频格式
  final AudioFormat format;

  /// 音频时长（秒）
  final double? duration;

  /// 采样率
  final int? sampleRate;

  TTSResponse({
    required this.audioData,
    required this.format,
    this.duration,
    this.sampleRate,
  });

  factory TTSResponse.fromJson(Map<String, dynamic> json) {
    return TTSResponse(
      audioData: json['audio'] as String,
      format: AudioFormat.values.firstWhere(
        (e) => e.name == (json['format'] ?? 'mp3'),
        orElse: () => AudioFormat.mp3,
      ),
      duration: json['duration'] as double?,
      sampleRate: json['sample_rate'] as int?,
    );
  }
}

/// 语音识别请求
class STTRequest {
  /// 音频数据（Base64 编码）
  final String audioData;

  /// 音频格式
  final AudioFormat format;

  /// 语言代码，如 'zh-CN', 'en-US'
  final String? language;

  /// 是否启用标点符号
  final bool? enablePunctuation;

  STTRequest({
    required this.audioData,
    required this.format,
    this.language,
    this.enablePunctuation,
  });

  Map<String, dynamic> toJson() {
    return {
      'audio': audioData,
      'format': format.name,
      if (language != null) 'language': language,
      if (enablePunctuation != null) 'enable_punctuation': enablePunctuation,
    };
  }
}

/// 语音识别响应
class STTResponse {
  /// 识别文本
  final String text;

  /// 置信度，范围 0.0-1.0
  final double? confidence;

  /// 识别结果详情
  final List<STTWord>? words;

  STTResponse({
    required this.text,
    this.confidence,
    this.words,
  });

  factory STTResponse.fromJson(Map<String, dynamic> json) {
    return STTResponse(
      text: json['text'] as String,
      confidence: json['confidence'] as double?,
      words: (json['words'] as List<dynamic>?)
          ?.map((e) => STTWord.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// 语音识别词级别结果
class STTWord {
  /// 词文本
  final String text;

  /// 开始时间（毫秒）
  final int startTime;

  /// 结束时间（毫秒）
  final int endTime;

  /// 置信度
  final double? confidence;

  STTWord({
    required this.text,
    required this.startTime,
    required this.endTime,
    this.confidence,
  });

  factory STTWord.fromJson(Map<String, dynamic> json) {
    return STTWord(
      text: json['text'] as String,
      startTime: json['start_time'] as int,
      endTime: json['end_time'] as int,
      confidence: json['confidence'] as double?,
    );
  }
}

/// 语音转录请求
class TranscriptionRequest {
  /// 音频文件 ID
  final String fileId;

  /// 语言代码
  final String? language;

  /// 是否启用说话人分离
  final bool? enableDiarization;

  TranscriptionRequest({
    required this.fileId,
    this.language,
    this.enableDiarization,
  });

  Map<String, dynamic> toJson() {
    return {
      'file_id': fileId,
      if (language != null) 'language': language,
      if (enableDiarization != null) 'enable_diarization': enableDiarization,
    };
  }
}

/// 语音转录响应
class TranscriptionResponse {
  /// 转录任务 ID
  final String transcriptionId;

  /// 转录状态
  final TranscriptionStatus status;

  /// 转录文本
  final String? text;

  /// 转录结果详情
  final List<TranscriptionSegment>? segments;

  TranscriptionResponse({
    required this.transcriptionId,
    required this.status,
    this.text,
    this.segments,
  });

  factory TranscriptionResponse.fromJson(Map<String, dynamic> json) {
    return TranscriptionResponse(
      transcriptionId: json['transcription_id'] as String,
      status: TranscriptionStatus.values.firstWhere(
        (e) => e.name == (json['status'] ?? 'processing'),
        orElse: () => TranscriptionStatus.processing,
      ),
      text: json['text'] as String?,
      segments: (json['segments'] as List<dynamic>?)
          ?.map((e) => TranscriptionSegment.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// 转录片段
class TranscriptionSegment {
  /// 片段 ID
  final String id;

  /// 说话人 ID
  final String? speakerId;

  /// 文本内容
  final String text;

  /// 开始时间（毫秒）
  final int startTime;

  /// 结束时间（毫秒）
  final int endTime;

  TranscriptionSegment({
    required this.id,
    this.speakerId,
    required this.text,
    required this.startTime,
    required this.endTime,
  });

  factory TranscriptionSegment.fromJson(Map<String, dynamic> json) {
    return TranscriptionSegment(
      id: json['id'] as String,
      speakerId: json['speaker_id'] as String?,
      text: json['text'] as String,
      startTime: json['start_time'] as int,
      endTime: json['end_time'] as int,
    );
  }
}

/// 语音信息
class Voice {
  /// 语音 ID
  final String id;

  /// 语音名称
  final String name;

  /// 语言
  final String language;

  /// 性别
  final String? gender;

  /// 描述
  final String? description;

  /// 预览音频 URL
  final String? previewUrl;

  Voice({
    required this.id,
    required this.name,
    required this.language,
    this.gender,
    this.description,
    this.previewUrl,
  });

  factory Voice.fromJson(Map<String, dynamic> json) {
    return Voice(
      id: json['voice_id'] as String,
      name: json['name'] as String,
      language: json['language'] as String,
      gender: json['gender'] as String?,
      description: json['description'] as String?,
      previewUrl: json['preview_url'] as String?,
    );
  }
}

/// 列出语音请求
class ListVoicesRequest {
  /// 语言过滤
  final String? language;

  /// 分页大小
  final int? pageSize;

  /// 分页游标
  final String? cursor;

  ListVoicesRequest({
    this.language,
    this.pageSize,
    this.cursor,
  });

  Map<String, dynamic> toJson() {
    return {
      if (language != null) 'language': language,
      if (pageSize != null) 'page_size': pageSize,
      if (cursor != null) 'cursor': cursor,
    };
  }
}

/// 列出语音响应
class ListVoicesResponse {
  /// 语音列表
  final List<Voice> voices;

  /// 是否有更多
  final bool hasMore;

  /// 分页游标
  final String? cursor;

  ListVoicesResponse({
    required this.voices,
    required this.hasMore,
    this.cursor,
  });

  factory ListVoicesResponse.fromJson(Map<String, dynamic> json) {
    return ListVoicesResponse(
      voices: (json['data'] as List<dynamic>?)
              ?.map((e) => Voice.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      hasMore: json['has_more'] as bool? ?? false,
      cursor: json['cursor'] as String?,
    );
  }
}
