/// Bot 管理 API 数据模型
///
/// 包含 Bot 相关的所有数据模型定义
library;

/// Bot 对象
///
/// 表示一个 Coze Bot
class Bot {
  /// Bot ID
  final String id;

  /// Bot 名称
  final String name;

  /// Bot 描述
  final String? description;

  /// Bot 头像 URL
  final String? iconUrl;

  /// 创建时间（Unix 时间戳，秒）
  final int? createdAt;

  /// 更新时间（Unix 时间戳，秒）
  final int? updatedAt;

  /// 发布版本
  final String? version;

  /// 提示词
  final String? promptInfo;

  /// 开场白
  final String? onboardingInfo;

  /// Bot 模式
  final String? botMode;

  /// 插件列表
  final List<BotPlugin>? plugins;

  /// 模型配置
  final BotModelInfo? modelInfo;

  /// 知识库配置
  final BotKnowledge? knowledge;

  /// 工作流配置
  final List<BotWorkflow>? workflows;

  /// 是否已发布
  final bool? isPublished;

  /// 发布时间
  final int? publishTime;

  Bot({
    required this.id,
    required this.name,
    this.description,
    this.iconUrl,
    this.createdAt,
    this.updatedAt,
    this.version,
    this.promptInfo,
    this.onboardingInfo,
    this.botMode,
    this.plugins,
    this.modelInfo,
    this.knowledge,
    this.workflows,
    this.isPublished,
    this.publishTime,
  });

