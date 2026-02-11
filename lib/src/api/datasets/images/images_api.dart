/// Datasets Images API
///
/// 提供数据集图片管理功能
library;

import '../../../client/http_client.dart';
import '../../../models/errors.dart';
import 'images_models.dart';

/// Datasets Images API 封装
///
/// 提供数据集中图片的列表查询和描述更新功能
class DatasetsImagesAPI {
  final HttpClient _client;

  /// 创建 Datasets Images API 实例
  DatasetsImagesAPI(this._client);

  /// 列出数据集中的图片
  ///
  /// [datasetId] 数据集 ID
  /// [request] 列出图片请求（可选）
  ///
  /// 返回图片列表
  Future<ListImagesResponse> list(
    String datasetId, {
    ListImagesRequest? request,
  }) async {
    final response = await _client.get(
      '/v1/datasets/$datasetId/images',
      queryParameters: request?.toJson().cast<String, String>(),
    );

    final data = response.jsonBody['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw CozeException(
        message: '获取图片列表失败：响应数据为空',
      );
    }

    return ListImagesResponse.fromJson(data);
  }

  /// 更新图片描述
  ///
  /// [datasetId] 数据集 ID
  /// [documentId] 文档（图片）ID
  /// [request] 更新图片描述请求
  ///
  /// 更新知识库中图片的描述信息
  Future<void> update(
    String datasetId,
    String documentId,
    UpdateImageRequest request,
  ) async {
    await _client.put(
      '/v1/datasets/$datasetId/images/$documentId',
      body: request.toJson(),
    );
  }
}
