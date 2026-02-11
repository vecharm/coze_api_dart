/// Knowledge Documents API 数据模型 (新版)
///
/// 包含知识库文档管理相关的所有数据模型定义
library;

/// 列出文档请求
class ListDocumentsRequest {
  /// 知识库 ID
  final String datasetId;

  /// 页码
  final int? page;

  /// 分页大小
  final int? pageSize;

  ListDocumentsRequest({
    required this.datasetId,
    this.page,
    this.pageSize,
  });

  Map<String, dynamic> toJson() {
    return {
      'dataset_id': datasetId,
      if (page != null) 'page': page.toString(),
      if (pageSize != null) 'page_size': pageSize.toString(),
    };
  }
}

/// 列出文档响应
class ListDocumentsResponse {
  /// 总数
  final int total;

  /// 文档信息列表
  final List<DocumentInfo> documentInfos;

  ListDocumentsResponse({
    required this.total,
    required this.documentInfos,
  });

  factory ListDocumentsResponse.fromJson(Map<String, dynamic> json) {
    return ListDocumentsResponse(
      total: json['total'] as int? ?? 0,
      documentInfos: (json['document_infos'] as List<dynamic>?)
              ?.map((e) => DocumentInfo.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// 创建文档请求
class CreateDocumentRequest {
  /// 知识库 ID
  final String datasetId;

  /// 文档基础信息列表
  final List<DocumentBase> documentBases;

  /// 分段策略
  final ChunkStrategy? chunkStrategy;

  CreateDocumentRequest({
    required this.datasetId,
    required this.documentBases,
    this.chunkStrategy,
  });

  Map<String, dynamic> toJson() {
    return {
      'dataset_id': datasetId,
      'document_bases': documentBases.map((e) => e.toJson()).toList(),
      if (chunkStrategy != null) 'chunk_strategy': chunkStrategy!.toJson(),
    };
  }
}

/// 删除文档请求
class DeleteDocumentRequest {
  /// 文档 ID 列表
  final List<String> documentIds;

  DeleteDocumentRequest({
    required this.documentIds,
  });

  Map<String, dynamic> toJson() {
    return {
      'document_ids': documentIds,
    };
  }
}

/// 更新文档请求
class UpdateDocumentRequest {
  /// 文档 ID
  final String documentId;

  /// 文档名称
  final String? documentName;

  /// 更新规则
  final UpdateRule? updateRule;

  UpdateDocumentRequest({
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

/// 文档信息
class DocumentInfo {
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

  /// 切片数量
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

  DocumentInfo({
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
  });

  factory DocumentInfo.fromJson(Map<String, dynamic> json) {
    return DocumentInfo(
      charCount: json['char_count'] as int,
      chunkStrategy: ChunkStrategy.fromJson(
          json['chunk_strategy'] as Map<String, dynamic>),
      createTime: json['create_time'] as int,
      documentId: json['document_id'] as String,
      formatType: json['format_type'] as int,
      hitCount: json['hit_count'] as int,
      name: json['name'] as String,
      size: json['size'] as int,
      sliceCount: json['slice_count'] as int,
      status: json['status'] as int,
      type: json['type'] as String,
      updateInterval: json['update_interval'] as int,
      updateTime: json['update_time'] as int,
      updateType: json['update_type'] as int,
    );
  }
}

/// 分段策略
class ChunkStrategy {
  /// 分段类型
  final int chunkType;

  /// 分隔符
  final String? separator;

  /// 最大 token 数
  final int? maxTokens;

  /// 是否移除额外空格
  final bool? removeExtraSpaces;

  /// 是否移除 URL 和邮箱
  final bool? removeUrlsEmails;

  ChunkStrategy({
    required this.chunkType,
    this.separator,
    this.maxTokens,
    this.removeExtraSpaces,
    this.removeUrlsEmails,
  });

  factory ChunkStrategy.fromJson(Map<String, dynamic> json) {
    return ChunkStrategy(
      chunkType: json['chunk_type'] as int,
      separator: json['separator'] as String?,
      maxTokens: json['max_tokens'] as int?,
      removeExtraSpaces: json['remove_extra_spaces'] as bool?,
      removeUrlsEmails: json['remove_urls_emails'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chunk_type': chunkType,
      if (separator != null) 'separator': separator,
      if (maxTokens != null) 'max_tokens': maxTokens,
      if (removeExtraSpaces != null) 'remove_extra_spaces': removeExtraSpaces,
      if (removeUrlsEmails != null) 'remove_urls_emails': removeUrlsEmails,
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

  /// 网页 URL
  final String? webUrl;

  /// 文档来源
  final int? documentSource;

  SourceInfo({
    this.fileBase64,
    this.fileType,
    this.webUrl,
    this.documentSource,
  });

  Map<String, dynamic> toJson() {
    return {
      if (fileBase64 != null) 'file_base64': fileBase64,
      if (fileType != null) 'file_type': fileType,
      if (webUrl != null) 'web_url': webUrl,
      if (documentSource != null) 'document_source': documentSource,
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
