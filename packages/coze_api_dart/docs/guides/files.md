# 文件上传指南

本文档详细介绍如何使用 Coze API Dart SDK 上传和管理文件。

## 目录

- [概述](#概述)
- [上传文件](#上传文件)
- [获取文件信息](#获取文件信息)
- [最佳实践](#最佳实践)

---

## 概述

Files API 支持上传各种文件类型，包括图片、文档、音频等。上传的文件可以用于：

- Chat 对话中的图片/文件消息
- Bot 的图标
- 数据集的文档
- 知识库的文档

---

## 上传文件

### 基础上传

```dart
import 'dart:io';
import 'package:coze_api_dart/coze_api_dart.dart';

void main() async {
  final client = CozeAPI(
    token: 'your_pat_token',
    baseURL: CozeURLs.comBaseURL,
  );

  // 读取文件
  final file = File('path/to/image.jpg');

  // 上传文件
  final uploadedFile = await client.files.upload(
    UploadFileRequest(
      file: file,
    ),
  );

  print('文件上传成功');
  print('文件 ID: ${uploadedFile.id}');
  print('文件名称: ${uploadedFile.fileName}');
  print('文件大小: ${uploadedFile.bytes} bytes');
}
```

### 带元数据的上传

```dart
final uploadedFile = await client.files.upload(
  UploadFileRequest(
    file: file,
    fileName: 'custom_name.jpg',  // 自定义文件名
    contentType: 'image/jpeg',     // 指定 MIME 类型
  ),
);
```

---

## 获取文件信息

```dart
final fileInfo = await client.files.retrieve('file_id');

print('文件 ID: ${fileInfo.id}');
print('文件名: ${fileInfo.fileName}');
print('文件大小: ${fileInfo.bytes} bytes');
print('创建时间: ${fileInfo.createdAt}');
```

---

## 最佳实践

### 1. 文件大小检查

```dart
Future<void> uploadWithSizeCheck(File file) async {
  const maxSize = 10 * 1024 * 1024;  // 10MB

  final size = await file.length();
  if (size > maxSize) {
    throw Exception('文件大小超过限制 (最大 10MB)');
  }

  await client.files.upload(UploadFileRequest(file: file));
}
```

### 2. 图片压缩

```dart
import 'package:image/image.dart' as img;

Future<File> compressImage(File file) async {
  final bytes = await file.readAsBytes();
  final image = img.decodeImage(bytes);

  if (image == null) return file;

  // 压缩到最大宽度 1920
  final resized = img.copyResize(
    image,
    width: image.width > 1920 ? 1920 : image.width,
  );

  final compressed = File('${file.path}_compressed.jpg');
  await compressed.writeAsBytes(img.encodeJpg(resized, quality: 85));

  return compressed;
}
```

### 3. 上传进度

```dart
Future<void> uploadWithProgress(File file) async {
  final stream = file.openRead();
  final length = await file.length();

  var uploaded = 0;

  await for (final chunk in stream) {
    uploaded += chunk.length;
    final progress = (uploaded / length * 100).toStringAsFixed(1);
    print('上传进度: $progress%');
  }
}
```

---

## 下一步

- [Chat 对话指南](chat.md) - 使用上传的文件进行对话
- [数据集指南](datasets.md) - 上传数据集文档
