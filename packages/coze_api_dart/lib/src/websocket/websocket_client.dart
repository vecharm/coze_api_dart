/// WebSocket 客户端
///
/// 提供与 Coze WebSocket API 的实时通信功能
/// 支持实时对话、语音聊天等功能
///
/// 使用示例：
/// ```dart
/// final wsClient = WebSocketClient(
///   botId: 'your_bot_id',
///   token: 'your_token',
///   baseURL: CozeURLs.comWsURL,
/// );
///
/// await wsClient.connect();
///
/// wsClient.onMessage = (event) {
///   print('Received: ${event.data}');
/// };
///
/// wsClient.send({
///   'event_type': 'conversation.message.create',
///   'data': {'content': 'Hello'},
/// });
/// ```
library;

import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../models/enums.dart';
import '../models/errors.dart';
import '../utils/logger.dart';
import 'websocket_events.dart';

/// WebSocket 连接状态
enum WebSocketConnectionState {
  /// 未连接
  disconnected,

  /// 正在连接
  connecting,

  /// 已连接
  connected,

  /// 正在断开连接
  disconnecting,

  /// 连接失败
  failed,

  /// 已关闭
  closed,
}

/// WebSocket 客户端配置
class WebSocketConfig {
  /// Bot ID
  final String botId;

  /// 认证令牌
  final String token;

  /// WebSocket URL
  final String baseURL;

  /// 连接超时时间
  final Duration connectionTimeout;

  /// 是否自动重连
  final bool autoReconnect;

  /// 重连间隔
  final Duration reconnectInterval;

  /// 最大重连次数
  final int maxReconnectAttempts;

  /// 是否允许在浏览器中使用 PAT
  final bool allowPersonalAccessTokenInBrowser;

  /// 是否启用调试日志
  final bool debug;

  const WebSocketConfig({
    required this.botId,
    required this.token,
    required this.baseURL,
    this.connectionTimeout = const Duration(seconds: 10),
    this.autoReconnect = true,
    this.reconnectInterval = const Duration(seconds: 3),
    this.maxReconnectAttempts = 3,
    this.allowPersonalAccessTokenInBrowser = false,
    this.debug = false,
  });
}

/// WebSocket 客户端
class WebSocketClient {
  final WebSocketConfig _config;
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;

  /// 当前连接状态
  WebSocketConnectionState _state = WebSocketConnectionState.disconnected;

  /// 重连计数
  int _reconnectAttempts = 0;

  /// 是否主动断开
  bool _isIntentionalDisconnect = false;

  /// 消息控制器
  final _messageController = StreamController<WebsocketEvent>.broadcast();

  /// 连接状态控制器
  final _stateController =
      StreamController<WebSocketConnectionState>.broadcast();

  /// 错误控制器
  final _errorController = StreamController<CozeException>.broadcast();

  /// 获取当前连接状态
  WebSocketConnectionState get state => _state;

  /// 是否已连接
  bool get isConnected => _state == WebSocketConnectionState.connected;

  /// 消息流
  Stream<WebsocketEvent> get messageStream => _messageController.stream;

  /// 连接状态流
  Stream<WebSocketConnectionState> get stateStream => _stateController.stream;

  /// 错误流
  Stream<CozeException> get errorStream => _errorController.stream;

  /// 消息回调（可选）
  void Function(WebsocketEvent event)? onMessage;

  /// 连接成功回调（可选）
  void Function()? onConnect;

  /// 断开连接回调（可选）
  void Function()? onDisconnect;

  /// 错误回调（可选）
  void Function(CozeException error)? onError;

  /// 创建 WebSocket 客户端
  WebSocketClient({
    required String botId,
    required String token,
    required String baseURL,
    Duration connectionTimeout = const Duration(seconds: 10),
    bool autoReconnect = true,
    Duration reconnectInterval = const Duration(seconds: 3),
    int maxReconnectAttempts = 3,
    bool allowPersonalAccessTokenInBrowser = false,
    bool debug = false,
  }) : _config = WebSocketConfig(
          botId: botId,
          token: token,
          baseURL: baseURL,
          connectionTimeout: connectionTimeout,
          autoReconnect: autoReconnect,
          reconnectInterval: reconnectInterval,
          maxReconnectAttempts: maxReconnectAttempts,
          allowPersonalAccessTokenInBrowser: allowPersonalAccessTokenInBrowser,
          debug: debug,
        );

  /// 使用配置创建 WebSocket 客户端
  WebSocketClient.withConfig(this._config);

  /// 连接到 WebSocket 服务器
  Future<void> connect() async {
    if (_state == WebSocketConnectionState.connected ||
        _state == WebSocketConnectionState.connecting) {
      return;
    }

    _updateState(WebSocketConnectionState.connecting);
    _isIntentionalDisconnect = false;

    try {
      // 构建 WebSocket URL
      final wsUrl = _buildWebSocketUrl();

      if (_config.debug) {
        logD('Connecting to WebSocket: $wsUrl');
      }

      // 建立连接
      _channel = WebSocketChannel.connect(
        Uri.parse(wsUrl),
      );

      // 等待连接建立
      await _channel!.ready.timeout(
        _config.connectionTimeout,
        onTimeout: () {
          throw TimeoutException(
            message: 'WebSocket connection timeout',
            timeoutMs: _config.connectionTimeout.inMilliseconds,
          );
        },
      );

      // 订阅消息
      _subscription = _channel!.stream.listen(
        _onData,
        onError: _onError,
        onDone: _onDone,
      );

      _updateState(WebSocketConnectionState.connected);
      _reconnectAttempts = 0;

      onConnect?.call();

      if (_config.debug) {
        logD('WebSocket connected');
      }
    } catch (e) {
      _updateState(WebSocketConnectionState.failed);

      final error = e is CozeException
          ? e
          : WebSocketException(
              message: 'Failed to connect: $e',
              originalError: e,
            );

      _errorController.add(error);
      onError?.call(error);

      // 尝试重连
      if (_config.autoReconnect && !_isIntentionalDisconnect) {
        _scheduleReconnect();
      }

      rethrow;
    }
  }

