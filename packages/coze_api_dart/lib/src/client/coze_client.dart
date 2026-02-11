/// Coze API 主客户端
///
/// 提供对所有 API 模块的统一访问入口
library;

import '../api/bots/bots_api.dart';
import '../api/chat/chat_api.dart';
import '../api/conversations/conversations_api.dart';
import '../api/datasets/datasets_api.dart';
import '../api/files/files_api.dart';
import '../api/templates/templates_api.dart';
import '../api/users/users_api.dart';
import '../api/variables/variables_api.dart';
import '../api/voice/voice_api.dart';
import '../api/workflows/workflows_api.dart';
import '../auth/auth_base.dart';
import '../auth/pat_auth.dart';
import '../utils/constants.dart';
import '../websocket/websocket_client.dart';
import 'http_client.dart';

/// Coze API 配置
class CozeConfig {
  /// 基础 URL
  final String baseURL;

  /// 请求超时时间
  final Duration timeout;

  /// 流式请求超时时间
  final Duration streamTimeout;

  /// 是否启用调试日志
  final bool debug;

  /// 用户代理
  final String? userAgent;

  /// 创建配置
  const CozeConfig({
    required this.baseURL,
    this.timeout = const Duration(seconds: 30),
    this.streamTimeout = const Duration(seconds: 60),
    this.debug = false,
    this.userAgent,
  });
}

/// Coze API 主客户端
///
/// 使用示例：
/// ```dart
/// final client = CozeAPI(
///   token: 'your_pat_token',
///   baseURL: CozeURLs.comBaseURL,
/// );
///
/// // 发起对话
/// final result = await client.chat.createAndPoll(
///   CreateChatRequest(botId: 'your_bot_id'),
/// );
/// ```
class CozeAPI {
  final AuthBase _auth;
  final CozeConfig _config;
  late final HttpClient _httpClient;

  /// Chat API
  late final ChatAPI chat;

  /// Bot API
  late final BotsAPI bots;

  /// 会话管理 API
  late final ConversationsAPI conversations;

  /// 工作流 API
  late final WorkflowsAPI workflows;

  /// 文件 API
  late final FilesAPI files;

  /// 语音 API
  late final VoiceAPI voice;

  /// 数据集 API
  late final DatasetsAPI datasets;

  /// 变量 API
  late final VariablesAPI variables;

  /// 模板 API
  late final TemplatesAPI templates;

  /// 用户 API
  late final UsersAPI users;

  /// WebSocket URL
  final String? _wsURL;

  /// 创建 Coze API 客户端
  ///
  /// [token] 可以是字符串（PAT）或异步函数（动态获取令牌）
  /// [baseURL] API 基础 URL，使用 [CozeURLs.comBaseURL] 或 [CozeURLs.cnBaseURL]
  /// [wsURL] WebSocket URL（可选），默认根据 baseURL 自动选择
  /// [config] 可选配置
  CozeAPI({
    required dynamic token,
    required String baseURL,
    String? wsURL,
    CozeConfig? config,
  })  : _auth = _createAuth(token),
        _config = config ?? CozeConfig(baseURL: baseURL),
        _wsURL = wsURL ?? _getDefaultWsURL(baseURL) {
    _init();
  }

  /// 使用自定义认证创建客户端
  ///
  /// [auth] 自定义认证实现
  /// [baseURL] API 基础 URL
  /// [wsURL] WebSocket URL（可选），默认根据 baseURL 自动选择
  /// [config] 可选配置
  CozeAPI.withAuth({
    required AuthBase auth,
    required String baseURL,
    String? wsURL,
    CozeConfig? config,
  })  : _auth = auth,
        _config = config ?? CozeConfig(baseURL: baseURL),
        _wsURL = wsURL ?? _getDefaultWsURL(baseURL) {
    _init();
  }

  /// 初始化
  void _init() {
    _httpClient = HttpClient(
      auth: _auth,
      config: HttpClientConfig(
        baseURL: _config.baseURL,
        timeout: _config.timeout,
        streamTimeout: _config.streamTimeout,
        enableLogging: _config.debug,
        defaultHeaders: {
          if (_config.userAgent != null) 'User-Agent': _config.userAgent!,
        },
      ),
    );

    // 初始化 API 模块
    chat = ChatAPI(_httpClient);
    bots = BotsAPI(_httpClient);
    conversations = ConversationsAPI(_httpClient);
    workflows = WorkflowsAPI(_httpClient);
    files = FilesAPI(_httpClient);
    voice = VoiceAPI(_httpClient);
    datasets = DatasetsAPI(_httpClient);
    variables = VariablesAPI(_httpClient);
    templates = TemplatesAPI(_httpClient);
    users = UsersAPI(_httpClient);
  }

  /// 创建认证实例
  static AuthBase _createAuth(dynamic token) {
    if (token is String) {
      return PATAuth(token);
    } else if (token is TokenProvider) {
      return AsyncPATAuth(token);
    }
    throw ArgumentError(
      'token 必须是 String 或 TokenProvider 函数',
    );
  }

  /// 获取 HTTP 客户端
  HttpClient get httpClient => _httpClient;

  /// 获取认证实例
  AuthBase get auth => _auth;

  /// 创建 WebSocket 客户端
  ///
  /// [botId] Bot ID
  /// [voiceId] 语音 ID（可选），用于语音对话
  WebSocketClient createWebSocketClient({
    required String botId,
    String? voiceId,
  }) {
    // 获取认证令牌
    String token;
    if (_auth case final PATAuth patAuth) {
      token = patAuth.token;
    } else {
      throw UnsupportedError(
        'WebSocket currently only supports PAT authentication. '
        'Please use PATAuth or provide a token directly.',
      );
    }

    return WebSocketClient(
      botId: botId,
      token: token,
      baseURL: _wsURL!,
      debug: _config.debug,
    );
  }

  /// 获取默认 WebSocket URL
  static String _getDefaultWsURL(String baseURL) {
    if (baseURL.contains('coze.cn')) {
      return CozeURLs.cnWsURL;
    }
    return CozeURLs.comWsURL;
  }

  /// 关闭客户端
  void close() {
    _httpClient.close();
  }
}
