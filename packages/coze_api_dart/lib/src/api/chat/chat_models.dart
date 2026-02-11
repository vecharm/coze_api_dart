
/// Chat API 数据模型
///
/// 包含对话相关的所有数据模型定义
library;

import 'dart:convert';

import '../../models/enums.dart';

/// 消息对象
///
/// 表示对话中的一条消息
class Message {
  /// 消息 ID
  final String? id;

  /// 角色
  final RoleType role;

  /// 消息类型
  final MessageType? type;

  /// 内容
  final String content;

  /// 内容类型
  final ContentType contentType;

  /// 创建时间（Unix 时间戳，秒）
  final int? createdAt;

  /// 更新时间（Unix 时间戳，秒）
  final int? updatedAt;

  /// 创建消息的角色名称
  final String? roleType;

  /// 创建消息的 Bot ID
  final String? botId;

  /// 创建消息的 Chat ID
  final String? chatId;

  /// 创建消息的会话 ID
  final String? conversationId;

  /// 创建消息的内容类型
  final String? contentTypeStr;

  /// 创建消息的类型
  final String? typeStr;

  /// 附加文件
  final List<FileInfo>? fileInfos;

  /// 工具调用
  final List<ToolCall>? toolCalls;

  /// 工具调用 ID
  final String? toolCallId;

  /// 元数据
  final Map<String, dynamic>? metadata;

  /// 创建消息
  Message({
    this.id,
    required this.role,
    this.type,
    required this.content,
    this.contentType = ContentType.text,
    this.createdAt,
    this.updatedAt,
    this.roleType,
    this.botId,
    this.chatId,
    this.conversationId,
    this.contentTypeStr,
    this.typeStr,
    this.fileInfos,
    this.toolCalls,
    this.toolCallId,
    this.metadata,
  });

  /// 从 JSON 创建消息
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String?,
      role: RoleType.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => RoleType.user,
      ),
      type: json['type'] != null
          ? MessageType.values.firstWhere(
              (e) => e.name == json['type'],
              orElse: () => MessageType.answer,
            )
          : null,
      content: json['content'] as String? ?? '',
      contentType: ContentType.values.firstWhere(
        (e) => e.name == (json['content_type'] ?? 'text'),
        orElse: () => ContentType.text,
      ),
      createdAt: json['created_at'] as int?,
      updatedAt: json['updated_at'] as int?,
      roleType: json['role_type'] as String?,
      botId: json['bot_id'] as String?,
      chatId: json['chat_id'] as String?,
      conversationId: json['conversation_id'] as String?,
      contentTypeStr: json['content_type'] as String?,
      typeStr: json['type'] as String?,
      fileInfos: (json['file_infos'] as List<dynamic>?)
          ?.map((e) => FileInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
      toolCalls: (json['tool_calls'] as List<dynamic>?)
          ?.map((e) => ToolCall.fromJson(e as Map<String, dynamic>))
          .toList(),
      toolCallId: json['tool_call_id'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'role': role.name,
      if (type != null) 'type': type!.name,
      'content': content,
      'content_type': contentType.name,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (roleType != null) 'role_type': roleType,
      if (botId != null) 'bot_id': botId,
      if (chatId != null) 'chat_id': chatId,
      if (conversationId != null) 'conversation_id': conversationId,
      if (contentTypeStr != null) 'content_type': contentTypeStr,
      if (typeStr != null) 'type': typeStr,
      if (fileInfos != null)
        'file_infos': fileInfos!.map((e) => e.toJson()).toList(),
      if (toolCalls != null)
        'tool_calls': toolCalls!.map((e) => e.toJson()).toList(),
      if (toolCallId != null) 'tool_call_id': toolCallId,
      if (metadata != null) 'metadata': metadata,
    };
  }

  /// 创建用户消息
  factory Message.user({
    required String content,
    ContentType contentType = ContentType.text,
    List<FileInfo>? fileInfos,
    Map<String, dynamic>? metadata,
  }) {
    return Message(
      role: RoleType.user,
      content: content,
      contentType: contentType,
      fileInfos: fileInfos,
      metadata: metadata,
    );
  }

  /// 创建助手消息
  factory Message.assistant({
    required String content,
    ContentType contentType = ContentType.text,
    List<ToolCall>? toolCalls,
    Map<String, dynamic>? metadata,
  }) {
    return Message(
      role: RoleType.assistant,
      content: content,
      contentType: contentType,
      toolCalls: toolCalls,
      metadata: metadata,
    );
  }

  /// 创建系统消息
  factory Message.system({
    required String content,
    Map<String, dynamic>? metadata,
  }) {
    return Message(
      role: RoleType.system,
      content: content,
      metadata: metadata,
    );
  }

  /// 创建工具消息
  factory Message.tool({
    required String content,
    required String toolCallId,
    Map<String, dynamic>? metadata,
  }) {
    return Message(
      role: RoleType.tool,
      content: content,
      toolCallId: toolCallId,
      metadata: metadata,
    );
  }

  @override
  String toString() {
    final displayContent = content.length > 50
        ? '${content.substring(0, 50)}...'
        : content;
    return 'Message(role: ${role.name}, content: $displayContent)';
  }
}