  factory Bot.fromJson(Map<String, dynamic> json) {
    return Bot(
      id: json['bot_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      iconUrl: json['icon_url'] as String?,
      createdAt: json['create_time'] as int?,
      updatedAt: json['update_time'] as int?,
      version: json['version'] as String?,
      promptInfo: json['prompt_info'] as String?,
      onboardingInfo: json['onboarding_info'] as String?,
      botMode: json['bot_mode'] as String?,
      plugins: (json['plugin_info_list'] as List<dynamic>?)
          ?.map((e) => BotPlugin.fromJson(e as Map<String, dynamic>))
          .toList(),
      modelInfo: json['model_info'] != null
          ? BotModelInfo.fromJson(json['model_info'] as Map<String, dynamic>)
          : null,
      knowledge: json['knowledge_info'] != null
          ? BotKnowledge.fromJson(
              json['knowledge_info'] as Map<String, dynamic>)
          : null,
      workflows: (json['workflow_info_list'] as List<dynamic>?)
          ?.map((e) => BotWorkflow.fromJson(e as Map<String, dynamic>))
          .toList(),
      isPublished: json['is_published'] as bool?,
      publishTime: json['publish_time'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bot_id': id,
      'name': name,
      if (description != null) 'description': description,
      if (iconUrl != null) 'icon_url': iconUrl,
      if (createdAt != null) 'create_time': createdAt,
      if (updatedAt != null) 'update_time': updatedAt,
      if (version != null) 'version': version,
      if (promptInfo != null) 'prompt_info': promptInfo,
      if (onboardingInfo != null) 'onboarding_info': onboardingInfo,
      if (botMode != null) 'bot_mode': botMode,
      if (plugins != null)
        'plugin_info_list': plugins!.map((e) => e.toJson()).toList(),
      if (modelInfo != null) 'model_info': modelInfo!.toJson(),
      if (knowledge != null) 'knowledge_info': knowledge!.toJson(),
      if (workflows != null)
        'workflow_info_list': workflows!.map((e) => e.toJson()).toList(),
      if (isPublished != null) 'is_published': isPublished,
      if (publishTime != null) 'publish_time': publishTime,
    };
  }
}

/// Bot 插件
class BotPlugin {
  /// 插件 ID
  final String id;

  /// 插件名称
  final String name;

  /// 插件描述
  final String? description;

  /// 插件图标
  final String? iconUrl;

  BotPlugin({
    required this.id,
    required this.name,
    this.description,
    this.iconUrl,
  });

  factory BotPlugin.fromJson(Map<String, dynamic> json) {
    return BotPlugin(
      id: json['plugin_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      iconUrl: json['icon_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plugin_id': id,
      'name': name,
      if (description != null) 'description': description,
      if (iconUrl != null) 'icon_url': iconUrl,
    };
  }
}

/// Bot 模型信息
class BotModelInfo {
  /// 模型 ID
  final String modelId;

  /// 模型名称
  final String? modelName;

  /// 温度参数
  final double? temperature;

  /// 最大 Token 数
  final int? maxTokens;

  /// Top P
  final double? topP;

  BotModelInfo({
    required this.modelId,
    this.modelName,
    this.temperature,
    this.maxTokens,
    this.topP,
  });

  factory BotModelInfo.fromJson(Map<String, dynamic> json) {
    return BotModelInfo(
      modelId: json['model_id'] as String,
      modelName: json['model_name'] as String?,
      temperature: json['temperature'] as double?,
      maxTokens: json['max_tokens'] as int?,
      topP: json['top_p'] as double?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'model_id': modelId,
      if (modelName != null) 'model_name': modelName,
      if (temperature != null) 'temperature': temperature,
      if (maxTokens != null) 'max_tokens': maxTokens,
      if (topP != null) 'top_p': topP,
    };
  }
}

/// Bot 知识库配置
class BotKnowledge {
  /// 知识库列表
  final List<BotKnowledgeItem>? items;

  BotKnowledge({this.items});

  factory BotKnowledge.fromJson(Map<String, dynamic> json) {
    return BotKnowledge(
      items: (json['dataset_infos'] as List<dynamic>?)
          ?.map((e) => BotKnowledgeItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (items != null)
        'dataset_infos': items!.map((e) => e.toJson()).toList(),
    };
  }
}

/// Bot 知识库项
class BotKnowledgeItem {
  /// 知识库 ID
  final String id;

  /// 知识库名称
  final String? name;

  BotKnowledgeItem({
    required this.id,
    this.name,
  });

  factory BotKnowledgeItem.fromJson(Map<String, dynamic> json) {
    return BotKnowledgeItem(
      id: json['dataset_id'] as String,
      name: json['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dataset_id': id,
      if (name != null) 'name': name,
    };
  }
}

/// Bot 工作流
class BotWorkflow {
  /// 工作流 ID
  final String id;

  /// 工作流名称
  final String? name;

  BotWorkflow({
    required this.id,
    this.name,
  });

  factory BotWorkflow.fromJson(Map<String, dynamic> json) {
    return BotWorkflow(
      id: json['workflow_id'] as String,
      name: json['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'workflow_id': id,
      if (name != null) 'name': name,
    };
  }
}

/// 获取 Bot 列表请求
class ListBotsRequest {
  /// 分页大小，默认 20
  final int? pageSize;

  /// 分页游标
  final String? cursor;

  /// 排序方式
  final String? order;

  /// 空间 ID，用于筛选特定空间下的 Bot
  final String? spaceId;

  ListBotsRequest({
    this.pageSize,
    this.cursor,
    this.order,
    this.spaceId,
  });

  Map<String, dynamic> toJson() {
    return {
      if (pageSize != null) 'page_size': pageSize,
      if (cursor != null) 'cursor': cursor,
      if (order != null) 'order': order,
      if (spaceId != null) 'space_id': spaceId,
    };
  }
}

/// Bot 列表响应
class ListBotsResponse {
  /// Bot 列表
  final List<Bot> bots;

  /// 分页信息
  final BotPagination? pagination;

  ListBotsResponse({
    required this.bots,
    this.pagination,
  });

  factory ListBotsResponse.fromJson(Map<String, dynamic> json) {
    return ListBotsResponse(
      bots: (json['data'] as List<dynamic>?)
              ?.map((e) => Bot.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      pagination: json['pagination'] != null
          ? BotPagination.fromJson(json['pagination'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// Bot 分页信息
class BotPagination {
  /// 分页游标
  final String? cursor;

  /// 是否有更多数据
  final bool hasMore;

  /// 总数
  final int? total;

  BotPagination({
    this.cursor,
    required this.hasMore,
    this.total,
  });

  factory BotPagination.fromJson(Map<String, dynamic> json) {
    return BotPagination(
      cursor: json['cursor'] as String?,
      hasMore: json['has_more'] as bool? ?? false,
      total: json['total'] as int?,
    );
  }
}

/// 发布 Bot 请求
class PublishBotRequest {
  /// Bot ID
  final String botId;

  /// 发布设置
  final BotPublishSettings? settings;

  PublishBotRequest({
    required this.botId,
    this.settings,
  });

  Map<String, dynamic> toJson() {
    return {
      'bot_id': botId,
      if (settings != null) 'settings': settings!.toJson(),
    };
  }
}

/// Bot 发布设置
class BotPublishSettings {
  /// 发布渠道
  final List<String>? connectorIds;

  BotPublishSettings({
    this.connectorIds,
  });

  Map<String, dynamic> toJson() {
    return {
      if (connectorIds != null) 'connector_ids': connectorIds,
    };
  }
}

/// 创建 Bot 请求
class CreateBotRequest {
  /// 空间 ID
  final String spaceId;

  /// Bot 名称
  final String name;

  /// Bot 描述
  final String? description;

  /// 头像文件 ID
  final String? iconFileId;

  /// 提示词配置
  final BotPromptInfo? promptInfo;

  /// 开场白配置
  final BotOnboardingInfo? onboardingInfo;

  /// 插件列表
  final List<PluginIdInfo>? pluginIdList;

  /// 工作流列表
  final List<WorkflowIdInfo>? workflowIdList;

  /// 模型配置
  final BotModelInfoConfig? modelInfoConfig;

  /// 建议回复配置
  final SuggestReplyInfo? suggestReplyInfo;

  CreateBotRequest({
    required this.spaceId,
    required this.name,
    this.description,
    this.iconFileId,
    this.promptInfo,
    this.onboardingInfo,
    this.pluginIdList,
    this.workflowIdList,
    this.modelInfoConfig,
    this.suggestReplyInfo,
  });

  Map<String, dynamic> toJson() {
    return {
      'space_id': spaceId,
      'name': name,
      if (description != null) 'description': description,
      if (iconFileId != null) 'icon_file_id': iconFileId,
      if (promptInfo != null) 'prompt_info': promptInfo!.toJson(),
      if (onboardingInfo != null) 'onboarding_info': onboardingInfo!.toJson(),
      if (pluginIdList != null)
        'plugin_id_list': {
          'id_list': pluginIdList!.map((e) => e.toJson()).toList()
        },
      if (workflowIdList != null)
        'workflow_id_list': {
          'ids': workflowIdList!.map((e) => e.toJson()).toList()
        },
      if (modelInfoConfig != null)
        'model_info_config': modelInfoConfig!.toJson(),
      if (suggestReplyInfo != null)
        'suggest_reply_info': suggestReplyInfo!.toJson(),
    };
  }
}

/// 创建 Bot 响应
class CreateBotResponse {
  /// Bot ID
  final String botId;

  CreateBotResponse({required this.botId});

  factory CreateBotResponse.fromJson(Map<String, dynamic> json) {
    return CreateBotResponse(
      botId: json['bot_id'] as String,
    );
  }
}

/// 更新 Bot 请求
class UpdateBotRequest {
  /// Bot ID
  final String botId;

  /// Bot 名称
  final String? name;

  /// Bot 描述
  final String? description;

  /// 头像文件 ID
  final String? iconFileId;

  /// 提示词配置
  final BotPromptInfo? promptInfo;

  /// 开场白配置
  final BotOnboardingInfo? onboardingInfo;

  /// 知识库配置
  final BotKnowledgeInfo? knowledge;

  /// 插件列表
  final List<PluginIdInfo>? pluginIdList;

  /// 工作流列表
  final List<WorkflowIdInfo>? workflowIdList;

  /// 模型配置
  final BotModelInfoConfig? modelInfoConfig;

  /// 建议回复配置
  final SuggestReplyInfo? suggestReplyInfo;

  UpdateBotRequest({
    required this.botId,
    this.name,
    this.description,
    this.iconFileId,
    this.promptInfo,
    this.onboardingInfo,
    this.knowledge,
    this.pluginIdList,
    this.workflowIdList,
    this.modelInfoConfig,
    this.suggestReplyInfo,
  });

  Map<String, dynamic> toJson() {
    return {
      'bot_id': botId,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (iconFileId != null) 'icon_file_id': iconFileId,
      if (promptInfo != null) 'prompt_info': promptInfo!.toJson(),
      if (onboardingInfo != null) 'onboarding_info': onboardingInfo!.toJson(),
      if (knowledge != null) 'knowledge': knowledge!.toJson(),
      if (pluginIdList != null)
        'plugin_id_list': {
          'id_list': pluginIdList!.map((e) => e.toJson()).toList()
        },
      if (workflowIdList != null)
        'workflow_id_list': {
          'ids': workflowIdList!.map((e) => e.toJson()).toList()
        },
      if (modelInfoConfig != null)
        'model_info_config': modelInfoConfig!.toJson(),
      if (suggestReplyInfo != null)
        'suggest_reply_info': suggestReplyInfo!.toJson(),
    };
  }
}

/// Bot 提示词信息
class BotPromptInfo {
  /// 提示词内容
  final String prompt;

  BotPromptInfo({required this.prompt});

  Map<String, dynamic> toJson() {
    return {'prompt': prompt};
  }
}

/// Bot 开场白信息
class BotOnboardingInfo {
  /// 开场白内容
  final String prologue;

  /// 建议问题列表
  final List<String>? suggestedQuestions;

  BotOnboardingInfo({
    required this.prologue,
    this.suggestedQuestions,
  });

  Map<String, dynamic> toJson() {
    return {
      'prologue': prologue,
      if (suggestedQuestions != null) 'suggested_questions': suggestedQuestions,
    };
  }
}

/// 插件 ID 信息
class PluginIdInfo {
  /// 插件 ID
  final String pluginId;

  /// API ID
  final String? apiId;

  PluginIdInfo({
    required this.pluginId,
    this.apiId,
  });

  Map<String, dynamic> toJson() {
    return {
      'plugin_id': pluginId,
      if (apiId != null) 'api_id': apiId,
    };
  }
}

/// 工作流 ID 信息
class WorkflowIdInfo {
  /// 工作流 ID
  final String id;

  WorkflowIdInfo({required this.id});

  Map<String, dynamic> toJson() {
    return {'id': id};
  }
}

/// Bot 模型配置
class BotModelInfoConfig {
  /// 模型 ID
  final String modelId;

  /// Top K
  final int? topK;

  /// Top P
  final double? topP;

  /// 最大 Token 数
  final int? maxTokens;

  /// 温度
  final double? temperature;

  /// 上下文轮数
  final int? contextRound;

  /// 输出格式
  final String? responseFormat;

  /// 主题重复惩罚
  final double? presencePenalty;

  /// 语句重复惩罚
  final double? frequencyPenalty;

  BotModelInfoConfig({
    required this.modelId,
    this.topK,
    this.topP,
    this.maxTokens,
    this.temperature,
    this.contextRound,
    this.responseFormat,
    this.presencePenalty,
    this.frequencyPenalty,
  });

  Map<String, dynamic> toJson() {
    return {
      'model_id': modelId,
      if (topK != null) 'top_k': topK,
      if (topP != null) 'top_p': topP,
      if (maxTokens != null) 'max_tokens': maxTokens,
      if (temperature != null) 'temperature': temperature,
      if (contextRound != null) 'context_round': contextRound,
      if (responseFormat != null) 'response_format': responseFormat,
      if (presencePenalty != null) 'presence_penalty': presencePenalty,
      if (frequencyPenalty != null) 'frequency_penalty': frequencyPenalty,
    };
  }
}

/// 建议回复配置
class SuggestReplyInfo {
  /// 回复模式
  final SuggestReplyMode replyMode;

  /// 自定义提示词
  final String? customizedPrompt;

  SuggestReplyInfo({
    required this.replyMode,
    this.customizedPrompt,
  });

  Map<String, dynamic> toJson() {
    return {
      'reply_mode': replyMode.name,
      if (customizedPrompt != null) 'customized_prompt': customizedPrompt,
    };
  }
}

/// 建议回复模式
enum SuggestReplyMode {
  /// 禁用
  disable,

  /// 启用
  enable,

  /// 自定义
  customized,
}

/// Bot 知识库信息
class BotKnowledgeInfo {
  /// 数据集 ID 列表
  final List<String>? datasetIds;

  /// 是否自动调用
  final bool? autoCall;

  /// 搜索策略
  final int? searchStrategy;

  BotKnowledgeInfo({
    this.datasetIds,
    this.autoCall,
    this.searchStrategy,
  });

  Map<String, dynamic> toJson() {
    return {
      if (datasetIds != null) 'dataset_ids': datasetIds,
      if (autoCall != null) 'auto_call': autoCall,
      if (searchStrategy != null) 'search_strategy': searchStrategy,
    };
  }
}

/// 新版列出 Bot 请求
class ListBotsNewRequest {
  /// 工作空间 ID
  final String? workspaceId;

  /// 发布状态
  /// - all: 所有状态
  /// - published_online: 已发布的正式版
  /// - published_draft: 已发布但当前为草稿状态
  /// - unpublished_draft: 从未发布过
  final String? publishStatus;

  /// 渠道 ID
  final String? connectorId;

  /// 分页大小
  final int? pageSize;

  /// 页码
  final int? pageNum;

  ListBotsNewRequest({
    this.workspaceId,
    this.publishStatus,
    this.connectorId,
    this.pageSize,
    this.pageNum,
  });

  Map<String, dynamic> toJson() {
    return {
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (publishStatus != null) 'publish_status': publishStatus,
      if (connectorId != null) 'connector_id': connectorId,
      if (pageSize != null) 'page_size': pageSize,
      if (pageNum != null) 'page_num': pageNum,
    };
  }
}

/// 新版 Bot 列表响应
class ListBotsNewResponse {
  /// 总数
  final int total;

  /// Bot 列表
  final List<BotInfo> items;

  ListBotsNewResponse({
    required this.total,
    required this.items,
  });

  factory ListBotsNewResponse.fromJson(Map<String, dynamic> json) {
    return ListBotsNewResponse(
      total: json['total'] as int,
      items: (json['items'] as List<dynamic>)
          .map((e) => BotInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Bot 信息（新版列表）
class BotInfo {
  /// Bot ID
  final String id;

  /// Bot 名称
  final String name;

  /// 图标 URL
  final String iconUrl;

  /// 更新时间
  final int updatedAt;

  /// 描述
  final String description;

  /// 是否已发布
  final bool isPublished;

  /// 发布时间
  final int? publishedAt;

  /// 创建者用户 ID
  final String ownerUserId;

  BotInfo({
    required this.id,
    required this.name,
    required this.iconUrl,
    required this.updatedAt,
    required this.description,
    required this.isPublished,
    this.publishedAt,
    required this.ownerUserId,
  });

  factory BotInfo.fromJson(Map<String, dynamic> json) {
    return BotInfo(
      id: json['id'] as String,
      name: json['name'] as String,
      iconUrl: json['icon_url'] as String,
      updatedAt: json['updated_at'] as int,
      description: json['description'] as String,
      isPublished: json['is_published'] as bool,
      publishedAt: json['published_at'] as int?,
      ownerUserId: json['owner_user_id'] as String,
    );
  }
}

/// 新版获取 Bot 请求
class RetrieveBotNewRequest {
  /// 是否已发布
  final bool? isPublished;

  RetrieveBotNewRequest({this.isPublished});

  Map<String, dynamic> toJson() {
    return {
      if (isPublished != null) 'is_published': isPublished,
    };
  }
}
