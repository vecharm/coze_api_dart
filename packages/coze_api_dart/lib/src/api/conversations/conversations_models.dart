
/// 会话管理 API 数据模型
///
/// 包含会话相关的所有数据模型定义
library;

import '../../models/enums.dart';

/// 会话对象
///
/// 表示一个对话会话，包含会话的元信息和设置
class Conversation {
  /// 会话 ID
  final String id;

  /// 创建时间（Unix 时间戳，秒）
  final int createdAt;

  /// 元数据
  final Map<String, dynamic>? metaData;

  /// 创建会话的角色名称
  final String? roleType;

  Conversation({
    required this.id,
    required this.createdAt,
    this.metaData,
    this.roleType,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] as String,
      createdAt: json['created_at'] as int,
      metaData: json['meta_data'] as Map<String, dynamic>?,
      roleType: json['role_type'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt,
      if (metaData != null) 'meta_data': metaData,
      if (roleType != null) 'role_type': roleType,
    };
  }
}

/// 创建会话请求
class CreateConversationRequest {
  /// 消息列表
  final List<ConversationMessage>? messages;

  /// 元数据
  final Map<String, dynamic>? metaData;

  CreateConversationRequest({
    this.messages,
    this.metaData,
  });

  Map<String, dynamic> toJson() {
    return {
      if (messages != null)
        'messages': messages!.map((e) => e.toJson()).toList(),
      if (metaData != null) 'meta_data': metaData,
    };
  }
}

/// 会话消息
class ConversationMessage {
  /// 角色
  final RoleType role;

  /// 内容
  final String content;

  /// 内容类型
  final ContentType contentType;

  /// 附加文件列表
  final List<ConversationMessageFile>? files;

  ConversationMessage({
    required this.role,
    required this.content,
    this.contentType = ContentType.text,
    this.files,
  });

  factory ConversationMessage.fromJson(Map<String, dynamic> json) {
    return ConversationMessage(
      role: RoleType.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => RoleType.user,
      ),
      content: json['content'] as String,
      contentType: ContentType.values.firstWhere(
        (e) => e.name == (json['content_type'] ?? 'text'),
        orElse: () => ContentType.text,
      ),
      files: (json['files'] as List<dynamic>?)
          ?.map((e) => ConversationMessageFile.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role': role.name,
      'content': content,
      'content_type': contentType.name,
      if (files != null) 'files': files!.map((e) => e.toJson()).toList(),
    };
  }

  /// 创建用户消息
  factory ConversationMessage.user({
    required String content,
    ContentType contentType = ContentType.text,
    List<ConversationMessageFile>? files,
  }) {
    return ConversationMessage(
      role: RoleType.user,
      content: content,
      contentType: contentType,
      files: files,
    );
  }

  /// 创建助手消息
  factory ConversationMessage.assistant({
    required String content,
    ContentType contentType = ContentType.text,
  }) {
    return ConversationMessage(
      role: RoleType.assistant,
      content: content,
      contentType: contentType,
    );
  }
}

/// 会话消息文件
class ConversationMessageFile {
  /// 文件 ID
  final String fileId;

  ConversationMessageFile({
    required this.fileId,
  });

  factory ConversationMessageFile.fromJson(Map<String, dynamic> json) {
    return ConversationMessageFile(
      fileId: json['file_id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'file_id': fileId,
    };
  }
}

/// 获取会话列表请求
class ListConversationsRequest {
  ///  Bot ID
  final String botId;

  /// 分页大小，默认 20，最大 50
  final int? limit;

  /// 分页游标
  final String? cursor;

  /// 排序方式，默认 desc
  final String? order;

  ListConversationsRequest({
    required this.botId,
    this.limit,
    this.cursor,
    this.order,
  });

  Map<String, dynamic> toJson() {
    return {
      'bot_id': botId,
      if (limit != null) 'limit': limit,
      if (cursor != null) 'cursor': cursor,
      if (order != null) 'order': order,
    };
  }
}

/// 会话列表响应
class ListConversationsResponse {
  /// 会话列表
  final List<Conversation> conversations;

  /// 分页信息
  final ConversationPagination? pagination;

  ListConversationsResponse({
    required this.conversations,
    this.pagination,
  });

  factory ListConversationsResponse.fromJson(Map<String, dynamic> json) {
    return ListConversationsResponse(
      conversations: (json['data'] as List<dynamic>?)
              ?.map((e) => Conversation.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      pagination: json['pagination'] != null
          ? ConversationPagination.fromJson(
              json['pagination'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// 会话分页信息
class ConversationPagination {
  /// 分页游标
  final String? cursor;

  /// 是否有更多数据
  final bool hasMore;

  ConversationPagination({
    this.cursor,
    required this.hasMore,
  });

  factory ConversationPagination.fromJson(Map<String, dynamic> json) {
    return ConversationPagination(
      cursor: json['cursor'] as String?,
      hasMore: json['has_more'] as bool? ?? false,
    );
  }
}

/// 清空会话消息请求
class ClearConversationMessagesRequest {
  /// 会话 ID
  final String conversationId;

  ///  Bot ID
  final String botId;

  ClearConversationMessagesRequest({
    required this.conversationId,
    required this.botId,
  });

  Map<String, dynamic> toJson() {
    return {
      'conversation_id': conversationId,
      'bot_id': botId,
    };
  }
}