/// 文件信息
class FileInfo {
  /// 文件 ID
  final String? id;

  /// 文件名称
  final String? name;

  /// 文件 URL
  final String? url;

  /// 文件类型
  final String? type;

  /// 文件大小（字节）
  final int? size;

  /// 创建时间
  final int? createdAt;

  FileInfo({
    this.id,
    this.name,
    this.url,
    this.type,
    this.size,
    this.createdAt,
  });

  factory FileInfo.fromJson(Map<String, dynamic> json) {
    return FileInfo(
      id: json['id'] as String?,
      name: json['name'] as String?,
      url: json['url'] as String?,
      type: json['type'] as String?,
      size: json['size'] as int?,
      createdAt: json['created_at'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (url != null) 'url': url,
      if (type != null) 'type': type,
      if (size != null) 'size': size,
      if (createdAt != null) 'created_at': createdAt,
    };
  }
}

/// 工具调用
class ToolCall {
  /// 工具调用 ID
  final String id;

  /// 工具类型
  final ToolCallType type;

  /// 功能调用详情
  final FunctionCall function;

  ToolCall({
    required this.id,
    this.type = ToolCallType.function,
    required this.function,
  });

  factory ToolCall.fromJson(Map<String, dynamic> json) {
    return ToolCall(
      id: json['id'] as String,
      type: ToolCallType.values.firstWhere(
        (e) => e.name == (json['type'] ?? 'function'),
        orElse: () => ToolCallType.function,
      ),
      function: FunctionCall.fromJson(json['function'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'function': function.toJson(),
    };
  }
}

/// 功能调用
class FunctionCall {
  /// 功能名称
  final String name;

  /// 功能参数（JSON 字符串）
  final String arguments;

  FunctionCall({
    required this.name,
    required this.arguments,
  });

  factory FunctionCall.fromJson(Map<String, dynamic> json) {
    return FunctionCall(
      name: json['name'] as String,
      arguments: json['arguments'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'arguments': arguments,
    };
  }

  /// 获取解析后的参数
  Map<String, dynamic> get parsedArguments {
    try {
      return jsonDecode(arguments) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }
}

/// 工具输出
class ToolOutput {
  /// 工具调用 ID
  final String toolCallId;

  /// 输出内容
  final String output;

  ToolOutput({
    required this.toolCallId,
    required this.output,
  });

  Map<String, dynamic> toJson() {
    return {
      'tool_call_id': toolCallId,
      'output': output,
    };
  }
}

/// 工具定义
class Tool {
  /// 工具类型，目前仅支持 function
  final String type;

  /// 功能定义
  final ToolFunction function;

  Tool({
    this.type = 'function',
    required this.function,
  });

  factory Tool.fromJson(Map<String, dynamic> json) {
    return Tool(
      type: json['type'] as String? ?? 'function',
      function: ToolFunction.fromJson(json['function'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'function': function.toJson(),
    };
  }
}

/// 工具功能定义
class ToolFunction {
  /// 功能名称
  final String name;

  /// 功能描述
  final String? description;

  /// 功能参数定义（JSON Schema 格式）
  final Map<String, dynamic>? parameters;

  ToolFunction({
    required this.name,
    this.description,
    this.parameters,
  });

  factory ToolFunction.fromJson(Map<String, dynamic> json) {
    return ToolFunction(
      name: json['name'] as String,
      description: json['description'] as String?,
      parameters: json['parameters'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (description != null) 'description': description,
      if (parameters != null) 'parameters': parameters,
    };
  }
}

/// 对话对象
class Chat {
  /// 对话 ID
  final String id;

  /// 会话 ID
  final String conversationId;

  /// Bot ID
  final String? botId;

  /// 运行 ID
  final String? runId;

  /// 用户 ID
  final String? userId;

  /// 对话状态
  final ChatStatus status;

  /// 创建时间（Unix 时间戳，秒）
  final int? createdAt;

  /// 更新时间（Unix 时间戳，秒）
  final int? updatedAt;

  /// 完成时间（Unix 时间戳，秒）
  final int? completedAt;

  /// 失败时间（Unix 时间戳，秒）
  final int? failedAt;

  /// 额外字段
  final Map<String, dynamic>? extra;

  /// 元数据
  final Map<String, dynamic>? metadata;

  /// 最后错误信息
  final String? lastError;

  /// 所需操作
  final RequiredAction? requiredAction;

  /// 使用统计
  final TokenUsage? usage;

  /// 对话中的消息数量
  final int? messageCount;

  Chat({
    required this.id,
    required this.conversationId,
    this.botId,
    this.runId,
    this.userId,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.completedAt,
    this.failedAt,
    this.extra,
    this.metadata,
    this.lastError,
    this.requiredAction,
    this.usage,
    this.messageCount,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'] as String,
      conversationId: json['conversation_id'] as String,
      botId: json['bot_id'] as String?,
      runId: json['run_id'] as String?,
      userId: json['user_id'] as String?,
      status: ChatStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ChatStatus.created,
      ),
      createdAt: json['created_at'] as int?,
      updatedAt: json['updated_at'] as int?,
      completedAt: json['completed_at'] as int?,
      failedAt: json['failed_at'] as int?,
      extra: json['extra'] as Map<String, dynamic>?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      lastError: json['last_error'] as String?,
      requiredAction: json['required_action'] != null
          ? RequiredAction.fromJson(
              json['required_action'] as Map<String, dynamic>)
          : null,
      usage: json['usage'] != null
          ? TokenUsage.fromJson(json['usage'] as Map<String, dynamic>)
          : null,
      messageCount: json['message_count'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_id': conversationId,
      if (botId != null) 'bot_id': botId,
      if (runId != null) 'run_id': runId,
      if (userId != null) 'user_id': userId,
      'status': status.name,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (failedAt != null) 'failed_at': failedAt,
      if (extra != null) 'extra': extra,
      if (metadata != null) 'metadata': metadata,
      if (lastError != null) 'last_error': lastError,
      if (requiredAction != null) 'required_action': requiredAction!.toJson(),
      if (usage != null) 'usage': usage!.toJson(),
      if (messageCount != null) 'message_count': messageCount,
    };
  }

  /// 检查对话是否已完成
  bool get isCompleted => status == ChatStatus.completed;

  /// 检查对话是否失败
  bool get isFailed => status == ChatStatus.failed;

  /// 检查对话是否需要操作
  bool get requiresAction => status == ChatStatus.requiresAction;
}

/// 所需操作
class RequiredAction {
  /// 操作类型
  final String type;

  /// 提交工具输出的信息
  final SubmitToolOutputs? submitToolOutputs;

  RequiredAction({
    required this.type,
    this.submitToolOutputs,
  });

  factory RequiredAction.fromJson(Map<String, dynamic> json) {
    return RequiredAction(
      type: json['type'] as String,
      submitToolOutputs: json['submit_tool_outputs'] != null
          ? SubmitToolOutputs.fromJson(
              json['submit_tool_outputs'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      if (submitToolOutputs != null)
        'submit_tool_outputs': submitToolOutputs!.toJson(),
    };
  }
}

/// 提交工具输出
class SubmitToolOutputs {
  /// 工具调用列表
  final List<ToolCall> toolCalls;

  SubmitToolOutputs({
    required this.toolCalls,
  });

  factory SubmitToolOutputs.fromJson(Map<String, dynamic> json) {
    return SubmitToolOutputs(
      toolCalls: (json['tool_calls'] as List<dynamic>)
          .map((e) => ToolCall.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tool_calls': toolCalls.map((e) => e.toJson()).toList(),
    };
  }
}

/// Token 使用统计
class TokenUsage {
  /// 输入 Token 数量
  final int inputCount;

  /// 输出 Token 数量
  final int outputCount;

  /// 总 Token 数量
  final int tokenCount;

  /// 输入 Token 详情
  final Map<String, dynamic>? inputCountDetail;

  /// 输出 Token 详情
  final Map<String, dynamic>? outputCountDetail;

  TokenUsage({
    required this.inputCount,
    required this.outputCount,
    required this.tokenCount,
    this.inputCountDetail,
    this.outputCountDetail,
  });

  factory TokenUsage.fromJson(Map<String, dynamic> json) {
    return TokenUsage(
      inputCount: json['input_count'] as int? ?? 0,
      outputCount: json['output_count'] as int? ?? 0,
      tokenCount: json['token_count'] as int? ?? 0,
      inputCountDetail: json['input_count_detail'] as Map<String, dynamic>?,
      outputCountDetail: json['output_count_detail'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'input_count': inputCount,
      'output_count': outputCount,
      'token_count': tokenCount,
      if (inputCountDetail != null) 'input_count_detail': inputCountDetail,
      if (outputCountDetail != null) 'output_count_detail': outputCountDetail,
    };
  }
}

/// 创建对话请求
class CreateChatRequest {
  /// Bot ID
  final String botId;

  /// 用户 ID
  final String? userId;

  /// 会话 ID，用于继续已有会话
  final String? conversationId;

  /// 额外消息列表
  final List<Message>? additionalMessages;

  /// 是否流式响应
  final bool? stream;

  /// 自定义变量
  final Map<String, dynamic>? customVariables;

  /// 是否自动保存历史
  final bool? autoSaveHistory;

  /// 元数据
  final Map<String, dynamic>? metaData;

  /// 插件列表
  final List<String>? plugins;

  /// 工具选择策略
  /// - none: 不调用工具
  /// - auto: 自动选择（默认）
  /// - required: 必须调用工具
  final ToolChoiceType? toolChoice;

  /// 工具定义列表
  final List<Tool>? tools;

  /// 额外参数
  final Map<String, dynamic>? extraParams;

  /// 空间 ID，用于访问特定空间下的 Bot
  final String? spaceId;

  /// 消息内容类型
  /// - text: 纯文本
  /// - object_string: 富文本
  /// - card: 卡片
  final ContentType? contentType;

  CreateChatRequest({
    required this.botId,
    this.userId,
    this.conversationId,
    this.additionalMessages,
    this.stream,
    this.customVariables,
    this.autoSaveHistory,
    this.metaData,
    this.plugins,
    this.toolChoice,
    this.tools,
    this.extraParams,
    this.spaceId,
    this.contentType,
  });

  Map<String, dynamic> toJson() {
    return {
      'bot_id': botId,
      if (userId != null) 'user_id': userId,
      if (conversationId != null) 'conversation_id': conversationId,
      if (additionalMessages != null)
        'additional_messages': additionalMessages!.map((e) => e.toJson()).toList(),
      if (stream != null) 'stream': stream,
      if (customVariables != null) 'custom_variables': customVariables,
      if (autoSaveHistory != null) 'auto_save_history': autoSaveHistory,
      if (metaData != null) 'meta_data': metaData,
      if (plugins != null) 'plugins': plugins,
      if (toolChoice != null) 'tool_choice': toolChoice!.name,
      if (tools != null) 'tools': tools!.map((e) => e.toJson()).toList(),
      if (extraParams != null) 'extra_params': extraParams,
      if (spaceId != null) 'space_id': spaceId,
      if (contentType != null) 'content_type': contentType!.name,
    };
  }
}

/// 对话结果
class ChatResult {
  /// 对话信息
  final Chat chat;

  /// 消息列表
  final List<Message> messages;

  ChatResult({
    required this.chat,
    required this.messages,
  });

  factory ChatResult.fromJson(Map<String, dynamic> json) {
    return ChatResult(
      chat: Chat.fromJson(json['chat'] as Map<String, dynamic>),
      messages: (json['messages'] as List<dynamic>?)
              ?.map((e) => Message.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chat': chat.toJson(),
      'messages': messages.map((e) => e.toJson()).toList(),
    };
  }
}

/// 流式事件
class ChatEvent {
  /// 事件类型
  final ChatEventType event;

  /// 事件数据
  final Map<String, dynamic> data;

  /// 消息（如果是消息相关事件）
  final Message? message;

  /// 对话（如果是对话相关事件）
  final Chat? chat;

  ChatEvent({
    required this.event,
    required this.data,
    this.message,
    this.chat,
  });

  factory ChatEvent.fromJson(Map<String, dynamic> json) {
    final eventType = ChatEventType.values.firstWhere(
      (e) => e.name == json['event'],
      orElse: () => ChatEventType.error,
    );

    return ChatEvent(
      event: eventType,
      data: json['data'] as Map<String, dynamic>? ?? {},
      message: json['message'] != null
          ? Message.fromJson(json['message'] as Map<String, dynamic>)
          : null,
      chat: json['chat'] != null
          ? Chat.fromJson(json['chat'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  String toString() {
    return 'ChatEvent(event: ${event.name}, data: $data)';
  }
}

/// 提交工具输出请求
class SubmitToolOutputsRequest {
  /// 工具输出列表
  final List<ToolOutput> toolOutputs;

  /// 是否流式响应
  final bool? stream;

  SubmitToolOutputsRequest({
    required this.toolOutputs,
    this.stream,
  });

  Map<String, dynamic> toJson() {
    return {
      'tool_outputs': toolOutputs.map((e) => e.toJson()).toList(),
      if (stream != null) 'stream': stream,
    };
  }
}
