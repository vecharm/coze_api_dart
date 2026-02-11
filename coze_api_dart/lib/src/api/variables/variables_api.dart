/// Variables API
///
/// 提供变量管理功能
library;

import '../../client/http_client.dart';
import '../../models/errors.dart';
import 'variables_models.dart';

/// Variables API 封装
///
/// 提供 Bot 和应用变量的管理功能
class VariablesAPI {
  final HttpClient _client;

  /// 创建 Variables API 实例
  VariablesAPI(this._client);

  /// 更新变量值
  ///
  /// [request] 更新变量请求
  ///
  /// 设置 Bot 或应用中的用户变量值
  Future<void> update(UpdateVariablesRequest request) async {
    await _client.put(
      '/v1/variables',
      body: request.toJson(),
    );
  }

  /// 获取变量值
  ///
  /// [request] 获取变量请求
  ///
  /// 返回变量值列表
  Future<VariablesData> retrieve(RetrieveVariablesRequest request) async {
    final response = await _client.get(
      '/v1/variables',
      queryParameters: request.toJson().cast<String, String>(),
    );

    final data = response.jsonBody['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw CozeException(
        message: '获取变量失败：响应数据为空',
      );
    }

    return VariablesData.fromJson(data);
  }
}
