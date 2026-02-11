/// Audio Rooms API
///
/// 提供音频房间管理功能
library;

import '../../../client/http_client.dart';
import '../../../models/errors.dart';
import 'rooms_models.dart';

/// Audio Rooms API 封装
///
/// 提供音频房间的创建和管理功能
class AudioRoomsAPI {
  final HttpClient _client;

  /// 创建 Audio Rooms API 实例
  AudioRoomsAPI(this._client);

  /// 创建音频房间
  ///
  /// [request] 创建房间请求
  ///
  /// 返回创建的房间信息
  Future<CreateRoomResponse> create(CreateRoomRequest request) async {
    final response = await _client.post(
      '/v1/audio/rooms',
      body: request.toJson(),
    );

    final data = response.jsonBody['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw CozeException(
        message: '创建音频房间失败：响应数据为空',
      );
    }

    return CreateRoomResponse.fromJson(data);
  }
}
