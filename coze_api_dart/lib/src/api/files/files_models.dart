
/// 文件 API 数据模型
///
/// 包含文件上传、管理等相关的所有数据模型定义
library;

import '../../models/enums.dart';

/// 文件对象
///
/// 表示一个已上传的文件
class CozeFile {
  /// 文件 ID
  final String id;

  /// 文件名称
  final String name;

  /// 文件大小（字节）
  final int size;

  /// 文件类型
  final FileType fileType;

  /// 文件 URL（有效期有限）
  final String? url;

  /// 创建时间（Unix 时间戳，秒）
  final int createdAt;

  /// 过期时间（Unix 时间戳，秒）
  final int? expiredAt;

  /// MIME 类型
  final String? mimeType;

  CozeFile({
    required this.id,
    required this.name,
    required this.size,
    required this.fileType,
    this.url,
    required this.createdAt,
    this.expiredAt,
    this.mimeType,
  });

  factory CozeFile.fromJson(Map<String, dynamic> json) {
    return CozeFile(
      id: json['id'] as String,
      name: json['file_name'] as String,
      size: json['bytes'] as int,
      fileType: FileType.values.firstWhere(
        (e) => e.name == (json['file_type'] ?? 'document'),
        orElse: () => FileType.document,
      ),
      url: json['url'] as String?,
      createdAt: json['created_at'] as int,
      expiredAt: json['expired_at'] as int?,
      mimeType: json['mime_type'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'file_name': name,
      'bytes': size,
      'file_type': fileType.name,
      if (url != null) 'url': url,
      'created_at': createdAt,
      if (expiredAt != null) 'expired_at': expiredAt,
      if (mimeType != null) 'mime_type': mimeType,
    };
  }

  /// 获取文件大小（人类可读格式）
  String get sizeFormatted {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(2)} KB';
    if (size < 1024 * 1024 * 1024) {
      return '${(size / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  /// 检查文件是否已过期
  bool get isExpired {
    if (expiredAt == null) return false;
    return DateTime.now().millisecondsSinceEpoch ~/ 1000 > expiredAt!;
  }
}

/// 上传文件请求
class UploadFileRequest {
  /// 文件字节数据
  final List<int> fileBytes;

  /// 文件名称
  final String fileName;

  /// 文件类型
  final FileType fileType;

  /// MIME 类型（可选，自动检测）
  final String? mimeType;

  UploadFileRequest({
    required this.fileBytes,
    required this.fileName,
    required this.fileType,
    this.mimeType,
  });
}

/// 获取文件信息请求
class RetrieveFileRequest {
  /// 文件 ID
  final String fileId;

  RetrieveFileRequest({
    required this.fileId,
  });

  Map<String, dynamic> toJson() {
    return {
      'file_id': fileId,
    };
  }
}

/// 删除文件请求
class DeleteFileRequest {
  /// 文件 ID
  final String fileId;

  DeleteFileRequest({
    required this.fileId,
  });

  Map<String, dynamic> toJson() {
    return {
      'file_id': fileId,
    };
  }
}

/// 列出文件请求
class ListFilesRequest {
  /// 分页大小，默认 20，最大 100
  final int? limit;

  /// 分页游标
  final String? cursor;

  /// 文件类型过滤
  final FileType? fileType;

  ListFilesRequest({
    this.limit,
    this.cursor,
    this.fileType,
  });

  Map<String, dynamic> toJson() {
    return {
      if (limit != null) 'limit': limit,
      if (cursor != null) 'cursor': cursor,
      if (fileType != null) 'file_type': fileType!.name,
    };
  }
}

/// 文件列表响应
class ListFilesResponse {
  /// 文件列表
  final List<CozeFile> files;

  /// 分页信息
  final FilePagination? pagination;

  ListFilesResponse({
    required this.files,
    this.pagination,
  });

  factory ListFilesResponse.fromJson(Map<String, dynamic> json) {
    return ListFilesResponse(
      files: (json['data'] as List<dynamic>?)
              ?.map((e) => CozeFile.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      pagination: json['pagination'] != null
          ? FilePagination.fromJson(json['pagination'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// 文件分页信息
class FilePagination {
  /// 分页游标
  final String? cursor;

  /// 是否有更多数据
  final bool hasMore;

  /// 总数
  final int? total;

  FilePagination({
    this.cursor,
    required this.hasMore,
    this.total,
  });

  factory FilePagination.fromJson(Map<String, dynamic> json) {
    return FilePagination(
      cursor: json['cursor'] as String?,
      hasMore: json['has_more'] as bool? ?? false,
      total: json['total'] as int?,
    );
  }
}

/// 文件上传响应
class UploadFileResponse {
  /// 上传的文件信息
  final CozeFile file;

  UploadFileResponse({
    required this.file,
  });

  factory UploadFileResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw FormatException('Invalid response: data is null');
    }
    return UploadFileResponse(
      file: CozeFile.fromJson(data),
    );
  }
}
