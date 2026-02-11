/// WebSocket Speech API
///
/// 提供 WebSocket 语音合成功能
library;

import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../client/http_client.dart';
import '../../../models/enums.dart';
import '../../../utils/logger.dart';

/// WebSocket Speech API 封装
///
/// 提供实时语音合成功能
class WebSocketSpeechAPI {
  final HttpClient _client;

  /// 创建 WebSocket Speech API 实例
  WebSocketSpeechAPI(this._client);

  /// 创建语音合成 WebSocket 连接
  ///
  /// [request] 创建语音合成请求
  ///
  /// 返回 WebSocket 连接
  Future<WebSocketSpeechConnection> create({
    CreateSpeechRequest? request,
  }) async {
    final queryParams = <String, String>{};
    if (request?.entityType != null) {
      queryParams['entity_type'] = request!.entityType!;
    }
    if (request?.entityId != null) {
      queryParams['entity_id'] = request!.entityId!;
    }

    final wsUrl = await _client.buildWebSocketUrl(
      '/v1/audio/speech',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    final channel = WebSocketChannel.connect(Uri.parse(wsUrl));
    await channel.ready;

    return WebSocketSpeechConnection(channel);
  }
}

/// 创建语音合成请求
class CreateSpeechRequest {
  /// 实体类型
  final String? entityType;

  /// 实体 ID
  final String? entityId;

  CreateSpeechRequest({
    this.entityType,
    this.entityId,
  });
}

/// WebSocket 语音合成连接
class WebSocketSpeechConnection {
  final WebSocketChannel _channel;
  final _eventController = StreamController<SpeechEvent>.broadcast();

  /// 事件流
  Stream<SpeechEvent> get events => _eventController.stream;

  /// 创建 WebSocket 语音合成连接
  WebSocketSpeechConnection(this._channel) {
    _channel.stream.listen(
      _handleMessage,
      onError: (error) {
        logE('WebSocket Speech error: $error');
        _eventController.add(SpeechEvent(
          eventType: WebsocketsEventType.error,
          data: {'error': error.toString()},
        ));
      },
      onDone: () {
        logI('WebSocket Speech connection closed');
      },
    );
  }

  /// 处理消息
  void _handleMessage(dynamic message) {
    try {
      final data = jsonDecode(message as String) as Map<String, dynamic>;
      final eventType = _parseEventType(data['event'] as String?);
      _eventController.add(SpeechEvent(
        eventType: eventType,
        data: data,
      ));
    } catch (e) {
      logW('Failed to parse speech event: $message');
    }
  }

  /// 解析事件类型
  WebsocketsEventType _parseEventType(String? event) {
    if (event == null) return WebsocketsEventType.error;

    final eventMap = {
      'speech.created': WebsocketsEventType.conversationChatCreated,
      'input_text_buffer.completed':
          WebsocketsEventType.inputAudioBufferCompleted,
      'speech.updated': WebsocketsEventType.conversationTtsMessageUpdate,
      'speech.audio.update': WebsocketsEventType.conversationAudioCompleted,
      'speech.audio.completed': WebsocketsEventType.conversationAudioCompleted,
      'error': WebsocketsEventType.error,
    };

    return eventMap[event] ?? WebsocketsEventType.error;
  }

  /// 发送文本更新事件
  void sendTextUpdate(String text) {
    _send({
      'event': 'speech.update',
      'data': {'text': text},
    });
  }

  /// 发送文本追加事件
  void appendTextBuffer(String text) {
    _send({
      'event': 'input_text_buffer.append',
      'data': {'text': text},
    });
  }

  /// 发送文本完成事件
  void completeTextBuffer() {
    _send({
      'event': 'input_text_buffer.complete',
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

/// 语音合成事件
class SpeechEvent {
  /// 事件类型
  final WebsocketsEventType eventType;

  /// 事件数据
  final Map<String, dynamic> data;

  SpeechEvent({
    required this.eventType,
    required this.data,
  });
}
