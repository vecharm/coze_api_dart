/// WebSocket Transcriptions API
///
/// 提供 WebSocket 语音转录功能
library;

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../client/http_client.dart';
import '../../../models/enums.dart';
import '../../../utils/logger.dart';

/// WebSocket Transcriptions API 封装
///
/// 提供实时语音转录功能
class WebSocketTranscriptionsAPI {
  final HttpClient _client;

  /// 创建 WebSocket Transcriptions API 实例
  WebSocketTranscriptionsAPI(this._client);

  /// 创建语音转录 WebSocket 连接
  ///
  /// [request] 创建语音转录请求
  ///
  /// 返回 WebSocket 连接
  Future<WebSocketTranscriptionsConnection> create({
    CreateTranscriptionsRequest? request,
  }) async {
    final queryParams = <String, String>{};
    if (request?.entityType != null) {
      queryParams['entity_type'] = request!.entityType!;
    }
    if (request?.entityId != null) {
      queryParams['entity_id'] = request!.entityId!;
    }

    final wsUrl = await _client.buildWebSocketUrl(
      '/v1/audio/transcriptions',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    final channel = WebSocketChannel.connect(Uri.parse(wsUrl));
    await channel.ready;

    return WebSocketTranscriptionsConnection(channel);
  }
}

/// 创建语音转录请求
class CreateTranscriptionsRequest {
  /// 实体类型
  final String? entityType;

  /// 实体 ID
  final String? entityId;

  CreateTranscriptionsRequest({
    this.entityType,
    this.entityId,
  });
}

/// WebSocket 语音转录连接
class WebSocketTranscriptionsConnection {
  final WebSocketChannel _channel;
  final _eventController = StreamController<TranscriptionEvent>.broadcast();

  /// 事件流
  Stream<TranscriptionEvent> get events => _eventController.stream;

  /// 创建 WebSocket 语音转录连接
  WebSocketTranscriptionsConnection(this._channel) {
    _channel.stream.listen(
      _handleMessage,
      onError: (error) {
        logE('WebSocket Transcriptions error: $error');
        _eventController.add(TranscriptionEvent(
          eventType: WebsocketsEventType.error,
          data: {'error': error.toString()},
        ));
      },
      onDone: () {
        logI('WebSocket Transcriptions connection closed');
      },
    );
  }

  /// 处理消息
  void _handleMessage(dynamic message) {
    try {
      final data = jsonDecode(message as String) as Map<String, dynamic>;
      final eventType = _parseEventType(data['event'] as String?);
      _eventController.add(TranscriptionEvent(
        eventType: eventType,
        data: data,
      ));
    } catch (e) {
      logW('Failed to parse transcription event: $message');
    }
  }

  /// 解析事件类型
  WebsocketsEventType _parseEventType(String? event) {
    if (event == null) return WebsocketsEventType.error;

    final eventMap = {
      'transcriptions.created': WebsocketsEventType.conversationChatCreated,
      'transcriptions.updated': WebsocketsEventType.conversationMessageUpdate,
      'input_audio_buffer.completed': WebsocketsEventType.inputAudioBufferCompleted,
      'input_audio_buffer.cleared': WebsocketsEventType.inputAudioBufferCleared,
      'transcriptions.message.update': WebsocketsEventType.conversationSpeechToTextUpdated,
      'transcriptions.message.completed': WebsocketsEventType.conversationSpeechToTextCompleted,
      'error': WebsocketsEventType.error,
    };

    return eventMap[event] ?? WebsocketsEventType.error;
  }

  /// 追加音频缓冲区
  void appendAudioBuffer(Uint8List audioData) {
    _send({
      'event': 'input_audio_buffer.append',
      'data': {
        'audio': base64Encode(audioData),
      },
    });
  }

  /// 完成音频缓冲区
  void completeAudioBuffer() {
    _send({
      'event': 'input_audio_buffer.complete',
      'data': {},
    });
  }

  /// 清除音频缓冲区
  void clearAudioBuffer() {
    _send({
      'event': 'input_audio_buffer.clear',
      'data': {},
    });
  }

  /// 发送消息
  void _send(Map<String, dynamic> data) {
    if (_channel.closeCode == null) {
      _channel.sink.add(jsonEncode(data));
    }
  }

  /// 关闭连接
  Future<void> close() async {
    await _channel.sink.close();
    await _eventController.close();
  }
}

/// 语音转录事件
class TranscriptionEvent {
  /// 事件类型
  final WebsocketsEventType eventType;

  /// 事件数据
  final Map<String, dynamic> data;

  TranscriptionEvent({
    required this.eventType,
    required this.data,
  });
}
