/// Templates API
///
/// 提供模板管理功能
library;

import '../../client/http_client.dart';
import '../../models/errors.dart';
import 'templates_models.dart';

/// Templates API 封装
///
/// 提供模板的完整管理功能
class TemplatesAPI {
  final HttpClient _client;

  /// 创建 Templates API 实例
  TemplatesAPI(this._client);

  /// 创建模板
  ///
  /// [request] 创建模板请求
  ///
  /// 返回创建的模板
  Future<Template> create(CreateTemplateRequest request) async {
    final response = await _client.post(
      '/v1/templates',
      body: request.toJson(),
    );

    final data = response.jsonBody['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw CozeException(
        message: '创建模板失败：响应数据为空',
      );
    }

    return Template.fromJson(data);
  }

  /// 获取模板信息
  ///
  /// [templateId] 模板 ID
  ///
  /// 返回模板详情
  Future<Template> retrieve(String templateId) async {
    final response = await _client.get(
      '/v1/templates',
      queryParameters: {
        'template_id': templateId,
      },
    );

    final data = response.jsonBody['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw CozeException(
        message: '获取模板信息失败：响应数据为空',
      );
    }

    return Template.fromJson(data);
  }

  /// 获取模板详情（包含变量信息）
  ///
  /// [templateId] 模板 ID
  ///
  /// 返回模板详情
  Future<TemplateDetail> retrieveDetail(String templateId) async {
    final response = await _client.get(
      '/v1/templates/detail',
      queryParameters: {
        'template_id': templateId,
      },
    );

    final data = response.jsonBody['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw CozeException(
        message: '获取模板详情失败：响应数据为空',
      );
    }

    return TemplateDetail.fromJson(data);
  }

  /// 更新模板
  ///
  /// [request] 更新模板请求
  ///
  /// 返回更新后的模板
  Future<Template> update(UpdateTemplateRequest request) async {
    final response = await _client.put(
      '/v1/templates',
      body: request.toJson(),
    );

    final data = response.jsonBody['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw CozeException(
        message: '更新模板失败：响应数据为空',
      );
    }

    return Template.fromJson(data);
  }

  /// 删除模板
  ///
  /// [templateId] 模板 ID
  Future<void> delete(String templateId) async {
    await _client.delete(
      '/v1/templates',
      queryParameters: {
        'template_id': templateId,
      },
    );
  }

  /// 列出模板
  ///
  /// [request] 列出模板请求
  ///
  /// 返回模板列表
  Future<ListTemplatesResponse> list(ListTemplatesRequest request) async {
    final response = await _client.get(
      '/v1/templates',
      queryParameters: request.toJson().cast<String, String>(),
    );

    return ListTemplatesResponse.fromJson(response.jsonBody);
  }

  /// 从模板创建 Bot
  ///
  /// [request] 从模板创建 Bot 请求
  ///
  /// 返回创建的 Bot 信息
  Future<CreateBotFromTemplateResponse> createBot(
    CreateBotFromTemplateRequest request,
  ) async {
    final response = await _client.post(
      '/v1/templates/create_bot',
      body: request.toJson(),
    );

    final data = response.jsonBody['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw CozeException(
        message: '从模板创建 Bot 失败：响应数据为空',
      );
    }

    return CreateBotFromTemplateResponse.fromJson(data);
  }

  /// 复制模板
  ///
  /// [templateId] 模板 ID
  /// [request] 复制模板请求
  ///
  /// 返回复制后的实体信息
  Future<DuplicateTemplateResponse> duplicate(
    String templateId,
    DuplicateTemplateRequest request,
  ) async {
    final response = await _client.post(
      '/v1/templates/$templateId/duplicate',
      body: request.toJson(),
    );

    final data = response.jsonBody['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw CozeException(
        message: '复制模板失败：响应数据为空',
      );
    }

    return DuplicateTemplateResponse.fromJson(data);
  }
}
