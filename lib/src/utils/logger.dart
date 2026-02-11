
/// Coze API 日志工具
///
/// 提供统一的日志记录功能，支持不同日志级别
library;

/// 日志级别
enum LogLevel {
  /// 详细（最详细）
  verbose,
  
  /// 调试
  debug,
  
  /// 信息
  info,
  
  /// 警告
  warning,
  
  /// 错误
  error,
  
  /// 无（不记录）
  none,
}

/// 日志记录器
///
/// 用于记录 SDK 运行过程中的各类信息
class Logger {
  static Logger? _instance;
  
  /// 当前日志级别
  LogLevel _level = LogLevel.none;
  
  /// 自定义日志处理器
  void Function(String message, LogLevel level)? _customHandler;
  
  /// 是否包含时间戳
  bool _includeTimestamp = true;
  
  /// 私有构造函数
  Logger._();
  
  /// 获取单例实例
  static Logger get instance => _instance ??= Logger._();
  
  /// 初始化日志记录器
  ///
  /// [level] 日志级别，低于此级别的日志不会输出
  /// [customHandler] 自定义日志处理器，可用于将日志发送到外部服务
  /// [includeTimestamp] 是否在日志中包含时间戳
  static void initialize({
    LogLevel level = LogLevel.none,
    void Function(String message, LogLevel level)? customHandler,
    bool includeTimestamp = true,
  }) {
    instance
      .._level = level
      .._customHandler = customHandler
      .._includeTimestamp = includeTimestamp;
  }
  
  /// 设置日志级别
  set level(LogLevel value) => _level = value;
  
  /// 获取当前日志级别
  LogLevel get level => _level;
  
  /// 记录详细日志
  void v(String message) => _log(message, LogLevel.verbose);
  
  /// 记录调试日志
  void d(String message) => _log(message, LogLevel.debug);
  
  /// 记录信息日志
  void i(String message) => _log(message, LogLevel.info);
  
  /// 记录警告日志
  void w(String message) => _log(message, LogLevel.warning);
  
  /// 记录错误日志
  void e(String message, [dynamic error, StackTrace? stackTrace]) {
    final buffer = StringBuffer(message);
    if (error != null) {
      buffer.write('\nError: $error');
    }
    if (stackTrace != null) {
      buffer.write('\nStackTrace:\n$stackTrace');
    }
    _log(buffer.toString(), LogLevel.error);
  }
  
  /// 内部日志记录方法
  void _log(String message, LogLevel level) {
    // 检查日志级别
    if (level.index < _level.index || _level == LogLevel.none) {
      return;
    }
    
    final buffer = StringBuffer();
    
    // 添加时间戳
    if (_includeTimestamp) {
      buffer.write('[${DateTime.now().toIso8601String()}] ');
    }
    
    // 添加日志级别
    buffer.write('[${_levelToString(level)}] ');
    
    // 添加消息
    buffer.write(message);
    
    final logMessage = buffer.toString();
    
    // 使用自定义处理器或默认输出
    if (_customHandler != null) {
      _customHandler!(logMessage, level);
    } else {
      _defaultOutput(logMessage, level);
    }
  }
  
  /// 默认日志输出
  void _defaultOutput(String message, LogLevel level) {
    // ignore: avoid_print
    print(message);
  }
  
  /// 将日志级别转换为字符串
  String _levelToString(LogLevel level) {
    return switch (level) {
      LogLevel.verbose => 'V',
      LogLevel.debug => 'D',
      LogLevel.info => 'I',
      LogLevel.warning => 'W',
      LogLevel.error => 'E',
      LogLevel.none => 'N',
    };
  }
}

/// 便捷的日志函数
void logV(String message) => Logger.instance.v(message);
void logD(String message) => Logger.instance.d(message);
void logI(String message) => Logger.instance.i(message);
void logW(String message) => Logger.instance.w(message);
void logE(String message, [dynamic error, StackTrace? stackTrace]) => 
    Logger.instance.e(message, error, stackTrace);
