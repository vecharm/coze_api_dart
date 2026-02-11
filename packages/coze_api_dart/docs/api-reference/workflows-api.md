# Workflows API 参考

本文档详细介绍 Workflows API 的所有类和方法。

## WorkflowsAPI 类

工作流相关 API 的主类。

### 方法

#### run()

同步执行工作流。

```dart
Future<WorkflowRunResult> run(WorkflowRunRequest request)
```

**参数：**

| 参数 | 类型 | 说明 |
|------|------|------|
| `request` | `WorkflowRunRequest` | 执行请求 |

**返回：** `WorkflowRunResult` - 执行结果

**示例：**

```dart
final result = await client.workflows.run(
  WorkflowRunRequest(
    workflowId: 'workflow_id',
    parameters: {'input': '测试'},
  ),
);
```

---

#### runAndPoll()

执行工作流并轮询结果。

```dart
Future<WorkflowRunResult> runAndPoll(
  WorkflowRunRequest request, {
  int? pollInterval,
  int? timeout,
})
```

**参数：**

| 参数 | 类型 | 说明 |
|------|------|------|
| `request` | `WorkflowRunRequest` | 执行请求 |
| `pollInterval` | `int?` | 轮询间隔（毫秒） |
| `timeout` | `int?` | 超时时间（毫秒） |

---

#### runAsync()

异步执行工作流。

```dart
Future<String> runAsync(WorkflowRunRequest request)
```

**返回：** `String` - 执行 ID

---

#### getRunResult()

获取异步执行结果。

```dart
Future<WorkflowRunResult> getRunResult(WorkflowRunResultRequest request)
```

---

#### stream()

流式执行工作流。

```dart
Stream<WorkflowEvent> stream(WorkflowRunRequest request)
```

**返回：** `Stream<WorkflowEvent>` - 流式事件

---

#### resume()

恢复工作流执行。

```dart
Stream<WorkflowEvent> resume(WorkflowResumeRequest request)
```

---

#### history()

获取执行历史。

```dart
Future<List<WorkflowHistory>> history(
  String workflowId,
  String executeId,
)
```

---

## WorkflowChatAPI 类

工作流对话 API。

### 方法

#### createAndPoll()

创建工作流对话并轮询结果。

```dart
Future<WorkflowChatResult> createAndPoll(CreateWorkflowChatRequest request)
```

---

#### stream()

流式工作流对话。

```dart
Stream<WorkflowChatEvent> stream(CreateWorkflowChatRequest request)
```

---

## 数据类

### WorkflowRunRequest

工作流执行请求。

| 属性 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `workflowId` | `String` | 是 | 工作流 ID |
| `botId` | `String?` | 否 | Bot ID |
| `version` | `String?` | 否 | 版本号 |
| `parameters` | `Map<String, dynamic>?` | 否 | 参数 |

### WorkflowRunResult

工作流执行结果。

| 属性 | 类型 | 说明 |
|------|------|------|
| `executeId` | `String` | 执行 ID |
| `status` | `WorkflowStatus` | 执行状态 |
| `data` | `Map<String, dynamic>?` | 输出数据 |
| `error` | `String?` | 错误信息 |

### WorkflowStatus 枚举

| 值 | 说明 |
|----|------|
| `success` | 成功 |
| `fail` | 失败 |
| `running` | 运行中 |

---

## 相关链接

- [工作流指南](../guides/workflows.md) - 使用指南
