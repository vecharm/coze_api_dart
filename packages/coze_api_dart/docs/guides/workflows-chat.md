# 工作流对话指南

本文档详细介绍如何使用 Coze API Dart SDK 进行工作流对话。

## 目录

- [概述](#概述)
- [基础工作流对话](#基础工作流对话)
- [流式工作流对话](#流式工作流对话)
- [带历史的工作流对话](#带历史的工作流对话)
- [最佳实践](#最佳实践)

---

## 概述

工作流对话允许你使用预定义的工作流进行对话。与普通 Chat 不同，工作流对话可以：

- 执行复杂的多步骤流程
- 调用外部 API 和插件
- 根据条件分支处理
- 实现更复杂的业务逻辑

---

## 基础工作流对话

### 简单工作流对话

```dart
import 'package:coze_api_dart/coze_api_dart.dart';

void main() async {
  final client = CozeAPI(
    token: 'your_pat_token',
    baseURL: CozeURLs.comBaseURL,
  );

  try {
    final result = await client.workflows.chat.createAndPoll(
      CreateWorkflowChatRequest(
        workflowId: 'your_workflow_id',
        appId: 'your_app_id',  // 可选
        botId: 'your_bot_id',  // 可选
        additionalMessages: [
          Message.user(content: '查询订单状态'),
        ],
        parameters: {
          'order_id': '12345',
        },
      ),
    );

    print('对话完成');
    print('回复: ${result.messages.last.content}');
  } catch (e) {
    print('对话失败: $e');
  }
}
```

---

## 流式工作流对话

```dart
import 'dart:io';
import 'package:coze_api_dart/coze_api_dart.dart';

void main() async {
  final client = CozeAPI(
    token: 'your_pat_token',
    baseURL: CozeURLs.comBaseURL,
  );

  final stream = client.workflows.chat.stream(
    CreateWorkflowChatRequest(
      workflowId: 'your_workflow_id',
      additionalMessages: [
        Message.user(content: '分析销售数据'),
      ],
    ),
  );

  await for (final event in stream) {
    switch (event.event) {
      case WorkflowChatEventType.message:
        stdout.write(event.data['content']);
        break;
      case WorkflowChatEventType.messageCompleted:
        print('\n消息完成');
        break;
      case WorkflowChatEventType.completed:
        print('对话完成');
        break;
      case WorkflowChatEventType.error:
        print('错误: ${event.data}');
        break;
    }
  }
}
```

---

## 带历史的工作流对话

```dart
import 'package:coze_api_dart/coze_api_dart.dart';

void main() async {
  final client = CozeAPI(
    token: 'your_pat_token',
    baseURL: CozeURLs.comBaseURL,
  );

  // 保存对话历史
  final history = <Message>[];

  // 第一轮对话
  var result = await client.workflows.chat.createAndPoll(
    CreateWorkflowChatRequest(
      workflowId: 'your_workflow_id',
      additionalMessages: [
        Message.user(content: '我的订单号是多少？'),
      ],
    ),
  );

  history.addAll(result.messages);
  print('Bot: ${result.messages.last.content}');

  // 第二轮对话（携带历史）
  result = await client.workflows.chat.createAndPoll(
    CreateWorkflowChatRequest(
      workflowId: 'your_workflow_id',
      additionalMessages: [
        ...history,
        Message.user(content: '帮我取消这个订单'),
      ],
    ),
  );

  print('Bot: ${result.messages.last.content}');
}
```

---

## 最佳实践

### 1. 错误处理

```dart
Future<void> safeWorkflowChat() async {
  try {
    final result = await client.workflows.chat.createAndPoll(
      CreateWorkflowChatRequest(
        workflowId: 'workflow_id',
        additionalMessages: [Message.user(content: '你好')],
      ),
    );
    // 处理结果
  } on CozeException catch (e) {
    print('工作流对话错误: ${e.message}');
  } on TimeoutException catch (e) {
    print('请求超时');
  }
}
```

### 2. 参数管理

```dart
class WorkflowChatManager {
  final CozeAPI client;
  final String workflowId;

  WorkflowChatManager(this.client, this.workflowId);

  Future<String> chat(
    String message, {
    Map<String, dynamic>? parameters,
  }) async {
    final result = await client.workflows.chat.createAndPoll(
      CreateWorkflowChatRequest(
        workflowId: workflowId,
        additionalMessages: [Message.user(content: message)],
        parameters: parameters,
      ),
    );

    return result.messages.last.content;
  }
}
```

---

## 下一步

- [工作流指南](workflows.md) - 了解工作流执行
- [Chat 对话指南](chat.md) - 普通对话功能
