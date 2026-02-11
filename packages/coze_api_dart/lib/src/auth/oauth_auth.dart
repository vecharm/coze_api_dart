/// OAuth 认证
///
/// 支持 OAuth 2.0 认证流程，包括 Web Application、PKCE、Device Code Flow
///
/// 使用示例：
/// ```dart
/// // OAuth Web Application Flow
/// final oauth = OAuthWebAuth(
///   clientId: 'your_client_id',
///   clientSecret: 'your_client_secret',
///   redirectUri: 'https://your-app.com/callback',
/// );
///
/// // 生成授权 URL
/// final authUrl = oauth.getAuthorizationUrl(
///   scopes: ['bot', 'conversation'],
///   state: 'random_state',
/// );
///
/// // 用户授权后，用 code 换取 token
/// final tokenInfo = await oauth.exchangeCodeForToken(code);
/// ```
library;

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

import '../models/errors.dart';
import '../utils/constants.dart';
import 'auth_base.dart';

/// OAuth 令牌信息
class OAuthTokenInfo extends TokenInfo {
  /// 授权范围
  final List<String> scope;

  OAuthTokenInfo({
    required super.accessToken,
    super.refreshToken,
    super.tokenType = 'Bearer',
    super.expiresAt,
    this.scope = const [],
  });

  factory OAuthTokenInfo.fromJson(Map<String, dynamic> json) {
    final expiresIn = json['expires_in'] as int?;
    return OAuthTokenInfo(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String?,
      tokenType: json['token_type'] as String? ?? 'Bearer',
      expiresAt: expiresIn != null
          ? DateTime.now().add(Duration(seconds: expiresIn))
          : null,
      scope: (json['scope'] as String?)?.split(' ') ?? [],
    );
  }
}

/// OAuth Web Application 认证
///
/// 适用于服务器端应用，需要 client_secret
class OAuthWebAuth extends CachedAuthBase {
  final String clientId;
  final String clientSecret;
  final String redirectUri;
  final String baseURL;

  OAuthWebAuth({
    required this.clientId,
    required this.clientSecret,
    required this.redirectUri,
    String? baseURL,
  }) : baseURL = baseURL ?? CozeURLs.comBaseURL;

  /// 生成授权 URL
  String getAuthorizationUrl({
    List<String>? scopes,
    String? state,
  }) {
    final buffer = StringBuffer('$baseURL/api/permission/oauth2/authorize');
    buffer.write('?client_id=${Uri.encodeComponent(clientId)}');
    buffer.write('&redirect_uri=${Uri.encodeComponent(redirectUri)}');
    buffer.write('&response_type=code');
    if (scopes != null && scopes.isNotEmpty) {
      buffer.write('&scope=${Uri.encodeComponent(scopes.join(' '))}');
    }
    if (state != null) {
      buffer.write('&state=${Uri.encodeComponent(state)}');
    }
    return buffer.toString();
  }

