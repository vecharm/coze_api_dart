/// Audio Voices API 数据模型
///
/// 包含语音克隆和语音列表相关的所有数据模型定义
library;

/// 克隆语音请求
class CloneVoiceRequest {
  /// 音色名称，不能为空，长度大于 6
  final String voiceName;

  /// 音频文件（Base64 编码或文件 ID）
  final String file;

  /// 音频格式，只支持 "wav", "mp3", "ogg", "m4a", "aac", "pcm"
  final String audioFormat;

  /// 语种，只支持 "zh", "en", "ja", "es", "id", "pt"
  final String? language;

  /// 如果传入，会在原有音色上训练并覆盖
  final String? voiceId;

  /// 预览文本，如果传入会基于该文本生成预览音频
  final String? previewText;

  /// 用户可以按照该文本念诵，服务会对比音频与文本的差异
  final String? text;

  /// 空间 ID
  final String? spaceId;

  /// 音色描述
  final String? description;

  CloneVoiceRequest({
    required this.voiceName,
    required this.file,
    required this.audioFormat,
    this.language,
    this.voiceId,
    this.previewText,
    this.text,
    this.spaceId,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'voice_name': voiceName,
      'file': file,
      'audio_format': audioFormat,
      if (language != null) 'language': language,
      if (voiceId != null) 'voice_id': voiceId,
      if (previewText != null) 'preview_text': previewText,
      if (text != null) 'text': text,
      if (spaceId != null) 'space_id': spaceId,
      if (description != null) 'description': description,
    };
  }
}

/// 克隆语音响应
class CloneVoiceResponse {
  /// 复刻后音色 ID
  final String voiceId;

  CloneVoiceResponse({required this.voiceId});

  factory CloneVoiceResponse.fromJson(Map<String, dynamic> json) {
    return CloneVoiceResponse(
      voiceId: json['voice_id'] as String,
    );
  }
}

/// 列出语音请求
class ListVoicesRequest {
  /// 音色模型类型
  final String? modelType;

  /// 是否过滤系统音色，默认不过滤
  final bool? filterSystemVoice;

  /// 页码，默认从 1 开始
  final int? pageNum;

  /// 分页大小，默认 100
  final int? pageSize;

  ListVoicesRequest({
    this.modelType,
    this.filterSystemVoice,
    this.pageNum,
    this.pageSize,
  });

  Map<String, dynamic> toJson() {
    return {
      if (modelType != null) 'model_type': modelType,
      if (filterSystemVoice != null)
        'filter_system_voice': filterSystemVoice.toString(),
      if (pageNum != null) 'page_num': pageNum.toString(),
      if (pageSize != null) 'page_size': pageSize.toString(),
    };
  }
}

/// 列出语音响应
class ListVoicesResponse {
  /// 音色列表
  final List<VoiceInfo> voiceList;

  /// 是否还有更多数据
  final bool hasMore;

  ListVoicesResponse({
    required this.voiceList,
    required this.hasMore,
  });

  factory ListVoicesResponse.fromJson(Map<String, dynamic> json) {
    return ListVoicesResponse(
      voiceList: (json['voice_list'] as List<dynamic>?)
              ?.map((e) => VoiceInfo.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      hasMore: json['has_more'] as bool? ?? false,
    );
  }
}

/// 语音信息
class VoiceInfo {
  /// 是否为系统音色
  final bool isSystemVoice;

  /// 语言名称
  final String languageName;

  /// 预览文本
  final String previewText;

  /// 创建时间
  final int createTime;

  /// 更新时间
  final int updateTime;

  /// 音色名称
  final String name;

  /// 语言代码
  final String languageCode;

  /// 音色 ID
  final String voiceId;

  /// 当前音色还可以训练的次数
  final int availableTrainingTimes;

  /// 预览音频 URL
  final String previewAudio;

  /// 支持的情感列表
  final List<EmotionInfo>? supportEmotions;

  VoiceInfo({
    required this.isSystemVoice,
    required this.languageName,
    required this.previewText,
    required this.createTime,
    required this.updateTime,
    required this.name,
    required this.languageCode,
    required this.voiceId,
    required this.availableTrainingTimes,
    required this.previewAudio,
    this.supportEmotions,
  });

  factory VoiceInfo.fromJson(Map<String, dynamic> json) {
    return VoiceInfo(
      isSystemVoice: json['is_system_voice'] as bool,
      languageName: json['language_name'] as String,
      previewText: json['preview_text'] as String,
      createTime: json['create_time'] as int,
      updateTime: json['update_time'] as int,
      name: json['name'] as String,
      languageCode: json['language_code'] as String,
      voiceId: json['voice_id'] as String,
      availableTrainingTimes: json['available_training_times'] as int,
      previewAudio: json['preview_audio'] as String,
      supportEmotions: (json['support_emotions'] as List<dynamic>?)
          ?.map((e) => EmotionInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// 情感信息
class EmotionInfo {
  /// 情感标识
  final String? emotion;

  /// 显示名称
  final String? displayName;

  /// 情感强度区间
  final IntervalInfo? emotionScaleInterval;

  EmotionInfo({
    this.emotion,
    this.displayName,
    this.emotionScaleInterval,
  });

  factory EmotionInfo.fromJson(Map<String, dynamic> json) {
    return EmotionInfo(
      emotion: json['emotion'] as String?,
      displayName: json['display_name'] as String?,
      emotionScaleInterval: json['emotion_scale_interval'] != null
          ? IntervalInfo.fromJson(
              json['emotion_scale_interval'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// 区间信息
class IntervalInfo {
  /// 最小值
  final double? min;

  /// 最大值
  final double? max;

  /// 默认值
  final double? defaultValue;

  IntervalInfo({
    this.min,
    this.max,
    this.defaultValue,
  });

  factory IntervalInfo.fromJson(Map<String, dynamic> json) {
    return IntervalInfo(
      min: (json['min'] as num?)?.toDouble(),
      max: (json['max'] as num?)?.toDouble(),
      defaultValue: (json['default'] as num?)?.toDouble(),
    );
  }
}
