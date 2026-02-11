/// Audio Live API 数据模型
///
/// 包含实时音频直播相关的所有数据模型定义
library;

/// 获取直播信息响应
class RetrieveLiveData {
  /// 应用 ID
  final String appId;

  /// 流信息列表
  final List<StreamInfo> streamInfos;

  RetrieveLiveData({
    required this.appId,
    required this.streamInfos,
  });

  factory RetrieveLiveData.fromJson(Map<String, dynamic> json) {
    return RetrieveLiveData(
      appId: json['app_id'] as String,
      streamInfos: (json['stream_infos'] as List<dynamic>?)
              ?.map((e) => StreamInfo.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// 流信息
class StreamInfo {
  /// 流 ID
  final String streamId;

  /// 流名称
  final String name;

  /// 直播类型
  final LiveType liveType;

  StreamInfo({
    required this.streamId,
    required this.name,
    required this.liveType,
  });

  factory StreamInfo.fromJson(Map<String, dynamic> json) {
    return StreamInfo(
      streamId: json['stream_id'] as String,
      name: json['name'] as String,
      liveType: LiveType.values.firstWhere(
        (e) => e.name == json['live_type'],
        orElse: () => LiveType.origin,
      ),
    );
  }
}

/// 直播类型
enum LiveType {
  /// 原生流
  origin,

  /// 翻译流
  translation,
}
