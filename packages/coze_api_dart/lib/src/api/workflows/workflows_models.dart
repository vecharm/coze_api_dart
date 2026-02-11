/// 工作流 API 数据模型
///
/// 包含工作流相关的所有数据模型定义
library;

import '../../models/enums.dart';

/// 工作流执行请求
class WorkflowRunRequest {
  /// 工作流 ID
  final String workflowId;

  /// 工作流版本（可选，不传则使用最新版本）
  final String? version;

  /// Bot ID（可选，用于获取 Bot 配置）
  final String? botId;

  /// 输入参数
  final Map<String, dynamic>? parameters;

  /// 执行模式
  /// - synchronous: 同步执行
  /// - asynchronous: 异步执行
  final String? executeMode;

  /// 是否流式返回
  final bool? isStream;

  /// 额外的 HTTP 头
  final Map<String, String>? extHeaders;

  WorkflowRunRequest({
    required this.workflowId,
    this.version,
    this.botId,
    this.parameters,
    this.executeMode,
    this.isStream,
    this.extHeaders,
  });

  Map<String, dynamic> toJson() {
    return {
      'workflow_id': workflowId,
      if (version != null) 'version': version,
      if (botId != null) 'bot_id': botId,
      if (parameters != null) 'parameters': parameters,
      if (executeMode != null) 'execute_mode': executeMode,
      if (isStream != null) 'is_stream': isStream,
    };
  }
}

/// 工作流执行响应
class WorkflowRunResponse {
  /// 执行 ID
  final String executeId;

  /// 执行状态
  final WorkflowStatus status;

  /// 输出数据
  final Map<String, dynamic>? data;

  /// 调试 URL
  final String? debugUrl;

  /// 耗时（毫秒）
  final int? cost;

  /// 令牌使用
  final WorkflowTokenUsage? tokenUsage;

  /// 错误信息
  final String? errorMessage;

  WorkflowRunResponse({
    required this.executeId,
    required this.status,
    this.data,
    this.debugUrl,
    this.cost,
    this.tokenUsage,
    this.errorMessage,
  });

  factory WorkflowRunResponse.fromJson(Map<String, dynamic> json) {
    return WorkflowRunResponse(
      executeId: json['execute_id'] as String,
      status: WorkflowStatus.values.firstWhere(
        (e) => e.name == (json['status'] ?? 'running'),
        orElse: () => WorkflowStatus.running,
      ),
      data: json['data'] as Map<String, dynamic>?,
      debugUrl: json['debug_url'] as String?,
      cost: json['cost'] as int?,
      tokenUsage: json['token_usage'] != null
          ? WorkflowTokenUsage.fromJson(
              json['token_usage'] as Map<String, dynamic>)
          : null,
      errorMessage: json['error_message'] as String?,
    );
  }
}

/// 工作流令牌使用统计
class WorkflowTokenUsage {
  /// 输入 Token 数
  final int inputCount;

  /// 输出 Token 数
  final int outputCount;

  /// 总 Token 数
  final int totalCount;

  WorkflowTokenUsage({
    required this.inputCount,
    required this.outputCount,
    required this.totalCount,
  });

  factory WorkflowTokenUsage.fromJson(Map<String, dynamic> json) {
    return WorkflowTokenUsage(
      inputCount: json['input_count'] as int? ?? 0,
      outputCount: json['output_count'] as int? ?? 0,
      totalCount: json['total_count'] as int? ?? 0,
    );
  }
}

/// 工作流执行结果查询请求
class WorkflowRunResultRequest {
  /// 执行 ID
  final String executeId;

  WorkflowRunResultRequest({
    required this.executeId,
  });

  Map<String, dynamic> toJson() {
    return {
      'execute_id': executeId,
    };
  }
}

/// 工作流执行结果
class WorkflowRunResult {
  /// 执行 ID
  final String executeId;

  /// 执行状态
  final WorkflowStatus status;

  /// 输出数据
  final Map<String, dynamic>? data;

  /// 开始时间
  final int? startTime;

  /// 结束时间
  final int? endTime;

  /// 耗时（毫秒）
  final int? cost;

  /// 令牌使用
  final WorkflowTokenUsage? tokenUsage;

  /// 错误信息
  final String? errorMessage;

  WorkflowRunResult({
    required this.executeId,
    required this.status,
    this.data,
    this.startTime,
    this.endTime,
    this.cost,
    this.tokenUsage,
    this.errorMessage,
  });

  factory WorkflowRunResult.fromJson(Map<String, dynamic> json) {
    return WorkflowRunResult(
      executeId: json['execute_id'] as String,
      status: WorkflowStatus.values.firstWhere(
        (e) => e.name == (json['status'] ?? 'running'),
        orElse: () => WorkflowStatus.running,
      ),
      data: json['data'] as Map<String, dynamic>?,
      startTime: json['start_time'] as int?,
      endTime: json['end_time'] as int?,
      cost: json['cost'] as int?,
      tokenUsage: json['token_usage'] != null
          ? WorkflowTokenUsage.fromJson(
              json['token_usage'] as Map<String, dynamic>)
          : null,
      errorMessage: json['error_message'] as String?,
    );
  }
}

/// 工作流事件（流式响应）
class WorkflowEvent {
  /// 事件 ID
  final String id;

  /// 事件类型
  final String event;

  /// 事件数据
  final Map<String, dynamic> data;

  /// 工作流节点名称
  final String? nodeName;

  /// 工作流节点类型
  final String? nodeType;

  /// 节点执行状态
  final String? nodeStatus;

  /// 节点输出
  final Map<String, dynamic>? nodeOutputs;

