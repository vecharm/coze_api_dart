# 工作空间指南

本文档详细介绍如何使用 Coze API Dart SDK 管理工作空间。

## 目录

- [概述](#概述)
- [列出工作空间](#列出工作空间)
- [最佳实践](#最佳实践)

---

## 概述

工作空间是 Coze 平台中用于组织资源的容器。通过 Workspaces API，你可以：

- 列出用户有权限访问的所有工作空间
- 获取工作空间信息

---

## 列出工作空间

```dart
import 'package:coze_api_dart/coze_api_dart.dart';

void main() async {
  final client = CozeAPI(
    token: 'your_pat_token',
    baseURL: CozeURLs.comBaseURL,
  );

  try {
    final response = await client.workspaces.list(
      ListWorkspacesRequest(
        pageNum: 1,
        pageSize: 20,
      ),
    );

    print('总工作空间数: ${response.total}');

    for (final workspace in response.workspaces) {
      print('工作空间 ID: ${workspace.id}');
      print('名称: ${workspace.name}');
      print('描述: ${workspace.description}');
      print('创建时间: ${workspace.createdAt}');
      print('---');
    }
  } catch (e) {
    print('获取工作空间列表失败: $e');
  }
}
```

---

## 最佳实践

### 1. 工作空间缓存

```dart
class WorkspaceCache {
  final CozeAPI client;
  List<Workspace>? _cache;
  DateTime? _lastUpdate;

  WorkspaceCache(this.client);

  Future<List<Workspace>> getWorkspaces() async {
    // 检查缓存是否有效（5分钟内）
    if (_cache != null &&
        _lastUpdate != null &&
        DateTime.now().difference(_lastUpdate!) < Duration(minutes: 5)) {
      return _cache!;
    }

    // 从 API 获取
    final response = await client.workspaces.list(
      ListWorkspacesRequest(pageNum: 1, pageSize: 100),
    );

    _cache = response.workspaces;
    _lastUpdate = DateTime.now();

    return _cache!;
  }

  void invalidate() {
    _cache = null;
    _lastUpdate = null;
  }
}
```

---

## 下一步

- [Bot 管理指南](bots.md) - 在工作空间中管理 Bot
- [数据集指南](datasets.md) - 在工作空间中管理数据集
