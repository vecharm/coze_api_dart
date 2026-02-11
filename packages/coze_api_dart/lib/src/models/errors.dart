
/// Coze API 错误定义
///
/// 包含所有自定义异常类和错误处理工具
library;

import '../utils/constants.dart';

/// Coze API 基础异常类
///
/// 所有 Coze API 相关的异常都继承自此类
class CozeException implements Exception {
  /// 错误码
  final int? code;

  /// 错误信息
  final String message;

  /// 原始错误
  final dynamic originalError;

  /// 请求 ID（用于追踪）
  final String? requestId;

  /// 创建 Coze 异常
  const CozeException({
    this.code,
    required this.message,
    this.originalError,
    this.requestId,
  });

  @override
  String toString() {
    final buffer = StringBuffer('CozeException');
    if (code != null) buffer.write(' [$code]');
    buffer.write(': $message');
    if (requestId != null) buffer.write(' (requestId: $requestId)');
    return buffer.toString();
  }
}

/// 认证异常
///
/// 当认证失败时抛出，如令牌无效、过期等
class AuthException extends CozeException {
  /// 认证类型
  final String? authType;

  const AuthException({
    super.code,
    required super.message,
    super.originalError,
    super.requestId,
    this.authType,
  });

  @override
  String toString() {
    final buffer = StringBuffer('AuthException');
    if (authType != null) buffer.write(' [$authType]');
    if (code != null) buffer.write(' [$code]');
    buffer.write(': $message');
    return buffer.toString();
  }
}

/// 未授权异常
///
/// 当请求未提供有效的认证信息时抛出
class UnauthorizedException extends AuthException {
  const UnauthorizedException({
    super.message = '未授权，请检查认证信息',
    super.requestId,
  }) : super(code: ErrorCodes.unauthorized);
}

/// 禁止访问异常
///
/// 当用户没有权限访问资源时抛出
class ForbiddenException extends AuthException {
  const ForbiddenException({
    super.message = '禁止访问，权限不足',
    super.requestId,
  }) : super(code: ErrorCodes.forbidden);
}

/// 资源不存在异常
///
/// 当请求的资源不存在时抛出
class NotFoundException extends CozeException {
  /// 资源类型
  final String? resourceType;

  /// 资源 ID
  final String? resourceId;

  const NotFoundException({
    super.message = '请求的资源不存在',
    super.requestId,
    this.resourceType,
    this.resourceId,
  }) : super(code: ErrorCodes.notFound);

  @override
  String toString() {
    final buffer = StringBuffer('NotFoundException');
    if (resourceType != null) buffer.write(' [$resourceType]');
    if (resourceId != null) buffer.write(' [id: $resourceId]');
    buffer.write(': $message');
    return buffer.toString();
  }
}

/// 请求参数错误异常
///
/// 当请求参数无效时抛出
class BadRequestException extends CozeException {
  /// 参数错误详情
  final Map<String, dynamic>? details;

  const BadRequestException({
    super.message = '请求参数错误',
    super.requestId,
    this.details,
  }) : super(code: ErrorCodes.badRequest);

  @override
  String toString() {
    final buffer = StringBuffer('BadRequestException: $message');
    if (details != null) buffer.write('\nDetails: $details');
    return buffer.toString();
  }
}

/// 服务器错误异常
///
/// 当服务器内部错误时抛出
class ServerException extends CozeException {
  const ServerException({
    super.message = '服务器内部错误',
    super.requestId,
  }) : super(code: ErrorCodes.serverError);
}

/// 服务不可用异常
///
/// 当服务暂时不可用时抛出
class ServiceUnavailableException extends CozeException {
  /// 重试时间（秒）
  final int? retryAfter;

  const ServiceUnavailableException({
    super.message = '服务暂时不可用',
    super.requestId,
    this.retryAfter,
  }) : super(code: ErrorCodes.serviceUnavailable);
}

/// 请求频率限制异常
///
/// 当请求过于频繁时抛出
class RateLimitException extends CozeException {
  /// 重试时间（秒）
  final int? retryAfter;

  const RateLimitException({
    super.message = '请求过于频繁，请稍后重试',
    super.requestId,
    this.retryAfter,
  }) : super(code: ErrorCodes.rateLimit);

  @override
  String toString() {
    final buffer = StringBuffer('RateLimitException: $message');
    if (retryAfter != null) {
      buffer.write(' (请等待 $retryAfter 秒后重试)');
    }
    return buffer.toString();
  }
}

/// 配额不足异常
///
/// 当账户配额不足时抛出
class QuotaExceededException extends CozeException {
  const QuotaExceededException({
    super.message = '账户配额不足',
    super.requestId,
  }) : super(code: ErrorCodes.quotaExceeded);
}

/// 网络异常
///
/// 当网络连接失败时抛出
class NetworkException extends CozeException {
  /// 是否可重试
  final bool isRetryable;

  const NetworkException({
    super.message = '网络连接失败',
    super.originalError,
    this.isRetryable = true,
  });
}

/// 超时异常
///
/// 当请求超时时抛出
class TimeoutException extends CozeException {
  /// 超时时间（毫秒）
  final int? timeoutMs;

  const TimeoutException({
    super.message = '请求超时',
    this.timeoutMs,
  });

  @override
  String toString() {
    final buffer = StringBuffer('TimeoutException: $message');
    if (timeoutMs != null) buffer.write(' (${timeoutMs}ms)');
    return buffer.toString();
  }
}

