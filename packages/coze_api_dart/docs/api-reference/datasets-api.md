# Datasets API 参考

本文档详细介绍 Datasets API 的所有类和方法。

## DatasetsAPI 类

数据集管理相关 API 的主类。

### 方法

#### create()

创建数据集。

```dart
Future<Dataset> create(CreateDatasetRequest request)
```

**参数：**

| 参数 | 类型 | 说明 |
|------|------|------|
| `request` | `CreateDatasetRequest` | 创建请求 |

**返回：** `Dataset` - 创建的数据集

**示例：**

```dart
final dataset = await client.datasets.create(
  CreateDatasetRequest(
    name: '产品知识库',
    spaceId: 'space_id',
    formatType: FormatType.document,
  ),
);
```

---

#### retrieve()

获取数据集信息。

```dart
Future<Dataset> retrieve(String datasetId)
```

---

#### list()

列出数据集。

```dart
Future<ListDatasetsResponse> list(ListDatasetsRequest request)
```

---

#### update()

更新数据集。

```dart
Future<void> update(
  String datasetId,
  UpdateDatasetRequest request,
)
```

---

#### delete()

删除数据集。

```dart
Future<void> delete(String datasetId)
```

---

## DatasetsDocumentsAPI 类

数据集文档管理 API。

### 方法

#### create()

创建文档。

```dart
Future<List<DocumentInfo>> create(
  String datasetId,
  CreateDocumentRequest request,
)
```

---

#### list()

列出文档。

```dart
Future<ListDocumentsResponse> list(
  String datasetId,
  ListDocumentsRequest request,
)
```

---

#### delete()

删除文档。

```dart
Future<void> delete(
  String datasetId,
  DeleteDocumentRequest request,
)
```

---

## DatasetsImagesAPI 类

数据集图片管理 API。

### 方法

#### list()

列出图片。

```dart
Future<ListImagesResponse> list(
  String datasetId, {
  ListImagesRequest? request,
})
```

---

#### update()

更新图片描述。

```dart
Future<void> update(
  String datasetId,
  String documentId,
  UpdateImageRequest request,
)
```

---

## 数据类

### CreateDatasetRequest

| 属性 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `name` | `String` | 是 | 数据集名称 |
| `spaceId` | `String` | 是 | 工作空间 ID |
| `description` | `String?` | 否 | 描述 |
| `formatType` | `FormatType` | 是 | 格式类型 |

### FormatType 枚举

| 值 | 说明 |
|----|------|
| `document` | 文档 |
| `table` | 表格 |
| `image` | 图片 |

---

## 相关链接

- [数据集管理指南](../guides/datasets.md) - 使用指南
