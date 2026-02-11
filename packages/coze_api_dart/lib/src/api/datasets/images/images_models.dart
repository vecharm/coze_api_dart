/// Datasets Images API 数据模型
///
/// 包含数据集图片管理相关的所有数据模型定义
library;

/// 列出图片请求
class ListImagesRequest {
  /// 页码，最小值为 1，默认为 1
  final int? pageNum;

  /// 每页数量，范围 1-299，默认为 10
  final int? pageSize;

  /// 图片描述的搜索关键词
  final String? keyword;

  /// 是否过滤有/无描述的图片
  final bool? hasCaption;

  ListImagesRequest({
    this.pageNum,
    this.pageSize,
    this.keyword,
    this.hasCaption,
  });

  Map<String, dynamic> toJson() {
    return {
      if (pageNum != null) 'page_num': pageNum.toString(),
      if (pageSize != null) 'page_size': pageSize.toString(),
      if (keyword != null) 'keyword': keyword,
      if (hasCaption != null) 'has_caption': hasCaption.toString(),
    };
  }
}

/// 列出图片响应
class ListImagesResponse {
  /// 图片信息列表
  final List<ImageInfo> photoInfos;

  /// 图片总数
  final int totalCount;

  ListImagesResponse({
    required this.photoInfos,
    required this.totalCount,
  });

  factory ListImagesResponse.fromJson(Map<String, dynamic> json) {
    return ListImagesResponse(
      photoInfos: (json['photo_infos'] as List<dynamic>?)
              ?.map((e) => ImageInfo.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      totalCount: json['total_count'] as int? ?? 0,
    );
  }
}

/// 图片信息
class ImageInfo {
  /// 图片 URL
  final String url;

  /// 图片名称
  final String name;

  /// 图片大小（字节）
  final int size;

  /// 文件格式/扩展名（如 jpg, png）
  final String type;

  /// 文件处理状态
  /// 0: 处理中
  /// 1: 已处理
  /// 9: 处理失败，建议重新上传
  final int status;

  /// 图片描述
  final String caption;

  /// 创建者 Coze ID
  final String creatorId;

  /// 上传时间（10位 Unix 时间戳）
  final int createTime;

  /// 图片 ID
  final String documentId;

  /// 上传方式
  /// 0: 本地文件上传
  /// 1: 在线网页上传
  /// 5: file_id 上传
  final int sourceType;

  /// 更新时间（10位 Unix 时间戳）
  final int updateTime;

  ImageInfo({
    required this.url,
    required this.name,
    required this.size,
    required this.type,
    required this.status,
    required this.caption,
    required this.creatorId,
    required this.createTime,
    required this.documentId,
    required this.sourceType,
    required this.updateTime,
  });

  factory ImageInfo.fromJson(Map<String, dynamic> json) {
    return ImageInfo(
      url: json['url'] as String,
      name: json['name'] as String,
      size: json['size'] as int,
      type: json['type'] as String,
      status: json['status'] as int,
      caption: json['caption'] as String,
      creatorId: json['creator_id'] as String,
      createTime: json['create_time'] as int,
      documentId: json['document_id'] as String,
      sourceType: json['source_type'] as int,
      updateTime: json['update_time'] as int,
    );
  }
}

/// 更新图片描述请求
class UpdateImageRequest {
  /// 图片描述
  final String caption;

  UpdateImageRequest({
    required this.caption,
  });

  Map<String, dynamic> toJson() {
    return {
      'caption': caption,
    };
  }
}
