# 数据集管理指南

本文档详细介绍如何使用 Coze API Dart SDK 管理数据集和文档。

## 目录

- [概述](#概述)
- [创建数据集](#创建数据集)
- [获取数据集信息](#获取数据集信息)
- [列出数据集](#列出数据集)
- [更新数据集](#更新数据集)
- [删除数据集](#删除数据集)
- [文档管理](#文档管理)
- [图片管理](#图片管理)
- [最佳实践](#最佳实践)

---

## 概述

数据集用于存储和管理知识库文档。通过 Datasets API，你可以：

- 创建、更新、删除数据集
- 管理数据集中的文档
- 管理数据集中的图片

---

## 创建数据集

```dart
import 'package:coze_api_dart/coze_api_dart.dart';

void main() async {
  final client = CozeAPI(
    token: 'your_pat_token',
    baseURL: CozeURLs.comBaseURL,
  );

  final dataset = await client.datasets.create(
    CreateDatasetRequest(
      name: '产品知识库',
      spaceId: 'your_space_id',
      description: '存储产品相关文档',
      formatType: FormatType.document,  // 文档类型
    ),
  );

  print('数据集创建成功');
  print('数据集 ID: ${dataset.datasetId}');
}
```

---

## 获取数据集信息

```dart
final dataset = await client.datasets.retrieve('dataset_id');

print('数据集 ID: ${dataset.datasetId}');
print('名称: ${dataset.name}');
print('描述: ${dataset.description}');
print('格式类型: ${dataset.formatType}');
print('状态: ${dataset.status}');
```

---

## 列出数据集

```dart
final response = await client.datasets.list(
  ListDatasetsRequest(
    spaceId: 'your_space_id',
    pageNum: 1,
    pageSize: 20,
  ),
);

for (final dataset in response.datasetList) {
  print('ID: ${dataset.datasetId}');
  print('名称: ${dataset.name}');
  print('---');
}
```

---

## 更新数据集

```dart
await client.datasets.update(
  'dataset_id',
  UpdateDatasetRequest(
    name: '新名称',
    description: '新描述',
  ),
);
```

---

## 删除数据集

```dart
await client.datasets.delete('dataset_id');
```

---

## 文档管理

### 创建文档

```dart
final document = await client.datasets.documents.create(
  'dataset_id',
  CreateDocumentRequest(
    documentBases: [
      DocumentBase(
        name: '产品介绍.pdf',
        sourceInfo: SourceInfo(
          fileBase64: base64Encode(fileBytes),
          fileType: 'pdf',
        ),
      ),
    ],
    chunkStrategy: ChunkStrategy(
      chunkType: 1,  // 自动分段
      separator: '\n',
      maxTokens: 800,
    ),
  ),
);

print('文档创建成功: ${document.documentId}');
```

### 列出文档

```dart
final response = await client.datasets.documents.list(
  'dataset_id',
  ListDocumentsRequest(
    pageNum: 1,
    pageSize: 20,
  ),
);

for (final doc in response.documentInfos) {
  print('ID: ${doc.documentId}');
  print('名称: ${doc.name}');
  print('状态: ${doc.status}');
}
```

### 删除文档

```dart
await client.datasets.documents.delete(
  'dataset_id',
  DeleteDocumentRequest(
    documentIds: ['document_id'],
  ),
);
```

---

## 图片管理

### 列出图片

```dart
final response = await client.datasets.images.list(
  'dataset_id',
  ListImagesRequest(
    pageNum: 1,
    pageSize: 20,
    keyword: '产品',  // 搜索关键词
  ),
);

for (final image in response.photoInfos) {
  print('ID: ${image.documentId}');
  print('名称: ${image.name}');
  print('URL: ${image.url}');
}
```

### 更新图片描述

```dart
await client.datasets.images.update(
  'dataset_id',
  'document_id',
  UpdateImageRequest(
    caption: '这是产品的详细截图',
  ),
);
```

---

## 最佳实践

### 1. 批量上传文档

```dart
Future<void> batchUploadDocuments(
  String datasetId,
  List<File> files,
) async {
  for (final file in files) {
    try {
      final bytes = await file.readAsBytes();

      await client.datasets.documents.create(
        datasetId,
        CreateDocumentRequest(
          documentBases: [
            DocumentBase(
              name: file.path.split('/').last,
              sourceInfo: SourceInfo(
                fileBase64: base64Encode(bytes),
                fileType: file.path.split('.').last,
              ),
            ),
          ],
        ),
      );

      print('上传成功: ${file.path}');
    } catch (e) {
      print('上传失败: ${file.path}, 错误: $e');
    }
  }
}
```

### 2. 文档处理状态检查

```dart
Future<void> waitForDocumentProcessing(
  String datasetId,
  String documentId,
) async {
  while (true) {
    final response = await client.datasets.documents.list(
      datasetId,
      ListDocumentsRequest(),
    );

    final doc = response.documentInfos.firstWhere(
      (d) => d.documentId == documentId,
    );

    if (doc.status == 1) {
      print('文档处理完成');
      break;
    } else if (doc.status == 9) {
      throw Exception('文档处理失败');
    }

    print('文档处理中...');
    await Future.delayed(Duration(seconds: 2));
  }
}
```

---

## 下一步

- [知识库指南](knowledge.md) - 使用新版知识库 API
- [Bot 管理指南](bots.md) - 将数据集关联到 Bot
