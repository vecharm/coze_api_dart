# Files API 参考

本文档详细介绍 Files API 的所有类和方法。

## FilesAPI 类

文件管理相关 API 的主类。

### 方法

#### upload()

上传文件。

```dart
Future<UploadedFile> upload(UploadFileRequest request)
```

**参数：**

| 参数 | 类型 | 说明 |
|------|------|------|
| `request` | `UploadFileRequest` | 上传请求 |

**返回：** `UploadedFile` - 上传的文件信息

**示例：**

```dart
final file = File('path/to/image.jpg');
final uploadedFile = await client.files.upload(
  UploadFileRequest(file: file),
);
print('文件 ID: ${uploadedFile.id}');
```

---

#### retrieve()

获取文件信息。

```dart
Future<UploadedFile> retrieve(String fileId)
```

**参数：**

| 参数 | 类型 | 说明 |
|------|------|------|
| `fileId` | `String` | 文件 ID |

**返回：** `UploadedFile` - 文件信息

---

## 数据类

### UploadFileRequest

| 属性 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `file` | `File` | 是 | 文件 |
| `fileName` | `String?` | 否 | 自定义文件名 |
| `contentType` | `String?` | 否 | MIME 类型 |

### UploadedFile

| 属性 | 类型 | 说明 |
|------|------|------|
| `id` | `String` | 文件 ID |
| `fileName` | `String` | 文件名 |
| `bytes` | `int` | 文件大小（字节） |
| `createdAt` | `int` | 创建时间 |

---

## 相关链接

- [文件上传指南](../guides/files.md) - 使用指南
