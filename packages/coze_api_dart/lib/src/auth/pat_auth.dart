
/// Personal Access Token (PAT) 认证
///
/// 最简单的认证方式，使用固定的个人访问令牌
library;

import 'auth_base.dart';

/// PAT 认证
///
/// 使用固定的个人访问令牌进行认证，适用于服务器端应用或简单的客户端应用
///
/// 使用示例：
/// ```dart
/// final auth = PATAuth('your_pat_token');
/// final headers = await auth.getHeaders();
/// ```
class PATAuth implements AuthBase {
  /// 个人访问令牌
  final String token;

  /// 创建 PAT 认证实例
  ///
  /// [token] 从 Coze 平台获取的个人访问令牌
  const PATAuth(this.token);

  @override
  Future<Map<String, String>> getHeaders() async {
    return {
      'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<void> refresh() async {
    // PAT 不支持刷新，无需操作
  }

  @override
  bool get isValid => token.isNotEmpty;

  @override
  bool get needsRefresh => false;
}

/// 异步 PAT 认证
///
/// 支持动态获取 PAT 令牌，适用于需要动态获取令牌的场景
///
/// 使用示例：
/// ```dart
/// final auth = AsyncPATAuth(() async {
///   // 从安全存储或服务器获取令牌
///   return await secureStorage.read(key: 'pat_token');
/// });
/// ```
class AsyncPATAuth implements AuthBase {
  /// 令牌提供者
  final TokenProvider tokenProvider;

  /// 缓存的令牌
  String? _cachedToken;

  /// 创建异步 PAT 认证实例
  ///
  /// [tokenProvider] 异步获取令牌的回调函数
  AsyncPATAuth(this.tokenProvider);

  @override
  Future<Map<String, String>> getHeaders() async {
    _cachedToken ??= await tokenProvider();
    
    if (_cachedToken == null || _cachedToken!.isEmpty) {
      throw Exception('无法获取有效的 PAT 令牌');
    }
    
    return {
      'Authorization': 'Bearer $_cachedToken',
    };
  }

  @override
  Future<void> refresh() async {
    _cachedToken = await tokenProvider();
  }

  @override
  bool get isValid => _cachedToken != null && _cachedToken!.isNotEmpty;

  @override
  bool get needsRefresh => false;
  
  /// 清除缓存的令牌，下次调用 getHeaders 时会重新获取
  void clearCache() {
    _cachedToken = null;
  }
}