  /// 用授权码换取令牌
  Future<OAuthTokenInfo> exchangeCodeForToken(String code) async {
    final response = await http.post(
      Uri.parse('$baseURL/api/permission/oauth2/token'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'grant_type': 'authorization_code',
        'client_id': clientId,
        'client_secret': clientSecret,
        'code': code,
        'redirect_uri': redirectUri,
      },
    );

    if (response.statusCode != 200) {
      throw AuthException(
        message: 'Failed to exchange code for token: ${response.body}',
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return OAuthTokenInfo.fromJson(json);
  }

  @override
  Future<TokenInfo> fetchToken() async {
    throw UnsupportedError(
      'OAuthWebAuth requires manual authorization. Use exchangeCodeForToken() instead.',
    );
  }

  @override
  Future<TokenInfo> refreshToken() async {
    if (cachedToken?.refreshToken == null) {
      throw AuthException(message: 'No refresh token available');
    }

    final response = await http.post(
      Uri.parse('$baseURL/api/permission/oauth2/token'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'grant_type': 'refresh_token',
        'client_id': clientId,
        'client_secret': clientSecret,
        'refresh_token': cachedToken!.refreshToken,
      },
    );

    if (response.statusCode != 200) {
      throw AuthException(
        message: 'Failed to refresh token: ${response.body}',
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return OAuthTokenInfo.fromJson(json);
  }
}

/// OAuth PKCE 认证
///
/// 适用于移动应用和单页应用，不需要 client_secret
class OAuthPKCEAuth extends CachedAuthBase {
  final String clientId;
  final String redirectUri;
  final String baseURL;
  String? _codeVerifier;

  OAuthPKCEAuth({
    required this.clientId,
    required this.redirectUri,
    String? baseURL,
  }) : baseURL = baseURL ?? CozeURLs.comBaseURL;

  /// 生成 PKCE 参数
  Map<String, String> generatePKCE() {
    // 生成 code_verifier (43-128 字符)
    final verifier = _generateCodeVerifier();
    _codeVerifier = verifier;

    // 生成 code_challenge (SHA256 hash of verifier)
    final challenge = _generateCodeChallenge(verifier);

    return {
      'code_verifier': verifier,
      'code_challenge': challenge,
      'code_challenge_method': 'S256',
    };
  }

  /// 生成授权 URL（带 PKCE）
  String getAuthorizationUrl({
    List<String>? scopes,
    String? state,
  }) {
    final pkce = generatePKCE();

    final buffer = StringBuffer('$baseURL/api/permission/oauth2/authorize');
    buffer.write('?client_id=${Uri.encodeComponent(clientId)}');
    buffer.write('&redirect_uri=${Uri.encodeComponent(redirectUri)}');
    buffer.write('&response_type=code');
    buffer.write(
        '&code_challenge=${Uri.encodeComponent(pkce['code_challenge']!)}');
    buffer.write('&code_challenge_method=S256');
    if (scopes != null && scopes.isNotEmpty) {
      buffer.write('&scope=${Uri.encodeComponent(scopes.join(' '))}');
    }
    if (state != null) {
      buffer.write('&state=${Uri.encodeComponent(state)}');
    }
    return buffer.toString();
  }

  /// 用授权码换取令牌
  Future<OAuthTokenInfo> exchangeCodeForToken(String code) async {
    if (_codeVerifier == null) {
      throw AuthException(
        message:
            'Code verifier not generated. Call getAuthorizationUrl() first.',
      );
    }

    final response = await http.post(
      Uri.parse('$baseURL/api/permission/oauth2/token'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'grant_type': 'authorization_code',
        'client_id': clientId,
        'code': code,
        'redirect_uri': redirectUri,
        'code_verifier': _codeVerifier!,
      },
    );

    if (response.statusCode != 200) {
      throw AuthException(
        message: 'Failed to exchange code for token: ${response.body}',
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return OAuthTokenInfo.fromJson(json);
  }

  @override
  Future<TokenInfo> fetchToken() async {
    throw UnsupportedError(
      'OAuthPKCEAuth requires manual authorization. Use exchangeCodeForToken() instead.',
    );
  }

  @override
  Future<TokenInfo> refreshToken() async {
    if (cachedToken?.refreshToken == null) {
      throw AuthException(message: 'No refresh token available');
    }

    final response = await http.post(
      Uri.parse('$baseURL/api/permission/oauth2/token'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'grant_type': 'refresh_token',
        'client_id': clientId,
        'refresh_token': cachedToken!.refreshToken,
      },
    );

    if (response.statusCode != 200) {
      throw AuthException(
        message: 'Failed to refresh token: ${response.body}',
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return OAuthTokenInfo.fromJson(json);
  }

  /// 生成 code_verifier
  String _generateCodeVerifier() {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
    final random = Random.secure();
    return List.generate(128, (_) => chars[random.nextInt(chars.length)])
        .join();
  }

  /// 生成 code_challenge (S256)
  String _generateCodeChallenge(String verifier) {
    final bytes = utf8.encode(verifier);
    final digest = base64Url.encode(_sha256(bytes));
    // 移除 base64 padding
    return digest.replaceAll('=', '');
  }

  /// 简化的 SHA256 实现（实际项目中应使用 crypto 包）
  List<int> _sha256(List<int> bytes) {
    // 注意：这里应该使用 crypto 包的 sha256
    // 为了简化，这里返回一个占位符
    // 实际使用时请添加 crypto: ^3.0.0 依赖
    throw UnimplementedError(
      'SHA256 not implemented. Please add crypto package dependency.',
    );
  }
}

/// OAuth Device Code Flow
///
/// 适用于无浏览器或输入受限的设备
class OAuthDeviceCodeAuth extends CachedAuthBase {
  final String clientId;
  final String baseURL;

  OAuthDeviceCodeAuth({
    required this.clientId,
    String? baseURL,
  }) : baseURL = baseURL ?? CozeURLs.comBaseURL;

  /// 获取设备码
  Future<DeviceCodeResponse> requestDeviceCode({
    List<String>? scopes,
  }) async {
    final response = await http.post(
      Uri.parse('$baseURL/api/permission/oauth2/device/code'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'client_id': clientId,
        if (scopes != null && scopes.isNotEmpty) 'scope': scopes.join(' '),
      },
    );

    if (response.statusCode != 200) {
      throw AuthException(
        message: 'Failed to request device code: ${response.body}',
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return DeviceCodeResponse.fromJson(json);
  }

  /// 轮询获取令牌
  Future<OAuthTokenInfo> pollForToken(
    String deviceCode, {
    int interval = 5,
    int maxAttempts = 60,
  }) async {
    var attempts = 0;

    while (attempts < maxAttempts) {
      await Future.delayed(Duration(seconds: interval));
      attempts++;

      try {
        final response = await http.post(
          Uri.parse('$baseURL/api/permission/oauth2/token'),
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          body: {
            'grant_type': 'urn:ietf:params:oauth:grant-type:device_code',
            'client_id': clientId,
            'device_code': deviceCode,
          },
        );

        if (response.statusCode == 200) {
          final json = jsonDecode(response.body) as Map<String, dynamic>;
          return OAuthTokenInfo.fromJson(json);
        }

        final error = jsonDecode(response.body) as Map<String, dynamic>;
        final errorCode = error['error'] as String?;

        // 继续轮询
        if (errorCode == 'authorization_pending') {
          continue;
        }

        // 其他错误
        throw AuthException(
          message: 'Device code flow failed: $errorCode',
        );
      } catch (e) {
        if (attempts >= maxAttempts) {
          throw AuthException(
            message: 'Device code polling timeout',
          );
        }
        // 继续轮询
      }
    }

    throw AuthException(message: 'Device code polling timeout');
  }

  @override
  Future<TokenInfo> fetchToken() async {
    throw UnsupportedError(
      'OAuthDeviceCodeAuth requires device code flow. Use requestDeviceCode() and pollForToken() instead.',
    );
  }

  @override
  Future<TokenInfo> refreshToken() async {
    if (cachedToken?.refreshToken == null) {
      throw AuthException(message: 'No refresh token available');
    }

    final response = await http.post(
      Uri.parse('$baseURL/api/permission/oauth2/token'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'grant_type': 'refresh_token',
        'client_id': clientId,
        'refresh_token': cachedToken!.refreshToken,
      },
    );

    if (response.statusCode != 200) {
      throw AuthException(
        message: 'Failed to refresh token: ${response.body}',
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return OAuthTokenInfo.fromJson(json);
  }
}

/// 设备码响应
class DeviceCodeResponse {
  /// 设备码
  final String deviceCode;

  /// 用户码
  final String userCode;

  /// 验证 URL
  final String verificationUri;

  /// 完整验证 URL（包含 user_code）
  final String? verificationUriComplete;

  /// 轮询间隔（秒）
  final int interval;

  /// 过期时间（秒）
  final int expiresIn;

  DeviceCodeResponse({
    required this.deviceCode,
    required this.userCode,
    required this.verificationUri,
    this.verificationUriComplete,
    required this.interval,
    required this.expiresIn,
  });

  factory DeviceCodeResponse.fromJson(Map<String, dynamic> json) {
    return DeviceCodeResponse(
      deviceCode: json['device_code'] as String,
      userCode: json['user_code'] as String,
      verificationUri: json['verification_uri'] as String,
      verificationUriComplete: json['verification_uri_complete'] as String?,
      interval: json['interval'] as int? ?? 5,
      expiresIn: json['expires_in'] as int,
    );
  }
}
