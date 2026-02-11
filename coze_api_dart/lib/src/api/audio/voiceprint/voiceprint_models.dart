/// Audio Voiceprint Groups API 数据模型
///
/// 包含声纹组管理相关的所有数据模型定义
library;

/// 创建声纹特征请求
class CreateVoiceprintFeatureRequest {
  /// 音频文件（Base64 编码或文件 ID）
  final String file;

  /// 特征名称
  final String name;

  /// 特征描述
  final String? desc;

  /// 采样率（仅 PCM 文件需要）
  final int? sampleRate;

  /// 声道数（仅 PCM 文件需要），0 / 1
  final int? channel;

  CreateVoiceprintFeatureRequest({
    required this.file,
    required this.name,
    this.desc,
    this.sampleRate,
    this.channel,
  });

  Map<String, dynamic> toJson() {
    return {
      'file': file,
      'name': name,
      if (desc != null) 'desc': desc,
      if (sampleRate != null) 'sample_rate': sampleRate,
      if (channel != null) 'channel': channel,
    };
  }
}

/// 更新声纹特征请求
class UpdateVoiceprintFeatureRequest {
  /// 音频文件（Base64 编码或文件 ID）
  final String? file;

  /// 特征名称
  final String? name;

  /// 特征描述
  final String? desc;

  /// 采样率（仅 PCM 文件需要）
  final int? sampleRate;

  /// 声道数（仅 PCM 文件需要），0 / 1
  final int? channel;

  UpdateVoiceprintFeatureRequest({
    this.file,
    this.name,
    this.desc,
    this.sampleRate,
    this.channel,
  });

  Map<String, dynamic> toJson() {
    return {
      if (file != null) 'file': file,
      if (name != null) 'name': name,
      if (desc != null) 'desc': desc,
      if (sampleRate != null) 'sample_rate': sampleRate,
      if (channel != null) 'channel': channel,
    };
  }
}

/// 创建声纹特征响应
class CreateVoiceprintFeatureResponse {
  /// 特征 ID
  final String id;

  CreateVoiceprintFeatureResponse({
    required this.id,
  });

  factory CreateVoiceprintFeatureResponse.fromJson(Map<String, dynamic> json) {
    return CreateVoiceprintFeatureResponse(
      id: json['id'] as String,
    );
  }
}

/// 列出声纹特征请求
class ListVoiceprintFeatureRequest {
  /// 页码
  final int? pageNum;

  /// 分页大小
  final int? pageSize;

  ListVoiceprintFeatureRequest({
    this.pageNum,
    this.pageSize,
  });

  Map<String, dynamic> toJson() {
    return {
      if (pageNum != null) 'page_num': pageNum.toString(),
      if (pageSize != null) 'page_size': pageSize.toString(),
    };
  }
}

/// 列出声纹特征响应
class ListVoiceprintFeatureResponse {
  /// 声纹特征列表
  final List<VoiceprintFeature> items;

  /// 总数
  final int? total;

  ListVoiceprintFeatureResponse({
    required this.items,
    this.total,
  });

  factory ListVoiceprintFeatureResponse.fromJson(Map<String, dynamic> json) {
    return ListVoiceprintFeatureResponse(
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => VoiceprintFeature.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      total: json['total'] as int?,
    );
  }
}

/// 声纹特征
class VoiceprintFeature {
  /// 特征 ID
  final String? id;

  /// 组 ID
  final String? groupId;

  /// 特征名称
  final String? name;

  /// 音频 URL
  final String? audioUrl;

  /// 创建时间
  final int? createdAt;

  /// 更新时间
  final int? updatedAt;

  /// 特征描述
  final String? desc;

  /// 图标 URL
  final String? iconUrl;

  /// 用户信息
  final Map<String, dynamic>? userInfo;

  VoiceprintFeature({
    this.id,
    this.groupId,
    this.name,
    this.audioUrl,
    this.createdAt,
    this.updatedAt,
    this.desc,
    this.iconUrl,
    this.userInfo,
  });

  factory VoiceprintFeature.fromJson(Map<String, dynamic> json) {
    return VoiceprintFeature(
      id: json['id'] as String?,
      groupId: json['group_id'] as String?,
      name: json['name'] as String?,
      audioUrl: json['audio_url'] as String?,
      createdAt: json['created_at'] as int?,
      updatedAt: json['updated_at'] as int?,
      desc: json['desc'] as String?,
      iconUrl: json['icon_url'] as String?,
      userInfo: json['user_info'] as Map<String, dynamic>?,
    );
  }
}

/// 说话人识别请求
class SpeakerIdentifyRequest {
  /// 音频文件（Base64 编码或文件 ID）
  final String file;

  /// 返回前 K 个最匹配的结果
  final int? topK;

  /// 采样率（仅 PCM 文件需要）
  final int? sampleRate;

  /// 声道数（仅 PCM 文件需要）
  final int? channel;

  SpeakerIdentifyRequest({
    required this.file,
    this.topK,
    this.sampleRate,
    this.channel,
  });

  Map<String, dynamic> toJson() {
    return {
      'file': file,
      if (topK != null) 'top_k': topK,
      if (sampleRate != null) 'sample_rate': sampleRate,
      if (channel != null) 'channel': channel,
    };
  }
}

/// 说话人识别响应
class SpeakerIdentifyResponse {
  /// 特征分数列表
  final List<FeatureScore> featureScoreList;

  SpeakerIdentifyResponse({
    required this.featureScoreList,
  });

  factory SpeakerIdentifyResponse.fromJson(Map<String, dynamic> json) {
    return SpeakerIdentifyResponse(
      featureScoreList: (json['feature_score_list'] as List<dynamic>?)
              ?.map((e) => FeatureScore.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// 特征分数
class FeatureScore {
  /// 特征 ID
  final String? featureId;

  /// 特征名称
  final String? featureName;

  /// 特征描述
  final String? featureDesc;

  /// 匹配分数
  final double? score;

  FeatureScore({
    this.featureId,
    this.featureName,
    this.featureDesc,
    this.score,
  });

  factory FeatureScore.fromJson(Map<String, dynamic> json) {
    return FeatureScore(
      featureId: json['feature_id'] as String?,
      featureName: json['feature_name'] as String?,
      featureDesc: json['feature_desc'] as String?,
      score: (json['score'] as num?)?.toDouble(),
    );
  }
}
