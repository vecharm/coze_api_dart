/// Workspaces API
///
/// 提供工作空间管理功能
library;

import '../../client/http_client.dart';
import '../../models/errors.dart';
import 'workspaces_models.dart';

/// Workspaces API 封装
///
/// 提供工作空间的查询功能
class WorkspacesAPI {
  final HttpClient _client;

  /// 创建 Workspaces API 实例
  WorkspacesAPI(this._client);

  /// 列出工作空间
  ///
  /// [request] 列出工作空间请求（可选）
  ///
  /// 返回工作空间列表
  Future<ListWorkspacesResponse> list({ListWorkspacesRequest? request}) async {
    final response = await _client.get(
      '/v1/workspaces',
      queryParameters: request?.toJson().cast<String, String>(),
    );

    final data = response.jsonBody['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw CozeException(
        message: '获取工作空间列表失败：响应数据为空',
      );
    }

    return ListWorkspacesResponse.fromJson(data);
  }
}
