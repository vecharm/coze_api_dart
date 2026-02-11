/// Conversations Messages API 数据模型
///
/// 包含会话消息管理相关的所有数据模型定义
library;

import '../../../models/enums.dart';

/// 创建消息请求
class CreateMessageRequest {
  /// 角色类型
  final RoleType role;

  /// 消息内容
  final String content;

  /// 内容类型
  final ContentType contentType;

  /// 元数据
  final Map<String, dynamic>? metaData;

  CreateMessageRequest({
    required this.role,
    required this.content,
    required this.contentType,
    this.metaData,
  });

  Map<String, dynamic> toJson() {
    return {
      'role': role.name,
      'content': content,
      'content_type': contentType.name,
      if (metaData != null) 'meta_data': metaData,
    };
  }
}

/// 修改消息请求
class UpdateMessageRequest {
  /// 消息内容
  final String? content;

  /// 内容类型
  final ContentType? contentType;

  /// 元数据
  final Map<String, dynamic>? metaData;

  UpdateMessageRequest({
    this.content,
    this.contentType,
    this.metaData,
  });

  Map<String, dynamic> toJson() {
    return {
      if (content != null) 'content': content,
      if (contentType != null) 'content_type': contentType!.name,
      if (metaData != null) 'meta_data': metaData,
    };
  }
}

/// 列出消息请求
class ListMessagesRequest {
  /// 排序方式
  final String? order;

  /// 对话 ID
  final String? chatId;

  /// 在此消息 ID 之前
  final String? beforeId;

  /// 在此消息 ID 之后
  final String? afterId;

  /// 限制数量
  final int? limit;

  ListMessagesRequest({
    this.order,
    this.chatId,
    this.beforeId,
    this.afterId,
    this.limit,
  });

  Map<String, dynamic> toJson() {
    return {
      if (order != null) 'order': order,
      if (chatId != null) 'chat_id': chatId,
      if (beforeId != null) 'before_id': beforeId,
      if (afterId != null) 'after_id': afterId,
      if (limit != null) 'limit': limit,
    };
  }
}

/// 列出消息响应
class ListMessagesResponse {
  /// 消息列表
  final List<Map<String, dynamic>> data;

  /// 第一条消息 ID
  final String? firstId;

  /// 最后一条消息 ID
  final String? lastId;

  /// 是否有更多
  final bool hasMore;

  ListMessagesResponse({
    required this.data,
    this.firstId,
    this.lastId,
    required this.hasMore,
  });

  factory ListMessagesResponse.fromJson(Map<String, dynamic> json) {
    return ListMessagesResponse(
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [],
      firstId: json['first_id'] as String?,
      lastId: json['last_id'] as String?,
      hasMore: json['has_more'] as bool? ?? false,
    );
  }
}
