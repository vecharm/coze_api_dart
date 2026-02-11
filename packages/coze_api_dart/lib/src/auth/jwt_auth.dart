/// JWT 认证
///
/// 支持 JSON Web Token 认证方式
///
/// 使用示例：
/// ```dart
/// final jwtAuth = JWTAuth(
///   appId: 'your_app_id',
///   privateKey: 'your_private_key',
/// );
///
/// final api = CozeAPI.withAuth(
///   auth: jwtAuth,
///   baseURL: CozeURLs.comBaseURL,
/// );
/// ```
library;

import 'dart:convert';

import 'auth_base.dart';

/// JWT 认证
///
/// 使用 JWT 令牌进行认证
class JWTAuth extends AuthBase {
  final String _token;

  /// 创建 JWT 认证实例
  ///
  /// [token] JWT 令牌字符串
  JWTAuth(String token) : _token = token;

  /// 使用 App ID 和私钥创建 JWT 认证
  ///
  /// [appId] 应用 ID
  /// [privateKey] 私钥（PEM 格式）
  factory JWTAuth.fromPrivateKey({
    required String appId,
    required String privateKey,
  }) {
    // 生成 JWT 令牌
    final token = _generateJWT(
      appId: appId,
      privateKey: privateKey,
    );
    return JWTAuth(token);
  }

  @override
  Future<Map<String, String>> getHeaders() async {
    return {
      'Authorization': 'Bearer $_token',
    };
  }

  @override
  Future<void> refresh() async {
    // JWT 通常不支持刷新，需要重新生成
    throw UnsupportedError(
        'JWT tokens cannot be refreshed. Please create a new JWTAuth instance.');
  }

  @override
  bool get isValid => true; // JWT 验证需要解析令牌

  @override
  bool get needsRefresh => false; // JWT 通常不需要刷新

  /// 生成 JWT 令牌
  static String _generateJWT({
    required String appId,
    required String privateKey,
  }) {
    // 构建 Header
    final header = {
      'alg': 'RS256',
      'typ': 'JWT',
    };

    // 构建 Payload
    final now = DateTime.now();
    final payload = {
      'iss': appId,
      'iat': now.millisecondsSinceEpoch ~/ 1000,
      'exp': now.add(const Duration(hours: 1)).millisecondsSinceEpoch ~/ 1000,
    };

    // Base64Url 编码
    final encodedHeader = _base64UrlEncode(jsonEncode(header));
    final encodedPayload = _base64UrlEncode(jsonEncode(payload));

    // 创建签名
    final signingInput = '$encodedHeader.$encodedPayload';
    final signature = _sign(signingInput, privateKey);

    return '$signingInput.$signature';
  }

  /// Base64Url 编码
  static String _base64UrlEncode(String input) {
    final bytes = utf8.encode(input);
    return base64Url.encode(bytes).replaceAll('=', '');
  }

  /// 签名（使用 RSA-SHA256）
  static String _sign(String input, String privateKey) {
    // 注意：完整的 RSA-SHA256 签名需要 pointycastle 包
    // 这里提供一个简化实现框架
    // 实际使用时请添加 pointycastle: ^3.7.3 依赖
    throw UnimplementedError(
      'JWT RSA-SHA256 signing requires pointycastle package. '
      'Please add pointycastle: ^3.7.3 to your dependencies and implement the signing logic.',
    );
  }
}
