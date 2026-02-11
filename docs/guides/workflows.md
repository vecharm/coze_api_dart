# 工作流指南

本文档详细介绍如何使用 Coze API Dart SDK 执行和管理工作流。

## 目录

- [概述](#概述)
- [执行工作流](#执行工作流)
- [流式执行](#流式执行)
- [异步执行](#异步执行)
- [恢复工作流](#恢复工作流)
- [执行历史](#执行历史)
- [最佳实践](#最佳实践)

---

## 概述

工作流是 Coze 平台中用于自动化任务的流程。通过 Workflows API，你可以：

- 同步执行工作流
- 异步执行工作流
- 流式获取执行过程
- 查询执行结果
- 恢复中断的工作流

---

## 执行工作流

### 同步执行

```dart
import 'package:coze_api_dart/coze_api_dart.dart';

void main() async {
  final client = CozeAPI(
    token: 'your_pat_token',
    baseURL: CozeURLs.comBaseURL,
  );

  try {
    final result = await client.workflows.run(
      WorkflowRunRequest(
        workflowId: 'your_workflow_id',
        botId: 'your_bot_id',  // 可选
        version: '1.0.0',  // 可选：指定版本
        parameters: {
          'input': '用户输入',
          'key': 'value',
        },
      ),
    );

    print('执行状态: ${result.status}');
    print('输出数据: ${result.data}');
    print('错误信息: ${result.error}');
  } catch (e) {
    print('执行失败: $e');
  }
}
```

### 执行并轮询结果

```dart
final result = await client.workflows.runAndPoll(
  WorkflowRunRequest(
    workflowId: 'your_workflow_id',
    parameters: {'input': '测试'},
  ),
  pollInterval: 1000,  // 轮询间隔 1 秒
  timeout: 60000,      // 超时时间 1 分钟
);

print('最终结果: ${result.data}');
```

---

## 流式执行

流式执行可以实时获取工作流的执行过程：

```dart
final stream = client.workflows.stream(
  WorkflowRunRequest(
    workflowId: 'your_workflow_id',
    parameters: {'input': '测试'},
  ),
);

await for (final event in stream) {
  switch (event.eventType) {
    case WorkflowEventType.workflowStarted:
      print('🚀 工作流开始');
      break;

    case WorkflowEventType.nodeStarted:
      print('▶️ 节点开始: ${event.nodeTitle}');
      break;

    case WorkflowEventType.nodeFinished:
      print('✅ 节点完成: ${event.nodeTitle}');
      print('输出: ${event.outputs}');
      break;

    case WorkflowEventType.workflowFinished:
      print('🏁 工作流完成');
      print('最终结果: ${event.outputs}');
      break;

    case WorkflowEventType.error:
      print('❌ 错误: ${event.error}');
      break;
  }
}
```

---

## 异步执行

### 启动异步执行

```dart
final executeId = await client.workflows.runAsync(
  WorkflowRunRequest(
    workflowId: 'your_workflow_id',
    parameters: {'input': '测试'},
  ),
);

print('执行 ID: $executeId');
```

### 查询执行结果

```dart
final result = await client.workflows.getRunResult(
  WorkflowRunResultRequest(executeId: executeId),
);

print('状态: ${result.status}');
print('输出: ${result.data}');
```

---

## 恢复工作流

当工作流需要用户输入时，可以恢复执行：

```dart
final stream = client.workflows.resume(
  WorkflowResumeRequest(
    workflowId: 'your_workflow_id',
    eventId: 'event_id',  // 中断事件 ID
    resumeData: {
      'user_input': '用户输入的内容',
    },
  ),
);

await for (final event in stream) {
  // 处理事件
}
```

---

## 执行历史

```dart
final history = await client.workflows.history(
  'workflow_id',
  'execute_id',
);

for (final record in history) {
  print('节点: ${record.nodeTitle}');
  print('状态: ${record.status}');
  print('输入: ${record.inputs}');
  print('输出: ${record.outputs}');
  print('耗时: ${record.costTime}ms');
  print('---');
}
```

---

## 最佳实践

### 1. 错误处理

```dart
Future<void> safeWorkflowExecution() async {
  try {
    final result = await client.workflows.run(...);
    
    switch (result.status) {
      case WorkflowStatus.success:
        print('执行成功: ${result.data}');
        break;
      case WorkflowStatus.fail:
        print('执行失败: ${result.error}');
        break;
      case WorkflowStatus.running:
        print('执行中...');
        break;
    }
  } on TimeoutException catch (e) {
    print('执行超时');
  } on CozeException catch (e) {
    print('工作流错误: ${e.message}');
  }
}
```

### 2. 工作流管理器

```dart
class WorkflowManager {
  final CozeAPI client;
  final Map<String, String> _runningWorkflows = {};

  WorkflowManager(this.client);

  Future<String> startWorkflow(
    String workflowId,
    Map<String, dynamic> parameters,
  ) async {
    final executeId = await client.workflows.runAsync(
      WorkflowRunRequest(
        workflowId: workflowId,
        parameters: parameters,
      ),
    );

    _runningWorkflows[workflowId] = executeId;
    return executeId;
  }

  Future<WorkflowRunResult> getResult(String workflowId) async {
    final executeId = _runningWorkflows[workflowId];
    if (executeId == null) {
      throw Exception('工作流未启动');
    }

    return await client.workflows.getRunResult(
      WorkflowRunResultRequest(executeId: executeId),
    );
  }

  Stream<WorkflowEvent> streamWorkflow(
    String workflowId,
    Map<String, dynamic> parameters,
  ) {
    return client.workflows.stream(
      WorkflowRunRequest(
        workflowId: workflowId,
        parameters: parameters,
      ),
    );
  }
}
```

---

## 下一步

- [工作流对话](workflows-chat.md) - 工作流对话功能
- [错误处理](../advanced/error-handling.md) - 错误处理最佳实践
