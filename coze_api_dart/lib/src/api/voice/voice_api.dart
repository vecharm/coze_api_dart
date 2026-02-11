
/// Voice API
///
/// 提供语音合成、语音识别等接口
library;

import '../../client/http_client.dart';
import '../../models/errors.dart';
import 'voice_models.dart';

/// Voice API 封装
///
/// 提供语音合成、语音识别、语音转录等功能
class VoiceAPI {
  final HttpClient _client;

  /// 创建 Voice API 实例
  VoiceAPI(this._client);

  /// 语音合成（Text to Speech）
  ///
  /// [request] 语音合成请求
  ///
  /// 返回合成的音频数据
  Future<TTSResponse> synthesize(TTSRequest request) async {
    final response = await _client.post(
      '/v1/audio/speech',
      body: request.toJson(),
    );

    final data = response.jsonBody['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw CozeException(
        message: '语音合成失败：响应数据为空',
      );
    }

    return TTSResponse.fromJson(data);
  }

  /// 语音识别（Speech to Text）
  ///
  /// [request] 语音识别请求
  ///
  /// 返回识别文本
  Future<STTResponse> recognize(STTRequest request) async {
    final response = await _client.post(
      '/v1/audio/transcriptions',
      body: request.toJson(),
    );

    final data = response.jsonBody['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw CozeException(
        message: '语音识别失败：响应数据为空',
      );
    }

    return STTResponse.fromJson(data);
  }

  /// 创建语音转录任务
  ///
  /// [request] 转录请求
  ///
  /// 返回转录任务 ID
  Future<TranscriptionResponse> createTranscription(
    TranscriptionRequest request,
  ) async {
    final response = await _client.post(
      '/v1/audio/transcriptions',
      body: request.toJson(),
    );

    final data = response.jsonBody['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw CozeException(
        message: '创建转录任务失败：响应数据为空',
      );
    }

    return TranscriptionResponse.fromJson(data);
  }

  /// 获取转录任务状态
  ///
  /// [transcriptionId] 转录任务 ID
  ///
  /// 返回转录状态和结果
  Future<TranscriptionResponse> getTranscription(String transcriptionId) async {
    final response = await _client.get(
      '/v1/audio/transcriptions',
      queryParameters: {
        'transcription_id': transcriptionId,
      },
    );

    final data = response.jsonBody['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw CozeException(
        message: '获取转录任务失败：响应数据为空',
      );
    }

    return TranscriptionResponse.fromJson(data);
  }

  /// 列出可用语音
  ///
  /// [request] 列出语音请求
  ///
  /// 返回语音列表
  Future<ListVoicesResponse> listVoices(ListVoicesRequest request) async {
    final response = await _client.post(
      '/v1/audio/voices',
      body: request.toJson(),
    );

    return ListVoicesResponse.fromJson(response.jsonBody);
  }
}
