/// Audio Live API
///
/// 提供实时音频直播功能
library;

import '../../../client/http_client.dart';
import '../../../models/errors.dart';
import 'live_models.dart';

/// Audio Live API 封装
///
/// 提供实时音频直播的拉流功能
class AudioLiveAPI {
  final HttpClient _client;

  /// 创建 Audio Live API 实例
  AudioLiveAPI(this._client);

  /// 获取直播信息
  ///
  /// [liveId] 直播 ID
  ///
  /// 返回直播信息
  Future<RetrieveLiveData> retrieve(String liveId) async {
    final response = await _client.get('/v1/audio/live/$liveId');

    final data = response.jsonBody['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw CozeException(
        message: '获取直播信息失败：响应数据为空',
      );
    }

    return RetrieveLiveData.fromJson(data);
  }
}
