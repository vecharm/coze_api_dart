/// Templates API 数据模型
///
/// 包含模板管理相关的所有数据模型定义
library;

/// 模板
class Template {
  /// 模板 ID
  final String id;

  /// 模板名称
  final String name;

  /// 模板描述
  final String? description;

  /// 模板类型
  final TemplateType type;

  /// 模板内容
  final String content;

  /// 创建者 ID
  final String creatorId;

  /// 空间 ID
  final String? spaceId;

  /// 是否公开
  final bool isPublic;

  /// 使用次数
  final int usageCount;

  /// 创建时间
  final DateTime createdAt;

  /// 更新时间
  final DateTime updatedAt;

  Template({
    required this.id,
    required this.name,
    this.description,
    required this.type,
    required this.content,
    required this.creatorId,
    this.spaceId,
    required this.isPublic,
    required this.usageCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Template.fromJson(Map<String, dynamic> json) {
    return Template(
      id: json['template_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      type: TemplateType.values.firstWhere(
        (e) => e.name == (json['type'] ?? 'prompt'),
        orElse: () => TemplateType.prompt,
      ),
      content: json['content'] as String,
      creatorId: json['creator_id'] as String,
      spaceId: json['space_id'] as String?,
      isPublic: json['is_public'] as bool? ?? false,
      usageCount: json['usage_count'] as int? ?? 0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (json['create_time'] as int) * 1000,
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        (json['update_time'] as int) * 1000,
      ),
    );
  }
}

/// 模板类型
enum TemplateType {
  /// 提示词模板
  prompt,

  /// 工作流模板
  workflow,

  /// 插件模板
  plugin,

  /// 知识库模板
  knowledge,
}

/// 创建模板请求
class CreateTemplateRequest {
  /// 模板名称
  final String name;

  /// 模板描述
  final String? description;

  /// 模板类型
  final TemplateType type;

  /// 模板内容
  final String content;

  /// 空间 ID
  final String? spaceId;

  /// 是否公开
  final bool isPublic;

  CreateTemplateRequest({
    required this.name,
    this.description,
    this.type = TemplateType.prompt,
    required this.content,
    this.spaceId,
    this.isPublic = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (description != null) 'description': description,
      'type': type.name,
      'content': content,
      if (spaceId != null) 'space_id': spaceId,
      'is_public': isPublic,
    };
  }
}

/// 更新模板请求
class UpdateTemplateRequest {
  /// 模板 ID
  final String templateId;

  /// 模板名称
  final String? name;

  /// 模板描述
  final String? description;

  /// 模板内容
  final String? content;

  /// 是否公开
  final bool? isPublic;

  UpdateTemplateRequest({
    required this.templateId,
    this.name,
    this.description,
    this.content,
    this.isPublic,
  });

  Map<String, dynamic> toJson() {
    return {
      'template_id': templateId,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (content != null) 'content': content,
      if (isPublic != null) 'is_public': isPublic,
    };
  }
}

/// 列出模板请求
class ListTemplatesRequest {
  /// 空间 ID
  final String? spaceId;

  /// 模板类型
  final TemplateType? type;

  /// 是否只查看公开模板
  final bool? isPublic;

  /// 分页大小
  final int? pageSize;

  /// 分页游标
  final String? cursor;

  ListTemplatesRequest({
    this.spaceId,
    this.type,
    this.isPublic,
    this.pageSize,
    this.cursor,
  });

  Map<String, dynamic> toJson() {
    return {
      if (spaceId != null) 'space_id': spaceId,
      if (type != null) 'type': type!.name,
      if (isPublic != null) 'is_public': isPublic,
      if (pageSize != null) 'page_size': pageSize,
      if (cursor != null) 'cursor': cursor,
    };
  }
}

/// 列出模板响应
class ListTemplatesResponse {
  /// 模板列表
  final List<Template> templates;

  /// 是否有更多
  final bool hasMore;

  /// 分页游标
  final String? cursor;

  ListTemplatesResponse({
    required this.templates,
    required this.hasMore,
    this.cursor,
  });

