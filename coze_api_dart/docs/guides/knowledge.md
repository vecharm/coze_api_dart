# 知识库管理指南（新版）

本文档详细介绍如何使用 Coze API Dart SDK 的新版知识库 API 管理文档。

## 目录

- [概述](#概述)
- [列出文档](#列出文档)
- [创建文档](#创建文档)
- [更新文档](#更新文档)
- [删除文档](#删除文档)
- [最佳实践](#最佳实践)

---

## 概述

新版 Knowledge Documents API 提供更简洁的文档管理方式。通过此 API，你可以：

- 列出知识库中的所有文档
- 创建新文档
- 更新文档信息
- 删除文档

---

## 列出文档

```dart
import 'package:coze_api_dart/coze_api_dart.dart';

void main() async {
  final client = CozeAPI(
    token: 'your_pat_token',
    baseURL: CozeURLs.comBaseURL,
  );

  final response = await client.knowledge.documents.list(
    ListDocumentsRequest(
      datasetId: 'your_dataset_id',
      page: 1,
      pageSize: 20,
    ),
  );

  print('总文档数: ${response.total}');

  for (final doc in response.documentInfos) {
    print('文档 ID: ${doc.documentId}');
    print('名称: ${doc.name}');
    print('类型: ${doc.type}');
    print('状态: ${doc.status}');
    print('字符数: ${doc.charCount}');
    print('切片数: ${doc.sliceCount}');
    print('---');
  }
}
```

---

## 创建文档

```dart
final documents = await client.knowledge.documents.create(
  CreateDocumentRequest(
    datasetId: 'your_dataset_id',
    documentBases: [
      DocumentBase(
        name: '产品手册.pdf',
        sourceInfo: SourceInfo(
          fileBase64: base64Encode(fileBytes),
          fileType: 'pdf',
        ),
        updateRule: UpdateRule(
          updateType: 1,  // 自动更新
          updateInterval: 24,  // 每24小时
        ),
      ),
    ],
    chunkStrategy: ChunkStrategy(
      chunkType: 1,  // 自动分段
      separator: '\n',
      maxTokens: 800,
      removeExtraSpaces: true,
      removeUrlsEmails: false,
    ),
  ),
);

for (final doc in documents) {
  print('文档创建成功: ${doc.documentId}');
}
```

---

## 更新文档

```dart
await client.knowledge.documents.update(
  UpdateDocumentRequest(
    documentId: 'document_id',
    documentName: '新名称',
    updateRule: UpdateRule(
      updateType: 1,
      updateInterval: 12,
    ),
  ),
);
```

---

## 删除文档

```dart
await client.knowledge.documents.delete(
  DeleteDocumentRequest(
    documentIds: ['document_id_1', 'document_id_2'],
  ),
);
```

---

## 最佳实践

### 1. 批量创建文档

```dart
Future<void> batchCreateDocuments(
  String datasetId,
  List<DocumentBase> documents,
) async {
  // 分批处理，每批最多10个
  const batchSize = 10;

  for (var i = 0; i < documents.length; i += batchSize) {
    final batch = documents.sublist(
      i,
      i + batchSize > documents.length ? documents.length : i + batchSize,
    );

    try {
      final created = await client.knowledge.documents.create(
        CreateDocumentRequest(
          datasetId: datasetId,
          documentBases: batch,
        ),
      );

      print('批次 ${i ~/ batchSize + 1} 创建成功: ${created.length} 个文档');
    } catch (e) {
      print('批次 ${i ~/ batchSize + 1} 创建失败: $e');
    }
  }
}
```

### 2. 文档更新检查

```dart
Future<List<DocumentInfo>> getDocumentsNeedingUpdate(
  String datasetId,
  Duration maxAge,
) async {
  final response = await client.knowledge.documents.list(
    ListDocumentsRequest(datasetId: datasetId),
  );

  final now = DateTime.now();

  return response.documentInfos.where((doc) {
    final updateTime = DateTime.fromMillisecondsSinceEpoch(doc.updateTime * 1000);
    return now.difference(updateTime) > maxAge;
  }).toList();
}
```

---

## 下一步

- [数据集指南](datasets.md) - 旧版数据集 API
- [Bot 管理指南](bots.md) - 将知识库关联到 Bot