/// 流式响应异常
///
/// 当流式响应过程中发生错误时抛出
class StreamException extends CozeException {
  /// 已接收的数据
  final String? receivedData;

  const StreamException({
    required super.message,
    super.originalError,
    this.receivedData,
  });
}

/// WebSocket 异常
///
/// 当 WebSocket 连接或通信发生错误时抛出
class WebSocketException extends CozeException {
  /// WebSocket 关闭码
  final int? closeCode;

  /// WebSocket 关闭原因
  final String? closeReason;

  const WebSocketException({
    required super.message,
    this.closeCode,
    this.closeReason,
    super.originalError,
  });

  @override
  String toString() {
    final buffer = StringBuffer('WebSocketException: $message');
    if (closeCode != null) buffer.write(' [code: $closeCode]');
    if (closeReason != null) buffer.write(' [reason: $closeReason]');
    return buffer.toString();
  }
}

/// 序列化异常
///
/// 当 JSON 序列化/反序列化失败时抛出
class SerializationException extends CozeException {
  /// 目标类型
  final Type? targetType;

  /// 原始数据
  final dynamic data;

  const SerializationException({
    required super.message,
    this.targetType,
    this.data,
    super.originalError,
  });

  @override
  String toString() {
    final buffer = StringBuffer('SerializationException: $message');
    if (targetType != null) buffer.write(' [target: $targetType]');
    return buffer.toString();
  }
}

/// 取消异常
///
/// 当操作被取消时抛出
class CancelledException extends CozeException {
  const CancelledException({
    super.message = '操作已取消',
  });
}

/// 错误工厂类
///
/// 用于根据 HTTP 状态码和响应体创建对应的异常
class ErrorFactory {
  /// 根据 HTTP 响应创建异常
  static CozeException create({
    required int statusCode,
    required Map<String, dynamic> responseBody,
    String? requestId,
  }) {
    final code = responseBody['code'] as int?;
    final message = responseBody['msg'] as String? ??
        responseBody['message'] as String? ??
        _getDefaultMessage(statusCode);

    // 首先根据业务错误码判断
    switch (code) {
      case ErrorCodes.unauthorized:
        return UnauthorizedException(
          message: message,
          requestId: requestId,
        );
      case ErrorCodes.forbidden:
        return ForbiddenException(
          message: message,
          requestId: requestId,
        );
      case ErrorCodes.notFound:
        return NotFoundException(
          message: message,
          requestId: requestId,
        );
      case ErrorCodes.badRequest:
        return BadRequestException(
          message: message,
          requestId: requestId,
          details: responseBody['detail'] as Map<String, dynamic>?,
        );
      case ErrorCodes.rateLimit:
        return RateLimitException(
          message: message,
          requestId: requestId,
          retryAfter: responseBody['retry_after'] as int?,
        );
      case ErrorCodes.quotaExceeded:
        return QuotaExceededException(
          message: message,
          requestId: requestId,
        );
      case ErrorCodes.serverError:
        return ServerException(
          message: message,
          requestId: requestId,
        );
      case ErrorCodes.serviceUnavailable:
        return ServiceUnavailableException(
          message: message,
          requestId: requestId,
          retryAfter: responseBody['retry_after'] as int?,
        );
    }

    // 根据 HTTP 状态码判断
    switch (statusCode) {
      case 400:
        return BadRequestException(
          message: message,
          requestId: requestId,
          details: responseBody['detail'] as Map<String, dynamic>?,
        );
      case 401:
        return UnauthorizedException(
          message: message,
          requestId: requestId,
        );
      case 403:
        return ForbiddenException(
          message: message,
          requestId: requestId,
        );
      case 404:
        return NotFoundException(
          message: message,
          requestId: requestId,
        );
      case 429:
        return RateLimitException(
          message: message,
          requestId: requestId,
          retryAfter: _parseRetryAfter(responseBody),
        );
      case 500:
        return ServerException(
          message: message,
          requestId: requestId,
        );
      case 502:
      case 503:
      case 504:
        return ServiceUnavailableException(
          message: message,
          requestId: requestId,
          retryAfter: _parseRetryAfter(responseBody),
        );
      default:
        return CozeException(
          code: code ?? statusCode,
          message: message,
          requestId: requestId,
        );
    }
  }

  /// 获取默认错误消息
  static String _getDefaultMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Bad Request';
      case 401:
        return 'Unauthorized';
      case 403:
        return 'Forbidden';
      case 404:
        return 'Not Found';
      case 405:
        return 'Method Not Allowed';
      case 408:
        return 'Request Timeout';
      case 409:
        return 'Conflict';
      case 410:
        return 'Gone';
      case 422:
        return 'Unprocessable Entity';
      case 429:
        return 'Too Many Requests';
      case 500:
        return 'Internal Server Error';
      case 502:
        return 'Bad Gateway';
      case 503:
        return 'Service Unavailable';
      case 504:
        return 'Gateway Timeout';
      default:
        return 'Unknown Error';
    }
  }

  /// 解析重试时间
  static int? _parseRetryAfter(Map<String, dynamic> responseBody) {
    // 尝试多种可能的字段名
    final retryAfter = responseBody['retry_after'] ??
        responseBody['retryAfter'] ??
        responseBody['Retry-After'];

    if (retryAfter is int) {
      return retryAfter;
    }
    if (retryAfter is String) {
      return int.tryParse(retryAfter);
    }
    return null;
  }
}