  WorkflowEvent({
    required this.id,
    required this.event,
    required this.data,
    this.nodeName,
    this.nodeType,
    this.nodeStatus,
    this.nodeOutputs,
  });

  factory WorkflowEvent.fromJson(Map<String, dynamic> json) {
    return WorkflowEvent(
      id: json['id'] as String? ?? '',
      event: json['event'] as String,
      data: json['data'] as Map<String, dynamic>? ?? {},
      nodeName: json['node_name'] as String?,
      nodeType: json['node_type'] as String?,
      nodeStatus: json['node_status'] as String?,
      nodeOutputs: json['node_outputs'] as Map<String, dynamic>?,
    );
  }
}

/// 工作流对象
class Workflow {
  /// 工作流 ID
  final String id;

  /// 工作流名称
  final String name;

  /// 工作流描述
  final String? description;

  /// 创建时间
  final int? createdAt;

  /// 更新时间
  final int? updatedAt;

  /// 最新版本
  final String? latestVersion;

  Workflow({
    required this.id,
    required this.name,
    this.description,
    this.createdAt,
    this.updatedAt,
    this.latestVersion,
  });

  factory Workflow.fromJson(Map<String, dynamic> json) {
    return Workflow(
      id: json['workflow_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      createdAt: json['create_time'] as int?,
      updatedAt: json['update_time'] as int?,
      latestVersion: json['latest_version'] as String?,
    );
  }
}

/// 列出工作流请求
class ListWorkflowsRequest {
  /// Bot ID
  final String? botId;

  /// 分页大小
  final int? pageSize;

  /// 分页游标
  final String? cursor;

  ListWorkflowsRequest({
    this.botId,
    this.pageSize,
    this.cursor,
  });

  Map<String, dynamic> toJson() {
    return {
      if (botId != null) 'bot_id': botId,
      if (pageSize != null) 'page_size': pageSize,
      if (cursor != null) 'cursor': cursor,
    };
  }
}

/// 工作流列表响应
class ListWorkflowsResponse {
  /// 工作流列表
  final List<Workflow> workflows;

  /// 分页信息
  final WorkflowPagination? pagination;

  ListWorkflowsResponse({
    required this.workflows,
    this.pagination,
  });

  factory ListWorkflowsResponse.fromJson(Map<String, dynamic> json) {
    return ListWorkflowsResponse(
      workflows: (json['data'] as List<dynamic>?)
              ?.map((e) => Workflow.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      pagination: json['pagination'] != null
          ? WorkflowPagination.fromJson(
              json['pagination'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// 工作流分页信息
class WorkflowPagination {
  /// 分页游标
  final String? cursor;

  /// 是否有更多数据
  final bool hasMore;

  /// 总数
  final int? total;

  WorkflowPagination({
    this.cursor,
    required this.hasMore,
    this.total,
  });

  factory WorkflowPagination.fromJson(Map<String, dynamic> json) {
    return WorkflowPagination(
      cursor: json['cursor'] as String?,
      hasMore: json['has_more'] as bool? ?? false,
      total: json['total'] as int?,
    );
  }
}

/// 工作流恢复请求
class WorkflowResumeRequest {
  /// 工作流 ID
  final String workflowId;

  /// 事件 ID
  final String eventId;

  /// 恢复数据
  final String resumeData;

  /// 中断类型
  final int interruptType;

  WorkflowResumeRequest({
    required this.workflowId,
    required this.eventId,
    required this.resumeData,
    required this.interruptType,
  });

  Map<String, dynamic> toJson() {
    return {
      'workflow_id': workflowId,
      'event_id': eventId,
      'resume_data': resumeData,
      'interrupt_type': interruptType,
    };
  }
}

/// 工作流执行历史
class WorkflowExecuteHistory {
  /// 执行 ID
  final String executeId;

  /// 执行状态
  final String executeStatus;

  /// Bot ID
  final String botId;

  /// 渠道 ID
  final String connectorId;

  /// 渠道 UID
  final String connectorUid;

  /// 运行模式
  final int runMode;

  /// 日志 ID
  final String logid;

  /// 创建时间
  final int createTime;

  /// 更新时间
  final int updateTime;

  /// 输出
  final String output;

  /// Token 使用
  final String token;

  /// 耗时
  final String cost;

  /// 错误码
  final String errorCode;

  /// 错误信息
  final String errorMessage;

  /// 调试 URL
  final String debugUrl;

  WorkflowExecuteHistory({
    required this.executeId,
    required this.executeStatus,
    required this.botId,
    required this.connectorId,
    required this.connectorUid,
    required this.runMode,
    required this.logid,
    required this.createTime,
    required this.updateTime,
    required this.output,
    required this.token,
    required this.cost,
    required this.errorCode,
    required this.errorMessage,
    required this.debugUrl,
  });

  factory WorkflowExecuteHistory.fromJson(Map<String, dynamic> json) {
    return WorkflowExecuteHistory(
      executeId: json['execute_id'] as String,
      executeStatus: json['execute_status'] as String,
      botId: json['bot_id'] as String,
      connectorId: json['connector_id'] as String,
      connectorUid: json['connector_uid'] as String,
      runMode: json['run_mode'] as int,
      logid: json['logid'] as String,
      createTime: json['create_time'] as int,
      updateTime: json['update_time'] as int,
      output: json['output'] as String,
      token: json['token'] as String,
      cost: json['cost'] as String,
      errorCode: json['error_code'] as String,
      errorMessage: json['error_message'] as String,
      debugUrl: json['debug_url'] as String,
    );
  }
}
