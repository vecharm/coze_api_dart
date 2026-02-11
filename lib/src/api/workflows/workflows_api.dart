/// 工作流 API
///
/// 提供工作流的执行、查询等接口
library;

import 'dart:async';
import 'dart:convert';

import '../../client/http_client.dart';
import '../../models/enums.dart';
import '../../models/errors.dart';
import '../../utils/logger.dart';
import 'workflows_models.dart';

/// 工作流 API 封装
///
/// 提供执行工作流、查询执行结果、列出工作流等功能
class WorkflowsAPI {
  final HttpClient _client;

  /// 创建工作流 API 实例
  WorkflowsAPI(this._client);

  /// 执行工作流（同步）
  ///
  /// [request] 工作流执行请求
  ///
  /// 返回执行结果
  Future<WorkflowRunResponse> run(WorkflowRunRequest request) async {
    final response = await _client.post(
      '/v1/workflow/run',
      body: request.toJson(),
    );

    final data = response.jsonBody['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw CozeException(
        message: '执行工作流失败：响应数据为空',
      );
    }

    return WorkflowRunResponse.fromJson(data);
  }

  /// 执行工作流（异步）
  ///
  /// [request] 工作流执行请求
  ///
  /// 返回执行 ID，需要通过 [getRunResult] 查询结果
  Future<String> runAsync(WorkflowRunRequest request) async {
    final asyncRequest = WorkflowRunRequest(
      workflowId: request.workflowId,
      version: request.version,
      botId: request.botId,
      parameters: request.parameters,
      executeMode: 'asynchronous',
      isStream: false,
      extHeaders: request.extHeaders,
    );

    final response = await _client.post(
      '/v1/workflow/run',
      body: asyncRequest.toJson(),
    );

    final data = response.jsonBody['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw CozeException(
        message: '异步执行工作流失败：响应数据为空',
      );
    }

    return data['execute_id'] as String;
  }

  /// 流式执行工作流
  ///
  /// [request] 工作流执行请求
  ///
  /// 返回事件流，可以监听实时执行过程
  Stream<WorkflowEvent> stream(WorkflowRunRequest request) async* {
    final streamRequest = WorkflowRunRequest(
      workflowId: request.workflowId,
      version: request.version,
      botId: request.botId,
      parameters: request.parameters,
      executeMode: request.executeMode,
      isStream: true,
      extHeaders: request.extHeaders,
    );

    final stream = _client.stream(
      '/v1/workflow/stream_run',
      body: streamRequest.toJson(),
    );

    await for (final chunk in stream) {
      // 解析 SSE 格式的数据
      for (final line in chunk.split('\n')) {
        final trimmed = line.trim();
        if (trimmed.isEmpty || !trimmed.startsWith('data:')) {
          continue;
        }

        final data = trimmed.substring(5).trim();
        if (data == '[DONE]') {
          return;
        }

        try {
          final json = jsonDecode(data) as Map<String, dynamic>;
          yield WorkflowEvent.fromJson(json);
        } catch (e) {
          logW('Failed to parse workflow stream event: $data');
        }
      }
    }
  }

  /// 获取工作流执行结果
  ///
  /// [request] 查询执行结果请求
  ///
  /// 返回执行结果
  Future<WorkflowRunResult> getRunResult(
      WorkflowRunResultRequest request) async {
    final response = await _client.post(
      '/v1/workflow/result',
      body: request.toJson(),
    );

    final data = response.jsonBody['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw CozeException(
        message: '获取工作流执行结果失败：响应数据为空',
      );
    }

    return WorkflowRunResult.fromJson(data);
  }

  /// 列出工作流列表
  ///
  /// [request] 列出工作流请求
  ///
  /// 返回工作流列表和分页信息
  Future<ListWorkflowsResponse> list(ListWorkflowsRequest request) async {
    final response = await _client.post(
      '/v1/workflow/list',
      body: request.toJson(),
    );

    return ListWorkflowsResponse.fromJson(response.jsonBody);
  }

  /// 执行工作流并轮询结果（简化版）
  ///
  /// [request] 工作流执行请求
  /// [pollInterval] 轮询间隔（毫秒），默认 500ms
  /// [timeout] 超时时间（毫秒），默认 5 分钟
  ///
  /// 返回完整的执行结果
  Future<WorkflowRunResult> runAndPoll(
    WorkflowRunRequest request, {
    int pollInterval = 500,
    int timeout = 300000,
  }) async {
    // 异步执行
    final executeId = await runAsync(request);

    final startTime = DateTime.now();

    // 轮询直到完成或失败
    while (true) {
      final result = await getRunResult(
        WorkflowRunResultRequest(executeId: executeId),
      );

      // 检查是否完成
      if (result.status == WorkflowStatus.success ||
          result.status == WorkflowStatus.fail) {
        return result;
      }

      // 检查超时
      if (DateTime.now().difference(startTime).inMilliseconds > timeout) {
        throw TimeoutException(
          message: '工作流执行轮询超时',
          timeoutMs: timeout,
        );
      }

      // 等待
      await Future.delayed(Duration(milliseconds: pollInterval));
    }
  }

  /// 恢复工作流执行（流式）
  ///
  /// [request] 恢复工作流请求
  ///
  /// 返回事件流
  Stream<WorkflowEvent> resume(WorkflowResumeRequest request) async* {
    final stream = _client.stream(
      '/v1/workflow/stream_resume',
      body: request.toJson(),
    );

    await for (final chunk in stream) {
      // 解析 SSE 格式的数据
      for (final line in chunk.split('\n')) {
        final trimmed = line.trim();
        if (trimmed.isEmpty || !trimmed.startsWith('data:')) {
          continue;
        }

        final data = trimmed.substring(5).trim();
        if (data == '[DONE]') {
          return;
        }

        try {
          final json = jsonDecode(data) as Map<String, dynamic>;
          yield WorkflowEvent.fromJson(json);
        } catch (e) {
          logW('Failed to parse workflow resume event: $data');
        }
      }
    }
  }

  /// 获取工作流执行历史
  ///
  /// [workflowId] 工作流 ID
  /// [executeId] 执行 ID
  ///
  /// 返回执行历史列表
  Future<List<WorkflowExecuteHistory>> history(
    String workflowId,
    String executeId,
  ) async {
    final response = await _client.get(
      '/v1/workflows/$workflowId/run_histories/$executeId',
    );

    final data = response.jsonBody['data'] as List<dynamic>?;
    if (data == null) {
      throw CozeException(
        message: '获取工作流执行历史失败：响应数据为空',
      );
    }

    return data
        .map((e) => WorkflowExecuteHistory.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
