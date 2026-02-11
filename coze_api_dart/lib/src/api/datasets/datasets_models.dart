/// Datasets API 数据模型
///
/// 包含数据集管理相关的所有数据模型定义
library;

import '../../models/enums.dart';

/// 数据集
class Dataset {
  /// 数据集 ID
  final String id;

  /// 数据集名称
  final String name;

  /// 数据集描述
  final String? description;

  /// 空间 ID
  final String spaceId;

  /// 格式类型
  final DatasetFormatType formatType;

  /// 数据集状态
  final DatasetStatus status;

  /// 文档数量
  final int documentCount;

  /// 字符数
  final int charCount;

  /// 创建时间
  final DateTime createdAt;

  /// 更新时间
  final DateTime updatedAt;

  Dataset({
    required this.id,
    required this.name,
    this.description,
    required this.spaceId,
    required this.formatType,
    required this.status,
    required this.documentCount,
    required this.charCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Dataset.fromJson(Map<String, dynamic> json) {
    return Dataset(
      id: json['dataset_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      spaceId: json['space_id'] as String,
      formatType: DatasetFormatType.values.firstWhere(
        (e) => e.name == (json['format_type'] ?? 'qa'),
        orElse: () => DatasetFormatType.qa,
      ),
      status: DatasetStatus.values.firstWhere(
        (e) => e.name == (json['status'] ?? 'enabled'),
        orElse: () => DatasetStatus.enabled,
      ),
      documentCount: json['document_count'] as int? ?? 0,
      charCount: json['char_count'] as int? ?? 0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (json['create_time'] as int) * 1000,
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        (json['update_time'] as int) * 1000,
      ),
    );
  }
}

/// 创建数据集请求
class CreateDatasetRequest {
  /// 空间 ID
  final String spaceId;

  /// 数据集名称
  final String name;

  /// 数据集描述
  final String? description;

  /// 格式类型
  final DatasetFormatType formatType;

  CreateDatasetRequest({
    required this.spaceId,
    required this.name,
    this.description,
    this.formatType = DatasetFormatType.qa,
  });

  Map<String, dynamic> toJson() {
    return {
      'space_id': spaceId,
      'name': name,
      if (description != null) 'description': description,
      'format_type': formatType.name,
    };
  }
}

/// 更新数据集请求
class UpdateDatasetRequest {
  /// 数据集 ID
  final String datasetId;

  /// 数据集名称
  final String? name;

  /// 数据集描述
  final String? description;

  UpdateDatasetRequest({
    required this.datasetId,
    this.name,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'dataset_id': datasetId,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
    };
  }
}

/// 列出数据集请求
class ListDatasetsRequest {
  /// 空间 ID
  final String spaceId;

  /// 分页大小
  final int? pageSize;

  /// 分页游标
  final String? cursor;

  ListDatasetsRequest({
    required this.spaceId,
    this.pageSize,
    this.cursor,
  });

  Map<String, dynamic> toJson() {
    return {
      'space_id': spaceId,
      if (pageSize != null) 'page_size': pageSize,
      if (cursor != null) 'cursor': cursor,
    };
  }
}

/// 列出数据集响应
class ListDatasetsResponse {
  /// 数据集列表
  final List<Dataset> datasets;

  /// 是否有更多
  final bool hasMore;

  /// 分页游标
  final String? cursor;

  ListDatasetsResponse({
    required this.datasets,
    required this.hasMore,
    this.cursor,
  });

  factory ListDatasetsResponse.fromJson(Map<String, dynamic> json) {
    return ListDatasetsResponse(
      datasets: (json['data'] as List<dynamic>?)
              ?.map((e) => Dataset.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      hasMore: json['has_more'] as bool? ?? false,
      cursor: json['cursor'] as String?,
    );
  }
}

/// 文档
class Document {
  /// 文档 ID
  final String id;

  /// 数据集 ID
  final String datasetId;

  /// 文档名称
  final String name;

  /// 文档类型
  final DocumentType type;

  /// 文档状态
  final DocumentStatus status;

  /// 字符数
  final int charCount;

  /// 切片数量
  final int sliceCount;

  /// 失败原因
  final String? failReason;

  /// 创建时间
  final DateTime createdAt;

  /// 更新时间
  final DateTime updatedAt;

  Document({
    required this.id,
    required this.datasetId,
    required this.name,
    required this.type,
    required this.status,
    required this.charCount,
    required this.sliceCount,
    this.failReason,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['document_id'] as String,
      datasetId: json['dataset_id'] as String,
      name: json['name'] as String,
      type: DocumentType.values.firstWhere(
        (e) => e.name == (json['type'] ?? 'text'),
        orElse: () => DocumentType.text,
      ),
      status: DocumentStatus.values.firstWhere(
        (e) => e.name == (json['status'] ?? 'processing'),
        orElse: () => DocumentStatus.processing,
      ),
      charCount: json['char_count'] as int? ?? 0,
      sliceCount: json['slice_count'] as int? ?? 0,
      failReason: json['fail_reason'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (json['create_time'] as int) * 1000,
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        (json['update_time'] as int) * 1000,
      ),
    );
  }
}

/// 创建文档请求
class CreateDocumentRequest {
  /// 数据集 ID
  final String datasetId;

  /// 文档名称
  final String name;

  /// 文档内容（直接上传）
  final String? content;

  /// 文件 ID（通过文件 API 上传）
  final String? fileId;

  /// 文档类型
  final DocumentType type;

  CreateDocumentRequest({
    required this.datasetId,
    required this.name,
    this.content,
    this.fileId,
    this.type = DocumentType.text,
  });

  Map<String, dynamic> toJson() {
    return {
      'dataset_id': datasetId,
      'name': name,
      'type': type.name,
      if (content != null) 'content': content,
      if (fileId != null) 'file_id': fileId,
    };
  }
}

/// 更新文档请求
class UpdateDocumentRequest {
  /// 文档 ID
  final String documentId;

  /// 文档名称
  final String? name;

  /// 文档内容
  final String? content;

  UpdateDocumentRequest({
    required this.documentId,
    this.name,
    this.content,
  });

  Map<String, dynamic> toJson() {
    return {
      'document_id': documentId,
      if (name != null) 'name': name,
      if (content != null) 'content': content,
    };
  }
}

/// 列出文档请求
class ListDocumentsRequest {
  /// 数据集 ID
  final String datasetId;

  /// 分页大小
  final int? pageSize;

  /// 分页游标
  final String? cursor;

  ListDocumentsRequest({
    required this.datasetId,
    this.pageSize,
    this.cursor,
  });

  Map<String, dynamic> toJson() {
    return {
      'dataset_id': datasetId,
      if (pageSize != null) 'page_size': pageSize,
      if (cursor != null) 'cursor': cursor,
    };
  }
}

/// 列出文档响应
class ListDocumentsResponse {
  /// 文档列表
  final List<Document> documents;

  /// 是否有更多
  final bool hasMore;

  /// 分页游标
  final String? cursor;

  ListDocumentsResponse({
    required this.documents,
    required this.hasMore,
    this.cursor,
  });

  factory ListDocumentsResponse.fromJson(Map<String, dynamic> json) {
    return ListDocumentsResponse(
      documents: (json['data'] as List<dynamic>?)
              ?.map((e) => Document.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      hasMore: json['has_more'] as bool? ?? false,
      cursor: json['cursor'] as String?,
    );
  }
}

/// 切片
class Slice {
  /// 切片 ID
  final String id;

  /// 文档 ID
  final String documentId;

  /// 切片内容
  final String content;

  /// 字符数
  final int charCount;

  /// 创建时间
  final DateTime createdAt;

  /// 更新时间
  final DateTime updatedAt;

  Slice({
    required this.id,
    required this.documentId,
    required this.content,
    required this.charCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Slice.fromJson(Map<String, dynamic> json) {
    return Slice(
      id: json['slice_id'] as String,
      documentId: json['document_id'] as String,
      content: json['content'] as String,
      charCount: json['char_count'] as int? ?? 0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (json['create_time'] as int) * 1000,
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        (json['update_time'] as int) * 1000,
      ),
    );
  }
}

/// 列出切片请求
class ListSlicesRequest {
  /// 文档 ID
  final String documentId;

  /// 分页大小
  final int? pageSize;

  /// 分页游标
  final String? cursor;

  ListSlicesRequest({
    required this.documentId,
    this.pageSize,
    this.cursor,
  });

  Map<String, dynamic> toJson() {
    return {
      'document_id': documentId,
      if (pageSize != null) 'page_size': pageSize,
      if (cursor != null) 'cursor': cursor,
    };
  }
}

/// 列出切片响应
class ListSlicesResponse {
  /// 切片列表
  final List<Slice> slices;

  /// 是否有更多
  final bool hasMore;

  /// 分页游标
  final String? cursor;

  ListSlicesResponse({
    required this.slices,
    required this.hasMore,
    this.cursor,
  });

  factory ListSlicesResponse.fromJson(Map<String, dynamic> json) {
    return ListSlicesResponse(
      slices: (json['data'] as List<dynamic>?)
              ?.map((e) => Slice.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      hasMore: json['has_more'] as bool? ?? false,
      cursor: json['cursor'] as String?,
    );
  }
}

/// 处理状态响应
class ProcessingStatusResponse {
  /// 文档 ID
  final String documentId;

  /// 处理状态
  final DocumentStatus status;

  /// 失败原因
  final String? failReason;

  ProcessingStatusResponse({
    required this.documentId,
    required this.status,
    this.failReason,
  });

  factory ProcessingStatusResponse.fromJson(Map<String, dynamic> json) {
    return ProcessingStatusResponse(
      documentId: json['document_id'] as String,
      status: DocumentStatus.values.firstWhere(
        (e) => e.name == (json['status'] ?? 'processing'),
        orElse: () => DocumentStatus.processing,
      ),
      failReason: json['fail_reason'] as String?,
    );
  }
}

// ========== 旧版 Knowledge API 模型 (已废弃) ==========

/// 列出知识库文档请求（旧版）
class ListKnowledgeDocumentsRequest {
  /// 数据集 ID
  final String datasetId;

  /// 页码
  final int? page;

  /// 分页大小
  final int? pageSize;

  ListKnowledgeDocumentsRequest({
    required this.datasetId,
    this.page,
    this.pageSize,
  });

  Map<String, dynamic> toJson() {
    return {
      'dataset_id': datasetId,
      if (page != null) 'page': page,
      if (pageSize != null) 'page_size': pageSize,
    };
  }
}

/// 列出知识库文档响应（旧版）
class ListKnowledgeDocumentsResponse {
  /// 总数
  final int total;

  /// 文档信息列表
  final List<KnowledgeDocumentInfo> documentInfos;

  ListKnowledgeDocumentsResponse({
    required this.total,
    required this.documentInfos,
  });

  factory ListKnowledgeDocumentsResponse.fromJson(Map<String, dynamic> json) {
    return ListKnowledgeDocumentsResponse(
      total: json['total'] as int? ?? 0,
      documentInfos: (json['document_infos'] as List<dynamic>?)
              ?.map((e) =>
                  KnowledgeDocumentInfo.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// 知识库文档信息（旧版）
class KnowledgeDocumentInfo {
  /// 字符数
  final int charCount;

  /// 分段策略
  final ChunkStrategy chunkStrategy;

  /// 创建时间
  final int createTime;

  /// 文档 ID
  final String documentId;

  /// 格式类型
  final int formatType;

  /// 命中次数
  final int hitCount;

  /// 名称
  final String name;

  /// 大小
  final int size;

  /// 切片数
  final int sliceCount;

  /// 状态
  final int status;

  /// 类型
  final String type;

  /// 更新间隔
  final int updateInterval;

  /// 更新时间
  final int updateTime;

  /// 更新类型
  final int updateType;

  /// TOS URI
  final String tosUri;

  KnowledgeDocumentInfo({
    required this.charCount,
    required this.chunkStrategy,
    required this.createTime,
    required this.documentId,
    required this.formatType,
    required this.hitCount,
    required this.name,
    required this.size,
    required this.sliceCount,
    required this.status,
    required this.type,
    required this.updateInterval,
    required this.updateTime,
    required this.updateType,
    required this.tosUri,
  });

  factory KnowledgeDocumentInfo.fromJson(Map<String, dynamic> json) {
    return KnowledgeDocumentInfo(
      charCount: json['char_count'] as int? ?? 0,
      chunkStrategy: ChunkStrategy.fromJson(
          json['chunk_strategy'] as Map<String, dynamic>? ?? {}),
      createTime: json['create_time'] as int? ?? 0,
      documentId: json['document_id'] as String,
      formatType: json['format_type'] as int? ?? 0,
      hitCount: json['hit_count'] as int? ?? 0,
      name: json['name'] as String,
      size: json['size'] as int? ?? 0,
      sliceCount: json['slice_count'] as int? ?? 0,
      status: json['status'] as int? ?? 0,
      type: json['type'] as String,
      updateInterval: json['update_interval'] as int? ?? 0,
      updateTime: json['update_time'] as int? ?? 0,
      updateType: json['update_type'] as int? ?? 0,
      tosUri: json['tos_uri'] as String? ?? '',
    );
  }
}

/// 分段策略
class ChunkStrategy {
  /// 分段类型
  final int chunkType;

  /// 分隔符
  final String? separator;

  /// 最大 Token 数
  final int? maxTokens;

  /// 是否移除额外空格
  final bool? removeExtraSpaces;

  /// 是否移除 URL 和邮箱
  final bool? removeUrlsEmails;

  /// 标题类型
  final int? captionType;

  ChunkStrategy({
    required this.chunkType,
    this.separator,
    this.maxTokens,
    this.removeExtraSpaces,
    this.removeUrlsEmails,
    this.captionType,
  });

  factory ChunkStrategy.fromJson(Map<String, dynamic> json) {
    return ChunkStrategy(
      chunkType: json['chunk_type'] as int? ?? 0,
      separator: json['separator'] as String?,
      maxTokens: json['max_tokens'] as int?,
      removeExtraSpaces: json['remove_extra_spaces'] as bool?,
      removeUrlsEmails: json['remove_urls_emails'] as bool?,
      captionType: json['caption_type'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chunk_type': chunkType,
      if (separator != null) 'separator': separator,
      if (maxTokens != null) 'max_tokens': maxTokens,
      if (removeExtraSpaces != null) 'remove_extra_spaces': removeExtraSpaces,
      if (removeUrlsEmails != null) 'remove_urls_emails': removeUrlsEmails,
      if (captionType != null) 'caption_type': captionType,
    };
  }
}

/// 创建知识库文档请求（旧版）
class CreateKnowledgeDocumentRequest {
  /// 数据集 ID
  final String datasetId;

  /// 文档基础信息列表
  final List<DocumentBase> documentBases;

  /// 分段策略
  final ChunkStrategy? chunkStrategy;

  /// 格式类型
  final int? formatType;

  CreateKnowledgeDocumentRequest({
    required this.datasetId,
    required this.documentBases,
    this.chunkStrategy,
    this.formatType,
  });

  Map<String, dynamic> toJson() {
    return {
      'dataset_id': datasetId,
      'document_bases': documentBases.map((e) => e.toJson()).toList(),
      if (chunkStrategy != null) 'chunk_strategy': chunkStrategy!.toJson(),
      if (formatType != null) 'format_type': formatType,
    };
  }
}

/// 文档基础信息
class DocumentBase {
  /// 名称
  final String name;

  /// 源信息
  final SourceInfo sourceInfo;

  /// 更新规则
  final UpdateRule? updateRule;

  DocumentBase({
    required this.name,
    required this.sourceInfo,
    this.updateRule,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'source_info': sourceInfo.toJson(),
      if (updateRule != null) 'update_rule': updateRule!.toJson(),
    };
  }
}

/// 源信息
class SourceInfo {
  /// 文件 Base64
  final String? fileBase64;

  /// 文件类型
  final String? fileType;

  /// Web URL
  final String? webUrl;

  /// 文档源
  final int? documentSource;

  /// 源文件 ID
  final String? sourceFileId;

  SourceInfo({
    this.fileBase64,
    this.fileType,
    this.webUrl,
    this.documentSource,
    this.sourceFileId,
  });

  Map<String, dynamic> toJson() {
    return {
      if (fileBase64 != null) 'file_base64': fileBase64,
      if (fileType != null) 'file_type': fileType,
      if (webUrl != null) 'web_url': webUrl,
      if (documentSource != null) 'document_source': documentSource,
      if (sourceFileId != null) 'source_file_id': sourceFileId,
    };
  }
}

/// 更新规则
class UpdateRule {
  /// 更新类型
  final int updateType;

  /// 更新间隔
  final int updateInterval;

  UpdateRule({
    required this.updateType,
    required this.updateInterval,
  });

  Map<String, dynamic> toJson() {
    return {
      'update_type': updateType,
      'update_interval': updateInterval,
    };
  }
}

/// 更新知识库文档请求（旧版）
class UpdateKnowledgeDocumentRequest {
  /// 文档 ID
  final String documentId;

  /// 文档名称
  final String? documentName;

  /// 更新规则
  final UpdateRule? updateRule;

  UpdateKnowledgeDocumentRequest({
    required this.documentId,
    this.documentName,
    this.updateRule,
  });

  Map<String, dynamic> toJson() {
    return {
      'document_id': documentId,
      if (documentName != null) 'document_name': documentName,
      if (updateRule != null) 'update_rule': updateRule!.toJson(),
    };
  }
}
