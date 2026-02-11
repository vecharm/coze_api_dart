/// Audio Voices API
///
/// 提供语音克隆和语音列表功能
library;

import '../../../client/http_client.dart';
import '../../../models/errors.dart';
import 'voices_models.dart';

/// Audio Voices API 封装
///
/// 提供语音克隆、语音列表查询功能
class AudioVoicesAPI {
  final HttpClient _client;

  /// 创建 Audio Voices API 实例
  AudioVoicesAPI(this._client);

  /// 克隆语音
  ///
  /// [request] 克隆语音请求
  ///
  /// 返回克隆后的语音 ID
  Future<CloneVoiceResponse> clone(CloneVoiceRequest request) async {
    final response = await _client.post(
      '/v1/audio/voices/clone',
      body: request.toJson(),
    );

    final data = response.jsonBody['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw CozeException(
        message: '克隆语音失败：响应数据为空',
      );
    }

    return CloneVoiceResponse.fromJson(data);
  }

  /// 列出语音列表
  ///
  /// [request] 列出语音请求（可选）
  ///
  /// 返回语音列表
  Future<ListVoicesResponse> list({ListVoicesRequest? request}) async {
    final response = await _client.get(
      '/v1/audio/voices',
      queryParameters: request?.toJson().cast<String, String>(),
    );

    final data = response.jsonBody['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw CozeException(
        message: '获取语音列表失败：响应数据为空',
      );
    }

    return ListVoicesResponse.fromJson(data);
  }
}
