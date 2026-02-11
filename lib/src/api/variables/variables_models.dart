/// Variables API 数据模型
///
/// 包含变量管理相关的所有数据模型定义
library;

/// 更新变量请求
class UpdateVariablesRequest {
  /// 应用 ID
  /// 获取应用中的用户变量时必须提供
  /// app_id 和 bot_id 必须提供一个
  final String? appId;

  /// Bot ID
  /// 获取 Bot 中的用户变量时必须提供
  /// app_id 和 bot_id 必须提供一个
  final String? botId;

  /// 渠道 ID
  /// 支持的渠道包括：
  /// - API: 1024
  /// - ChatSDK: 999
  /// - 自定义渠道: 自定义渠道 ID
  final String? connectorId;

  /// 用户 ID
  /// 用于获取特定用户的变量值
  final String? connectorUid;

  /// 变量数据列表
  final List<VariableItem> data;

  UpdateVariablesRequest({
    this.appId,
    this.botId,
    this.connectorId,
    this.connectorUid,
    required this.data,
  });

  Map<String, dynamic> toJson() {
    return {
      if (appId != null) 'app_id': appId,
      if (botId != null) 'bot_id': botId,
      if (connectorId != null) 'connector_id': connectorId,
      if (connectorUid != null) 'connector_uid': connectorUid,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}

/// 获取变量请求
class RetrieveVariablesRequest {
  /// 应用 ID
  final String? appId;

  /// Bot ID
  final String? botId;

  /// 渠道 ID
  final String? connectorId;

  /// 用户 ID
  final String? connectorUid;

  /// 变量名称列表，多个变量用逗号分隔
  /// 如果为空，返回所有用户变量
  final List<String>? keywords;

  RetrieveVariablesRequest({
    this.appId,
    this.botId,
    this.connectorId,
    this.connectorUid,
    this.keywords,
  });

  Map<String, dynamic> toJson() {
    return {
      if (appId != null) 'app_id': appId,
      if (botId != null) 'bot_id': botId,
      if (connectorId != null) 'connector_id': connectorId,
      if (connectorUid != null) 'connector_uid': connectorUid,
      if (keywords != null) 'keywords': keywords!.join(','),
    };
  }
}

/// 变量数据响应
class VariablesData {
  /// 变量项列表
  final List<VariableItem> items;

  VariablesData({
    required this.items,
  });

  factory VariablesData.fromJson(Map<String, dynamic> json) {
    return VariablesData(
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => VariableItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// 变量项
class VariableItem {
  /// 变量名称
  final String keyword;

  /// 变量值
  final String value;

  /// 创建时间（Unix 时间戳，秒）
  /// 如果是默认值，create_time 为 0
  final int createTime;

  /// 更新时间（Unix 时间戳，秒）
  final int updateTime;

  VariableItem({
    required this.keyword,
    required this.value,
    required this.createTime,
    required this.updateTime,
  });

  factory VariableItem.fromJson(Map<String, dynamic> json) {
    return VariableItem(
      keyword: json['keyword'] as String,
      value: json['value'] as String,
      createTime: json['create_time'] as int? ?? 0,
      updateTime: json['update_time'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'keyword': keyword,
      'value': value,
    };
  }
}
