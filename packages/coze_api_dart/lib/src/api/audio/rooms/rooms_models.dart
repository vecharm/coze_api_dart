/// Audio Rooms API 数据模型
///
/// 包含音频房间管理相关的所有数据模型定义
library;

/// 创建房间请求
class CreateRoomRequest {
  /// Bot ID
  final String botId;

  /// 会话 ID
  final String? conversationId;

  /// 语音 ID
  final String? voiceId;

  /// 渠道 ID
  final String connectorId;

  /// 用户 ID
  final String? uid;

  /// 工作流 ID
  final String? workflowId;

  /// 房间配置
  final RoomConfig? config;

  CreateRoomRequest({
    required this.botId,
    this.conversationId,
    this.voiceId,
    required this.connectorId,
    this.uid,
    this.workflowId,
    this.config,
  });

  Map<String, dynamic> toJson() {
    return {
      'bot_id': botId,
      'connector_id': connectorId,
      if (conversationId != null) 'conversation_id': conversationId,
      if (voiceId != null) 'voice_id': voiceId,
      if (uid != null) 'uid': uid,
      if (workflowId != null) 'workflow_id': workflowId,
      if (config != null) 'config': config!.toJson(),
    };
  }
}

/// 房间配置
class RoomConfig {
  /// 视频配置
  final VideoConfig? videoConfig;

  /// 开场白内容
  final String? prologueContent;

  /// 翻译配置
  final TranslateConfig? translateConfig;

  /// 房间模式
  final RoomMode? roomMode;

  /// 说话检测配置
  final TurnDetectionConfig? turnDetection;

  RoomConfig({
    this.videoConfig,
    this.prologueContent,
    this.translateConfig,
    this.roomMode,
    this.turnDetection,
  });

  Map<String, dynamic> toJson() {
    return {
      if (videoConfig != null) 'video_config': videoConfig!.toJson(),
      if (prologueContent != null) 'prologue_content': prologueContent,
      if (translateConfig != null) 'translate_config': translateConfig!.toJson(),
      if (roomMode != null) 'room_mode': roomMode!.name,
      if (turnDetection != null) 'turn_detection': turnDetection!.toJson(),
    };
  }
}

/// 视频配置
class VideoConfig {
  /// 视频流类型
  final StreamVideoType streamVideoType;

  VideoConfig({
    required this.streamVideoType,
  });

  Map<String, dynamic> toJson() {
    return {
      'stream_video_type': streamVideoType.name,
    };
  }
}

/// 视频流类型
enum StreamVideoType {
  /// 主视频
  main,

  /// 屏幕共享
  screen,
}

/// 翻译配置
class TranslateConfig {
  /// 源语言
  final String from;

  /// 目标语言
  final String to;

  TranslateConfig({
    required this.from,
    required this.to,
  });

  Map<String, dynamic> toJson() {
    return {
      'from': from,
      'to': to,
    };
  }
}

/// 房间模式
enum RoomMode {
  /// 普通模式
  default_,

  /// 端到端模式
  s2s,

  /// 博客模式
  podcast,

  /// 同声传译模式
  translate,
}

/// 说话检测配置
class TurnDetectionConfig {
  /// 检测类型
  final TurnDetectionType? type;

  TurnDetectionConfig({
    this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      if (type != null) 'type': type!.name,
    };
  }
}

/// 说话检测类型
enum TurnDetectionType {
  /// 服务端 VAD
  serverVad,

  /// 客户端 VAD
  clientVad,

  /// 客户端打断
  clientInterrupt,
}

/// 创建房间响应
class CreateRoomResponse {
  /// Token
  final String token;

  /// 用户 ID
  final String uid;

  /// 房间 ID
  final String roomId;

  /// 应用 ID
  final String appId;

  CreateRoomResponse({
    required this.token,
    required this.uid,
    required this.roomId,
    required this.appId,
  });

  factory CreateRoomResponse.fromJson(Map<String, dynamic> json) {
    return CreateRoomResponse(
      token: json['token'] as String,
      uid: json['uid'] as String,
      roomId: json['room_id'] as String,
      appId: json['app_id'] as String,
    );
  }
}