  /// 断开连接
  Future<void> disconnect() async {
    if (_state == WebSocketConnectionState.disconnected ||
        _state == WebSocketConnectionState.closed) {
      return;
    }

    _isIntentionalDisconnect = true;
    _updateState(WebSocketConnectionState.disconnecting);

    await _subscription?.cancel();
    await _channel?.sink.close();

    _subscription = null;
    _channel = null;

    _updateState(WebSocketConnectionState.disconnected);
    onDisconnect?.call();

    if (_config.debug) {
      logD('WebSocket disconnected');
    }
  }

  /// 发送消息
  void send(Map<String, dynamic> data) {
    if (!isConnected) {
      throw WebSocketException(
        message: 'WebSocket is not connected',
      );
    }

    final json = jsonEncode(data);

    if (_config.debug) {
      logD('Sending: $json');
    }

    _channel!.sink.add(json);
  }

  /// 发送聊天更新事件
  void sendChatUpdate({
    required bool autoSaveHistory,
    String? userId,
    Map<String, dynamic>? metaData,
    Map<String, dynamic>? customVariables,
    Map<String, dynamic>? extraParams,
  }) {
    send({
      'id': _generateEventId(),
      'event_type': WebsocketsEventType.chatUpdate.name,
      'data': {
        'chat_config': {
          'auto_save_history': autoSaveHistory,
          if (userId != null) 'user_id': userId,
          if (metaData != null) 'meta_data': metaData,
          if (customVariables != null) 'custom_variables': customVariables,
          if (extraParams != null) 'extra_params': extraParams,
        },
      },
    });
  }

  /// 发送消息创建事件
  void sendMessageCreate({
    required RoleType role,
    required String content,
    ContentType contentType = ContentType.text,
  }) {
    send({
      'id': _generateEventId(),
      'event_type': WebsocketsEventType.conversationMessageCreate.name,
      'data': {
        'role': role.name,
        'content': content,
        'content_type': contentType.name,
      },
    });
  }

  /// 关闭客户端并释放资源
  void close() {
    disconnect();
    _messageController.close();
    _stateController.close();
    _errorController.close();
  }

  /// 构建 WebSocket URL
  String _buildWebSocketUrl() {
    final buffer = StringBuffer(_config.baseURL);

    // 添加路径
    if (!buffer.toString().endsWith('/')) {
      buffer.write('/');
    }
    buffer.write('v3/chat');

    // 添加查询参数
    buffer.write('?bot_id=${Uri.encodeComponent(_config.botId)}');

    // 添加认证
    buffer.write('&token=${Uri.encodeComponent(_config.token)}');

    return buffer.toString();
  }

  /// 处理接收到的数据
  void _onData(dynamic data) {
    if (_config.debug) {
      logD('Received: $data');
    }

    try {
      final json = jsonDecode(data as String) as Map<String, dynamic>;
      final event = WebsocketEvent.fromJson(json);

      // 检查是否是错误事件
      if (event.eventType == WebsocketsEventType.error) {
        final errorData = event.data;
        final code = errorData['code'] as int?;

        if (code == 4100) {
          final error = UnauthorizedException(
            message: errorData['msg'] as String? ?? 'Unauthorized',
          );
          _errorController.add(error);
          onError?.call(error);
          return;
        } else if (code == 4101) {
          final error = ForbiddenException(
            message: errorData['msg'] as String? ?? 'Forbidden',
          );
          _errorController.add(error);
          onError?.call(error);
          return;
        }
      }

      _messageController.add(event);
      onMessage?.call(event);
    } catch (e) {
      logW('Failed to parse WebSocket message: $data');
    }
  }

  /// 处理错误
  void _onError(Object error) {
    if (_config.debug) {
      logD('WebSocket error: $error');
    }

    final wsError = error is CozeException
        ? error
        : WebSocketException(
            message: 'WebSocket error: $error',
            originalError: error,
          );

    _errorController.add(wsError);
    onError?.call(wsError);
  }

  /// 连接关闭
  void _onDone() {
    if (_config.debug) {
      logD('WebSocket connection closed');
    }

    _subscription = null;
    _channel = null;

    if (_state != WebSocketConnectionState.disconnected) {
      _updateState(WebSocketConnectionState.disconnected);
      onDisconnect?.call();

      // 尝试重连
      if (_config.autoReconnect && !_isIntentionalDisconnect) {
        _scheduleReconnect();
      }
    }
  }

  /// 更新连接状态
  void _updateState(WebSocketConnectionState newState) {
    _state = newState;
    _stateController.add(newState);
  }

  /// 安排重连
  void _scheduleReconnect() {
    if (_reconnectAttempts >= _config.maxReconnectAttempts) {
      logW('Max reconnection attempts reached');
      return;
    }

    _reconnectAttempts++;

    if (_config.debug) {
      logD(
          'Scheduling reconnect attempt $_reconnectAttempts/${_config.maxReconnectAttempts}');
    }

    Future.delayed(_config.reconnectInterval, () {
      if (!_isIntentionalDisconnect &&
          _state != WebSocketConnectionState.connected) {
        connect();
      }
    });
  }

  /// 生成事件 ID
  String _generateEventId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${(_reconnectAttempts)}';
  }
}
