/// Datasets API
///
/// 提供数据集管理、文档管理、切片管理等功能
library;

import '../../client/http_client.dart';
import '../../models/errors.dart';
import 'datasets_models.dart';

/// Datasets API 封装
///
/// 提供数据集、文档、切片的完整管理功能
class DatasetsAPI {
  final HttpClient _client;

  /// 创建 Datasets API 实例
  DatasetsAPI(this._client);

  // ========== 数据集管理 ==========

  /// 创建数据集
  ///
  /// [request] 创建数据集请求
  ///
  /// 返回创建的数据集
  Future<Dataset> create(CreateDatasetRequest request) async {
    final response = await _client.post(
      '/v1/datasets',
      body: request.toJson(),
    );

    final data = response.jsonBody['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw CozeException(
        message: '创建数据集失败：响应数据为空',
      );
    }

    return Dataset.fromJson(data);
  }

  /// 获取数据集信息
  ///
  /// [datasetId] 数据集 ID
  ///
  /// 返回数据集详情
  Future<Dataset> retrieve(String datasetId) async {
    final response = await _client.get(
      '/v1/datasets',
      queryParameters: {
        'dataset_id': datasetId,
      },
    );

    final data = response.jsonBody['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw CozeException(
        message: '获取数据集信息失败：响应数据为空',
      );
    }

    return Dataset.fromJson(data);
  }

  /// 更新数据集
  ///
  /// [request] 更新数据集请求
  ///
  /// 返回更新后的数据集
  Future<Dataset> update(UpdateDatasetRequest request) async {
    final response = await _client.put(
      '/v1/datasets',
      body: request.toJson(),
    );

    final data = response.jsonBody['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw CozeException(
        message: '更新数据集失败：响应数据为空',
      );
    }

    return Dataset.fromJson(data);
  }

  /// 删除数据集
  ///
  /// [datasetId] 数据集 ID
  Future<void> delete(String datasetId) async {
    await _client.delete(
      '/v1/datasets',
      queryParameters: {
        'dataset_id': datasetId,
      },
    );
  }

  /// 列出数据集
  ///
  /// [request] 列出数据集请求
  ///
  /// 返回数据集列表
  Future<ListDatasetsResponse> list(ListDatasetsRequest request) async {
    final response = await _client.get(
      '/v1/datasets',
      queryParameters: request.toJson().cast<String, String>(),
    );

    return ListDatasetsResponse.fromJson(response.jsonBody);
  }

  // ========== 文档管理 ==========

  /// 创建文档
  ///
  /// [request] 创建文档请求
  ///
  /// 返回创建的文档
  Future<Document> createDocument(CreateDocumentRequest request) async {
    final response = await _client.post(
      '/v1/datasets/document',
      body: request.toJson(),
    );

    final data = response.jsonBody['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw CozeException(
        message: '创建文档失败：响应数据为空',
      );
    }

    return Document.fromJson(data);
  }

  /// 获取文档信息
  ///
  /// [documentId] 文档 ID
  ///
  /// 返回文档详情
  Future<Document> retrieveDocument(String documentId) async {
    final response = await _client.get(
      '/v1/datasets/document',
      queryParameters: {
        'document_id': documentId,
      },
    );

    final data = response.jsonBody['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw CozeException(
        message: '获取文档信息失败：响应数据为空',
      );
    }

    return Document.fromJson(data);
  }

  /// 更新文档
  ///
  /// [request] 更新文档请求
  ///
  /// 返回更新后的文档
  Future<Document> updateDocument(UpdateDocumentRequest request) async {
    final response = await _client.put(
      '/v1/datasets/document',
      body: request.toJson(),
    );

    final data = response.jsonBody['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw CozeException(
        message: '更新文档失败：响应数据为空',
      );
    }

    return Document.fromJson(data);
  }

  /// 删除文档
  ///
  /// [documentId] 文档 ID
  Future<void> deleteDocument(String documentId) async {
    await _client.delete(
      '/v1/datasets/document',
      queryParameters: {
        'document_id': documentId,
      },
    );
  }

  /// 列出文档
  ///
  /// [request] 列出文档请求
  ///
  /// 返回文档列表
  Future<ListDocumentsResponse> listDocuments(
      ListDocumentsRequest request) async {
    final response = await _client.get(
      '/v1/datasets/document',
      queryParameters: request.toJson().cast<String, String>(),
    );

    return ListDocumentsResponse.fromJson(response.jsonBody);
  }

  /// 获取文档处理状态
  ///
  /// [documentId] 文档 ID
  ///
  /// 返回处理状态
  Future<ProcessingStatusResponse> getProcessingStatus(
      String documentId) async {
    final response = await _client.get(
      '/v1/datasets/document/processing',
      queryParameters: {
        'document_id': documentId,
      },
    );

    final data = response.jsonBody['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw CozeException(
        message: '获取处理状态失败：响应数据为空',
      );
    }

    return ProcessingStatusResponse.fromJson(data);
  }

  // ========== 切片管理 ==========

  /// 列出切片
  ///
  /// [request] 列出切片请求
  ///
  /// 返回切片列表
  Future<ListSlicesResponse> listSlices(ListSlicesRequest request) async {
    final response = await _client.get(
      '/v1/datasets/slice',
      queryParameters: request.toJson().cast<String, String>(),
    );

    return ListSlicesResponse.fromJson(response.jsonBody);
  }

  /// 更新切片内容
  ///
  /// [sliceId] 切片 ID
  /// [content] 新内容
  Future<Slice> updateSlice(String sliceId, String content) async {
    final response = await _client.put(
      '/v1/datasets/slice',
      body: {
        'slice_id': sliceId,
        'content': content,
      },
    );

    final data = response.jsonBody['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw CozeException(
        message: '更新切片失败：响应数据为空',
      );
    }

    return Slice.fromJson(data);
  }

  /// 删除切片
  ///
  /// [sliceId] 切片 ID
  Future<void> deleteSlice(String sliceId) async {
    await _client.delete(
      '/v1/datasets/slice',
      queryParameters: {
        'slice_id': sliceId,
      },
    );
  }

  // ========== 旧版 Knowledge API (已废弃) ==========

  /// 列出知识库文档（旧版 API）
  ///
  /// [request] 列出文档请求
  ///
  /// 返回文档列表
  /// @deprecated 请使用 listDocuments 方法
  @deprecated
  Future<ListKnowledgeDocumentsResponse> listKnowledgeDocuments(
    ListKnowledgeDocumentsRequest request,
  ) async {
    final response = await _client.post(
      '/open_api/knowledge/document/list',
      body: request.toJson(),
      headers: {'agw-js-conv': 'str'},
    );

    return ListKnowledgeDocumentsResponse.fromJson(response.jsonBody);
  }

  /// 创建知识库文档（旧版 API）
  ///
  /// [request] 创建文档请求
  ///
  /// 返回创建的文档信息
  /// @deprecated 请使用 createDocument 方法
  @deprecated
  Future<List<KnowledgeDocumentInfo>> createKnowledgeDocument(
    CreateKnowledgeDocumentRequest request,
  ) async {
    final response = await _client.post(
      '/open_api/knowledge/document/create',
      body: request.toJson(),
      headers: {'agw-js-conv': 'str'},
    );

    final data = response.jsonBody['document_infos'] as List<dynamic>?;
    if (data == null) {
      throw CozeException(
        message: '创建知识库文档失败：响应数据为空',
      );
    }

    return data
        .map((e) => KnowledgeDocumentInfo.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// 删除知识库文档（旧版 API）
  ///
  /// [documentIds] 要删除的文档 ID 列表
  ///
  /// @deprecated 请使用 deleteDocument 方法
  @deprecated
  Future<void> deleteKnowledgeDocuments(List<String> documentIds) async {
    await _client.post(
      '/open_api/knowledge/document/delete',
      body: {'document_ids': documentIds},
      headers: {'agw-js-conv': 'str'},
    );
  }

  /// 更新知识库文档（旧版 API）
  ///
  /// [request] 更新文档请求
  ///
  /// @deprecated 请使用 updateDocument 方法
  @deprecated
  Future<void> updateKnowledgeDocument(
    UpdateKnowledgeDocumentRequest request,
  ) async {
    await _client.post(
      '/open_api/knowledge/document/update',
      body: request.toJson(),
      headers: {'agw-js-conv': 'str'},
    );
  }
}
