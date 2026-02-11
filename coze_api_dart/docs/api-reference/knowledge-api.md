# Knowledge API 参考

本文档详细介绍 Knowledge Documents API（新版）的所有类和方法。

## KnowledgeDocumentsAPI 类

新版知识库文档管理 API 的主类。

### 方法

#### list()

列出知识库文档。

```dart
Future<ListDocumentsResponse> list(ListDocumentsRequest request)
```

**参数：**

| 参数 | 类型 | 说明 |
|------|------|------|
| `request` | `ListDocumentsRequest` | 列表请求 |

**返回：** `ListDocumentsResponse` - 文档列表响应

**示例：**

```dart
final response = await client.knowledge.documents.list(
  ListDocumentsRequest(
    datasetId: 'dataset_id',
    page: 1,
    pageSize: 20,
  ),
);
```

---

#### create()

创建知识库文档。

```dart
Future<List<DocumentInfo>> create(CreateDocumentRequest request)
```

**参数：**

| 参数 | 类型 | 说明 |
|------|------|------|
| `request` | `CreateDocumentRequest` | 创建请求 |

**返回：** `List<DocumentInfo>` - 创建的文档列表

**示例：**

```dart
final documents = await client.knowledge.documents.create(
  CreateDocumentRequest(
    datasetId: 'dataset_id',
    documentBases: [
      DocumentBase(
        name: '文档.pdf',
        sourceInfo: SourceInfo(
          fileBase64: base64Encode(fileBytes),
          fileType: 'pdf',
        ),
      ),
    ],
  ),
);
```

---

#### update()

更新知识库文档。

```dart
Future<void> update(UpdateDocumentRequest request)
```

**参数：**

| 参数 | 类型 | 说明 |
|------|------|------|
| `request` | `UpdateDocumentRequest` | 更新请求 |

**示例：**

```dart
await client.knowledge.documents.update(
  UpdateDocumentRequest(
    documentId: 'document_id',
    documentName: '新名称',
  ),
);
```

---

#### delete()

删除知识库文档。

```dart
Future<void> delete(DeleteDocumentRequest request)
```

**参数：**

| 参数 | 类型 | 说明 |
|------|------|------|
| `request` | `DeleteDocumentRequest` | 删除请求 |

**示例：**

```dart
await client.knowledge.documents.delete(
  DeleteDocumentRequest(
    documentIds: ['doc_id_1', 'doc_id_2'],
  ),
);
```

---

## 数据类

### ListDocumentsRequest

| 属性 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `datasetId` | `String` | 是 | 数据集 ID |
| `page` | `int?` | 否 | 页码 |
| `pageSize` | `int?` | 否 | 每页数量 |

### CreateDocumentRequest

| 属性 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `datasetId` | `String` | 是 | 数据集 ID |
| `documentBases` | `List<DocumentBase>` | 是 | 文档基础信息列表 |
| `chunkStrategy` | `ChunkStrategy?` | 否 | 分段策略 |

### DocumentBase

| 属性 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `name` | `String` | 是 | 文档名称 |
| `sourceInfo` | `SourceInfo` | 是 | 源信息 |
| `updateRule` | `UpdateRule?` | 否 | 更新规则 |

### SourceInfo

| 属性 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `fileBase64` | `String?` | 否 | 文件 Base64 |
| `fileType` | `String?` | 否 | 文件类型 |
| `webUrl` | `String?` | 否 | 网页 URL |

---

## 相关链接

- [知识库管理指南](../guides/knowledge.md) - 使用指南