  factory ListTemplatesResponse.fromJson(Map<String, dynamic> json) {
    return ListTemplatesResponse(
      templates: (json['data'] as List<dynamic>?)
              ?.map((e) => Template.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      hasMore: json['has_more'] as bool? ?? false,
      cursor: json['cursor'] as String?,
    );
  }
}

/// 从模板创建 Bot 请求
class CreateBotFromTemplateRequest {
  /// 模板 ID
  final String templateId;

  /// Bot 名称
  final String? botName;

  /// 空间 ID
  final String? spaceId;

  CreateBotFromTemplateRequest({
    required this.templateId,
    this.botName,
    this.spaceId,
  });

  Map<String, dynamic> toJson() {
    return {
      'template_id': templateId,
      if (botName != null) 'bot_name': botName,
      if (spaceId != null) 'space_id': spaceId,
    };
  }
}

/// 从模板创建 Bot 响应
class CreateBotFromTemplateResponse {
  /// 新创建的 Bot ID
  final String botId;

  /// Bot 名称
  final String botName;

  CreateBotFromTemplateResponse({
    required this.botId,
    required this.botName,
  });

  factory CreateBotFromTemplateResponse.fromJson(Map<String, dynamic> json) {
    return CreateBotFromTemplateResponse(
      botId: json['bot_id'] as String,
      botName: json['bot_name'] as String,
    );
  }
}

/// 模板变量
class TemplateVariable {
  /// 变量名
  final String name;

  /// 变量描述
  final String? description;

  /// 默认值
  final String? defaultValue;

  /// 是否必需
  final bool isRequired;

  TemplateVariable({
    required this.name,
    this.description,
    this.defaultValue,
    this.isRequired = false,
  });

  factory TemplateVariable.fromJson(Map<String, dynamic> json) {
    return TemplateVariable(
      name: json['name'] as String,
      description: json['description'] as String?,
      defaultValue: json['default_value'] as String?,
      isRequired: json['is_required'] as bool? ?? false,
    );
  }
}

/// 模板详情（包含变量信息）
class TemplateDetail extends Template {
  /// 模板变量列表
  final List<TemplateVariable> variables;

  TemplateDetail({
    required super.id,
    required super.name,
    super.description,
    required super.type,
    required super.content,
    required super.creatorId,
    super.spaceId,
    required super.isPublic,
    required super.usageCount,
    required super.createdAt,
    required super.updatedAt,
    required this.variables,
  });

  factory TemplateDetail.fromJson(Map<String, dynamic> json) {
    return TemplateDetail(
      id: json['template_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      type: TemplateType.values.firstWhere(
        (e) => e.name == (json['type'] ?? 'prompt'),
        orElse: () => TemplateType.prompt,
      ),
      content: json['content'] as String,
      creatorId: json['creator_id'] as String,
      spaceId: json['space_id'] as String?,
      isPublic: json['is_public'] as bool? ?? false,
      usageCount: json['usage_count'] as int? ?? 0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (json['create_time'] as int) * 1000,
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        (json['update_time'] as int) * 1000,
      ),
      variables: (json['variables'] as List<dynamic>?)
              ?.map((e) => TemplateVariable.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// 复制模板请求
class DuplicateTemplateRequest {
  /// 工作空间 ID
  final String workspaceId;

  /// 新模板名称
  final String? name;

  DuplicateTemplateRequest({
    required this.workspaceId,
    this.name,
  });

  Map<String, dynamic> toJson() {
    return {
      'workspace_id': workspaceId,
      if (name != null) 'name': name,
    };
  }
}

/// 模板实体类型
enum TemplateEntityType {
  /// Bot
  agent,
}

/// 复制模板响应
class DuplicateTemplateResponse {
  /// 实体 ID
  final String entityId;

  /// 实体类型
  final TemplateEntityType entityType;

  DuplicateTemplateResponse({
    required this.entityId,
    required this.entityType,
  });

  factory DuplicateTemplateResponse.fromJson(Map<String, dynamic> json) {
    return DuplicateTemplateResponse(
      entityId: json['entity_id'] as String,
      entityType: TemplateEntityType.values.firstWhere(
        (e) => e.name == (json['entity_type'] ?? 'agent'),
        orElse: () => TemplateEntityType.agent,
      ),
    );
  }
}
