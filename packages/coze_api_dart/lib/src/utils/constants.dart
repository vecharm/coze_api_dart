
/// Coze API 常量定义
/// 
/// 包含基础 URL、API 版本、超时配置等常量
library;

/// Coze 平台基础 URL
class CozeURLs {
  /// 国际版基础 URL
  static const String comBaseURL = 'https://api.coze.com';
  
  /// 中国版基础 URL
  static const String cnBaseURL = 'https://api.coze.cn';
  
  /// WebSocket 国际版 URL
  static const String comWsURL = 'wss://ws.coze.com';
  
  /// WebSocket 中国版 URL
  static const String cnWsURL = 'wss://ws.coze.cn';
}

/// API 版本
class APIVersions {
  /// V3 API 版本路径
  static const String v3 = '/v3';
}

/// 默认配置
class DefaultConfig {
  /// 默认请求超时时间（毫秒）
  static const int timeout = 30000;
  
  /// 默认流式请求超时时间（毫秒）
  static const int streamTimeout = 60000;
  
  /// 默认 WebSocket 连接超时时间（毫秒）
  static const int wsTimeout = 10000;
  
  /// 默认最大重试次数
  static const int maxRetries = 3;
  
  /// 默认重试延迟（毫秒）
  static const int retryDelay = 1000;
}

/// HTTP 头常量
class Headers {
  /// 授权头
  static const String authorization = 'Authorization';
  
  /// 内容类型
  static const String contentType = 'Content-Type';
  
  /// 接受类型
  static const String accept = 'Accept';
  
  /// 用户代理
  static const String userAgent = 'User-Agent';
  
  /// 请求 ID
  static const String requestId = 'X-Request-Id';
  
  /// 内容类型: JSON
  static const String contentTypeJson = 'application/json';
  
  /// 内容类型: 流
  static const String contentTypeStream = 'text/event-stream';
  
  /// 接受类型: JSON
  static const String acceptJson = 'application/json';
  
  /// 接受类型: 流
  static const String acceptStream = 'text/event-stream';
}

/// 错误码
class ErrorCodes {
  /// 未授权
  static const int unauthorized = 4100;
  
  /// 禁止访问
  static const int forbidden = 4101;
  
  /// 资源不存在
  static const int notFound = 4200;
  
  /// 请求参数错误
  static const int badRequest = 4300;
  
  /// 服务器内部错误
  static const int serverError = 5000;
  
  /// 服务不可用
  static const int serviceUnavailable = 5001;
  
  /// 请求频率限制
  static const int rateLimit = 4301;
  
  /// 配额不足
  static const int quotaExceeded = 4302;
}
