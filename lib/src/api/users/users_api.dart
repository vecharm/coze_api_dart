
/// Users API
///
/// 提供用户信息管理功能
library;

import '../../client/http_client.dart';
import '../../models/errors.dart';
import 'users_models.dart';

/// Users API 封装
///
/// 提供用户信息的查询和管理功能
class UsersAPI {
  final HttpClient _client;

  /// 创建 Users API 实例
  UsersAPI(this._client);

  /// 获取当前登录用户信息
  ///
  /// 返回当前用户详细信息
  Future<CurrentUser> me() async {
    final response = await _client.get('/v1/users/me');

    final data = response.jsonBody['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw CozeException(
        message: '获取用户信息失败：响应数据为空',
      );
    }

    return CurrentUser.fromJson(data);
  }

  /// 获取指定用户信息
  ///
  /// [userId] 用户 ID
  ///
  /// 返回用户详情
  Future<User> retrieve(String userId) async {
    final response = await _client.get(
      '/v1/users',
      queryParameters: {
        'user_id': userId,
      },
    );

    final data = response.jsonBody['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw CozeException(
        message: '获取用户信息失败：响应数据为空',
      );
    }

    return User.fromJson(data);
  }

  /// 更新当前用户信息
  ///
  /// [request] 更新用户请求
  ///
  /// 返回更新后的用户信息
  Future<CurrentUser> update(UpdateUserRequest request) async {
    final response = await _client.put(
      '/v1/users',
      body: request.toJson(),
    );

    final data = response.jsonBody['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw CozeException(
        message: '更新用户信息失败：响应数据为空',
      );
    }

    return CurrentUser.fromJson(data);
  }

  /// 获取用户配额信息
  ///
  /// [userId] 用户 ID（可选，默认为当前用户）
  ///
  /// 返回用户配额信息
  Future<UserQuota> getQuota({String? userId}) async {
    final queryParameters = <String, String>{};
    if (userId != null) {
      queryParameters['user_id'] = userId;
    }

    final response = await _client.get(
      '/v1/users/quota',
      queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
    );

    final data = response.jsonBody['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw CozeException(
        message: '获取用户配额失败：响应数据为空',
      );
    }

    return UserQuota.fromJson(data);
  }

  /// 获取用户使用统计
  ///
  /// [userId] 用户 ID（可选，默认为当前用户）
  ///
  /// 返回用户使用统计
  Future<UserUsageStats> getUsageStats({String? userId}) async {
    final queryParameters = <String, String>{};
    if (userId != null) {
      queryParameters['user_id'] = userId;
    }

    final response = await _client.get(
      '/v1/users/usage_stats',
      queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
    );

    final data = response.jsonBody['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw CozeException(
        message: '获取使用统计失败：响应数据为空',
      );
    }

    return UserUsageStats.fromJson(data);
  }
}
