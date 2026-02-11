/// Knowledge Documents API (新版)
///
/// 提供知识库文档管理功能（新版 API）
library;

import '../../../client/http_client.dart';
import '../../../models/errors.dart';
import 'knowledge_documents_models.dart';

/// Knowledge Documents API 封装
///
/// 提供知识库文档的列表查询、创建、删除、更新功能
class KnowledgeDocumentsAPI {
  final HttpClient _client;

  /// 创建 Knowledge Documents API 实例
  KnowledgeDocumentsAPI(this._client);

  /// 列出知识库文档
  ///
  /// [request] 列出文档请求
  ///
  /// 返回文档列表
  Future<ListDocumentsResponse> list(ListDocumentsRequest request) async {
    final response = await _client.get(
      '/v1/knowledge/documents',
      queryParameters: request.toJson().cast<String, String>(),
    );

    return ListDocumentsResponse.fromJson(response.jsonBody);
  }

  /// 创建知识库文档
  ///
  /// [request] 创建文档请求
  ///
  /// 返回创建的文档信息
  Future<List<DocumentInfo>> create(CreateDocumentRequest request) async {
    final response = await _client.post(
      '/v1/knowledge/documents',
      body: request.toJson(),
    );

    final documentInfos = response.jsonBody['document_infos'] as List<dynamic>?;
    if (documentInfos == null) {
      throw CozeException(
        message: '创建知识库文档失败：响应数据为空',
      );
    }

    return documentInfos
        .map((e) => DocumentInfo.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// 删除知识库文档
  ///
  /// [request] 删除文档请求
  Future<void> delete(DeleteDocumentRequest request) async {
    await _client.post(
      '/v1/knowledge/documents/delete',
      body: request.toJson(),
    );
  }

  /// 更新知识库文档
  ///
  /// [request] 更新文档请求
  Future<void> update(UpdateDocumentRequest request) async {
    await _client.put(
      '/v1/knowledge/documents',
      body: request.toJson(),
    );
  }
}
