/// 文件 API
///
/// 提供文件上传、查询、管理等接口
library;

import '../../client/http_client.dart';
import '../../models/errors.dart';
import 'files_models.dart';

/// 文件 API 封装
///
/// 提供上传文件、获取文件信息、列出文件等功能
class FilesAPI {
  final HttpClient _client;

  /// 创建文件 API 实例
  FilesAPI(this._client);

  /// 上传文件
  ///
  /// [request] 上传文件请求，包含文件字节数据和元信息
  ///
  /// 返回上传后的文件信息
  Future<CozeFile> upload(UploadFileRequest request) async {
    // 检测 MIME 类型
    final mimeType = request.mimeType ?? _detectMimeType(request.fileName);

    final response = await _client.uploadFile(
      '/v1/files/upload',
      fileBytes: request.fileBytes,
      filename: request.fileName,
      contentType: mimeType,
    );

    final data = response.jsonBody['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw CozeException(
        message: '上传文件失败：响应数据为空',
      );
    }

    return CozeFile.fromJson(data);
  }

  /// 获取文件信息
  ///
  /// [fileId] 文件 ID
  ///
  /// 返回文件详情
  Future<CozeFile> retrieve(String fileId) async {
    final response = await _client.get(
      '/v1/files/retrieve',
      queryParameters: {
        'file_id': fileId,
      },
    );

    final data = response.jsonBody['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw CozeException(
        message: '获取文件信息失败：响应数据为空',
      );
    }

    return CozeFile.fromJson(data);
  }

  /// 列出文件列表
  ///
  /// [request] 列出文件请求
  ///
  /// 返回文件列表和分页信息
  Future<ListFilesResponse> list(ListFilesRequest request) async {
    final response = await _client.post(
      '/v1/files',
      body: request.toJson(),
    );

    return ListFilesResponse.fromJson(response.jsonBody);
  }

  /// 删除文件
  ///
  /// [fileId] 文件 ID
  Future<void> delete(String fileId) async {
    await _client.post(
      '/v1/files/delete',
      body: {
        'file_id': fileId,
      },
    );
  }

  /// 检测 MIME 类型
  String _detectMimeType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();

    final mimeTypes = <String, String>{
      // 图片
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'png': 'image/png',
      'gif': 'image/gif',
      'webp': 'image/webp',
      'bmp': 'image/bmp',
      'svg': 'image/svg+xml',
      // 文档
      'pdf': 'application/pdf',
      'doc': 'application/msword',
      'docx':
          'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'txt': 'text/plain',
      'md': 'text/markdown',
      'json': 'application/json',
      'csv': 'text/csv',
      // 音频
      'mp3': 'audio/mpeg',
      'wav': 'audio/wav',
      'ogg': 'audio/ogg',
      'm4a': 'audio/mp4',
      // 视频
      'mp4': 'video/mp4',
      'avi': 'video/x-msvideo',
      'mov': 'video/quicktime',
      'webm': 'video/webm',
    };

    return mimeTypes[extension] ?? 'application/octet-stream';
  }
}
