/// Bot 管理 API
///
/// 提供 Bot 的查询、发布等接口
library;

import '../../client/http_client.dart';
import '../../models/errors.dart';
import 'bots_models.dart';

/// Bot 管理 API 封装
///
/// 提供获取 Bot 信息、列出 Bot、发布 Bot 等功能
class BotsAPI {
  final HttpClient _client;

  /// 创建 Bots API 实例
  BotsAPI(this._client);

  /// 获取 Bot 信息
  ///
  /// [botId] Bot ID
  /// [spaceId] 空间 ID（可选），用于访问特定空间下的 Bot
  ///
  /// 返回 Bot 详情
  Future<Bot> retrieve(String botId, {String? spaceId}) async {
    final queryParameters = <String, String>{
      'bot_id': botId,
    };
    if (spaceId != null) {
      queryParameters['space_id'] = spaceId;
    }

    final response = await _client.get(
      '/v1/bot/get_online_info',
      queryParameters: queryParameters,
    );

    final data = response.jsonBody['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw CozeException(
        message: '获取 Bot 信息失败：响应数据为空',
      );
    }

    return Bot.fromJson(data);
  }

  /// 获取已发布的 Bot 信息
  ///
  /// [botId] Bot ID
  /// [spaceId] 空间 ID（可选），用于访问特定空间下的 Bot
  ///
  /// 返回已发布的 Bot 详情
  Future<Bot> retrievePublished(String botId, {String? spaceId}) async {
    final queryParameters = <String, String>{
      'bot_id': botId,
    };
    if (spaceId != null) {
      queryParameters['space_id'] = spaceId;
    }

    final response = await _client.get(
      '/v1/bot/get_published_info',
      queryParameters: queryParameters,
    );

    final data = response.jsonBody['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw CozeException(
        message: '获取已发布 Bot 信息失败：响应数据为空',
      );
    }

    return Bot.fromJson(data);
  }

  /// 列出 Bot 列表
  ///
  /// [request] 列出 Bot 请求
  ///
  /// 返回 Bot 列表和分页信息
  Future<ListBotsResponse> list(ListBotsRequest request) async {
    final response = await _client.post(
      '/v1/bot/list',
      body: request.toJson(),
    );

    return ListBotsResponse.fromJson(response.jsonBody);
  }

  /// 列出已发布的 Bot 列表
  ///
  /// [request] 列出 Bot 请求
  ///
  /// 返回已发布的 Bot 列表和分页信息
  Future<ListBotsResponse> listPublished(ListBotsRequest request) async {
    final response = await _client.post(
      '/v1/bot/list_published_bots',
      body: request.toJson(),
    );

    return ListBotsResponse.fromJson(response.jsonBody);
  }

  /// 发布 Bot
  ///
  /// [request] 发布 Bot 请求
  ///
  /// 返回发布结果
  Future<void> publish(PublishBotRequest request) async {
    await _client.post(
      '/v1/bot/publish',
      body: request.toJson(),
    );
  }

  /// 创建 Bot
  ///
  /// [request] 创建 Bot 请求
  ///
  /// 返回创建的 Bot ID
  Future<CreateBotResponse> create(CreateBotRequest request) async {
    final response = await _client.post(
      '/v1/bot/create',
      body: request.toJson(),
    );

    final data = response.jsonBody['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw CozeException(
        message: '创建 Bot 失败：响应数据为空',
      );
    }

    return CreateBotResponse.fromJson(data);
  }

  /// 更新 Bot
  ///
  /// [request] 更新 Bot 请求
  Future<void> update(UpdateBotRequest request) async {
    await _client.post(
      '/v1/bot/update',
      body: request.toJson(),
    );
  }

  /// 获取 Bot 信息（新版）
  ///
  /// [botId] Bot ID
  /// [request] 可选参数
  ///
  /// 返回 Bot 详情
  Future<Bot> retrieveNew(
    String botId, {
    RetrieveBotNewRequest? request,
  }) async {
    final response = await _client.get(
      '/v1/bots/$botId',
      queryParameters: request?.toJson().cast<String, String>(),
    );

    final data = response.jsonBody['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw CozeException(
        message: '获取 Bot 信息失败：响应数据为空',
      );
    }

    return Bot.fromJson(data);
  }

  /// 列出 Bot 列表（新版）
  ///
  /// [request] 列出 Bot 请求
  ///
  /// 返回 Bot 列表和分页信息
  Future<ListBotsNewResponse> listNew(ListBotsNewRequest request) async {
    final response = await _client.get(
      '/v1/bots',
      queryParameters: request.toJson().cast<String, String>(),
    );

    final data = response.jsonBody['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw CozeException(
        message: '获取 Bot 列表失败：响应数据为空',
      );
    }

    return ListBotsNewResponse.fromJson(data);
  }
}
