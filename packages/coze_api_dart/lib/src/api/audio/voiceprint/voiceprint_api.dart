/// Audio Voiceprint Groups API
///
/// 提供声纹组管理功能
library;

import '../../../client/http_client.dart';
import '../../../models/errors.dart';
import 'voiceprint_models.dart';

/// Audio Voiceprint Groups API 封装
///
/// 提供声纹特征的创建、更新、删除、列表查询和说话人识别功能
class AudioVoiceprintAPI {
  final HttpClient _client;

  /// 创建 Audio Voiceprint API 实例
  AudioVoiceprintAPI(this._client);

  /// 创建声纹特征
  ///
  /// [groupId] 声纹组 ID
  /// [request] 创建声纹特征请求
  ///
  /// 返回创建的特征 ID
  Future<CreateVoiceprintFeatureResponse> createFeature(
    String groupId,
    CreateVoiceprintFeatureRequest request,
  ) async {
    final response = await _client.post(
      '/v1/audio/voiceprint_groups/$groupId/features',
      body: request.toJson(),
    );

    final data = response.jsonBody['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw CozeException(
        message: '创建声纹特征失败：响应数据为空',
      );
    }

    return CreateVoiceprintFeatureResponse.fromJson(data);
  }

  /// 更新声纹特征
  ///
  /// [groupId] 声纹组 ID
  /// [featureId] 特征 ID
  /// [request] 更新声纹特征请求
  Future<void> updateFeature(
    String groupId,
    String featureId,
    UpdateVoiceprintFeatureRequest request,
  ) async {
    await _client.put(
      '/v1/audio/voiceprint_groups/$groupId/features/$featureId',
      body: request.toJson(),
    );
  }

  /// 删除声纹特征
  ///
  /// [groupId] 声纹组 ID
  /// [featureId] 特征 ID
  Future<void> deleteFeature(
    String groupId,
    String featureId,
  ) async {
    await _client.delete(
      '/v1/audio/voiceprint_groups/$groupId/features/$featureId',
    );
  }

  /// 获取声纹特征列表
  ///
  /// [groupId] 声纹组 ID
  /// [request] 列出声纹特征请求（可选）
  ///
  /// 返回声纹特征列表
  Future<ListVoiceprintFeatureResponse> listFeatures(
    String groupId, {
    ListVoiceprintFeatureRequest? request,
  }) async {
    final response = await _client.get(
      '/v1/audio/voiceprint_groups/$groupId/features',
      queryParameters: request?.toJson().cast<String, String>(),
    );

    final data = response.jsonBody['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw CozeException(
        message: '获取声纹特征列表失败：响应数据为空',
      );
    }

    return ListVoiceprintFeatureResponse.fromJson(data);
  }

  /// 说话人识别
  ///
  /// [groupId] 声纹组 ID
  /// [request] 说话人识别请求
  ///
  /// 返回识别结果
  Future<SpeakerIdentifyResponse> speakerIdentify(
    String groupId,
    SpeakerIdentifyRequest request,
  ) async {
    final response = await _client.post(
      '/v1/audio/voiceprint_groups/$groupId/speaker_identify',
      body: request.toJson(),
    );

    final data = response.jsonBody['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw CozeException(
        message: '说话人识别失败：响应数据为空',
      );
    }

    return SpeakerIdentifyResponse.fromJson(data);
  }
}
