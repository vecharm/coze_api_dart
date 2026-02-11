
/// 认证模块基类
///
/// 定义所有认证方式的通用接口
library;

import '../models/errors.dart';

/// 认证基类
///
/// 所有认证方式都需要实现此类，用于提供统一的认证接口
abstract class AuthBase {
  /// 获取认证头信息
  ///
  /// 返回包含认证信息的 HTTP 头映射
  /// 如果令牌需要刷新，此方法会自动处理
  ///
  /// 抛出 [AuthException] 当认证失败时
  Future<Map<String, String>> getHeaders();

  /// 刷新认证令牌
  ///
  /// 当令牌过期或即将过期时调用此方法刷新
  /// 不是所有认证方式都支持刷新
  ///
  /// 抛出 [AuthException] 当刷新失败时
  Future<void> refresh();

  /// 检查认证是否有效
  ///
  /// 返回 true 如果当前认证信息有效
  bool get isValid;

  /// 检查认证是否需要刷新
  ///
  /// 返回 true 如果认证即将过期需要刷新
  bool get needsRefresh;
}

/// 令牌信息
///
/// 封装访问令牌和刷新令牌
class TokenInfo {
  /// 访问令牌
  final String accessToken;

  /// 刷新令牌
  final String? refreshToken;

  /// 令牌类型（如 Bearer）
  final String tokenType;

  /// 过期时间
  final DateTime? expiresAt;

  /// 创建令牌信息
  const TokenInfo({
    required this.accessToken,
    this.refreshToken,
    this.tokenType = 'Bearer',
    this.expiresAt,
  });

  /// 从 JSON 创建令牌信息
  factory TokenInfo.fromJson(Map<String, dynamic> json) {
    return TokenInfo(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String?,
      tokenType: json['token_type'] as String? ?? 'Bearer',
      expiresAt: json['expires_in'] != null
          ? DateTime.now().add(
              Duration(seconds: (json['expires_in'] as num).toInt()),
            )
          : null,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      if (refreshToken != null) 'refresh_token': refreshToken,
      'token_type': tokenType,
      if (expiresAt != null)
        'expires_in': expiresAt!.difference(DateTime.now()).inSeconds,
    };
  }

  /// 检查令牌是否已过期
  bool get isExpired {
    if (expiresAt == null) return false;
    // 提前 60 秒认为过期，避免边界情况
    return DateTime.now().isAfter(expiresAt!.subtract(const Duration(seconds: 60)));
  }

  /// 检查是否可以刷新
  bool get canRefresh => refreshToken != null;

  /// 获取授权头值
  String get authorizationHeader => '$tokenType $accessToken';
}

/// 异步令牌提供者
///
/// 用于动态获取令牌，支持令牌刷新场景
typedef TokenProvider = Future<String> Function();

/// 带缓存的认证基类
///
/// 提供令牌缓存和自动刷新功能
abstract class CachedAuthBase extends AuthBase {
  TokenInfo? _cachedToken;

  /// 获取缓存的令牌
  TokenInfo? get cachedToken => _cachedToken;

  /// 设置缓存的令牌
  set cachedToken(TokenInfo? value) => _cachedToken = value;

  /// 获取新的令牌
  ///
  /// 子类需要实现此方法获取新的令牌
  Future<TokenInfo> fetchToken();

  /// 使用刷新令牌获取新令牌
  ///
  /// 子类需要实现此方法，如果不支持刷新则抛出异常
  Future<TokenInfo> refreshToken();

  @override
  Future<Map<String, String>> getHeaders() async {
    // 检查是否需要刷新
    if (_cachedToken == null || needsRefresh) {
      if (_cachedToken?.canRefresh == true) {
        _cachedToken = await refreshToken();
      } else {
        _cachedToken = await fetchToken();
      }
    }

    if (_cachedToken == null) {
      throw const AuthException(
        message: '无法获取有效的认证令牌',
      );
    }

    return {
      'Authorization': _cachedToken!.authorizationHeader,
    };
  }

  @override
  Future<void> refresh() async {
    if (_cachedToken?.canRefresh == true) {
      _cachedToken = await refreshToken();
    } else {
      _cachedToken = await fetchToken();
    }
  }

  @override
  bool get isValid => _cachedToken != null && !_cachedToken!.isExpired;

  @override
  bool get needsRefresh => _cachedToken == null || _cachedToken!.isExpired;
}
