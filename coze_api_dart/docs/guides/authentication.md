# 认证方式详解

本文档详细介绍 Coze API Dart SDK 支持的所有认证方式，帮助你选择最适合的认证方案。

## 概述

Coze API Dart SDK 支持以下认证方式：

| 认证方式 | 适用场景 | 复杂度 | 安全性 |
|---------|---------|--------|--------|
| **PAT (Personal Access Token)** | 个人开发、测试 | ⭐ 简单 | ⭐⭐⭐ |
| **Async PAT** | 令牌需要动态获取 | ⭐⭐ 中等 | ⭐⭐⭐ |
| **OAuth Web** | Web 应用 | ⭐⭐⭐ 复杂 | ⭐⭐⭐⭐⭐ |
| **OAuth PKCE** | 移动端、单页应用 | ⭐⭐⭐ 复杂 | ⭐⭐⭐⭐⭐ |
| **JWT** | 企业级应用 | ⭐⭐⭐ 复杂 | ⭐⭐⭐⭐⭐ |
| **Device Code** | 无浏览器设备 | ⭐⭐ 中等 | ⭐⭐⭐⭐ |

---

## 1. PAT (Personal Access Token)

个人访问令牌是最简单的认证方式，适合个人开发和测试。

### 特点

- ✅ 简单易用，一行代码即可
- ✅ 长期有效（可设置过期时间）
- ✅ 支持权限控制
- ❌ 不适合生产环境的多用户场景

### 获取令牌

1. 访问 [Coze 开发者平台](https://www.coze.com/open/oauth/pats)
2. 点击 "Create a new PAT token"
3. 设置令牌名称和过期时间
4. 复制生成的令牌（格式：`pat_xxxxx`）

### 使用示例

```dart
import 'package:coze_api_dart/coze_api_dart.dart';

void main() {
  // 方式1：直接传入令牌字符串
  final client = CozeAPI(
    token: 'pat_xxxxxxxxxxxxxxxx',
    baseURL: CozeURLs.comBaseURL,
  );

  // 方式2：使用 PATAuth 类（更明确）
  final client2 = CozeAPI(
    auth: PATAuth('pat_xxxxxxxxxxxxxxxx'),
    baseURL: CozeURLs.comBaseURL,
  );
}
```

### 最佳实践

```dart
import 'package:coze_api_dart/coze_api_dart.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';  // 环境变量管理

void main() {
  // 从环境变量读取令牌（推荐）
  final token = dotenv.env['COZE_PAT_TOKEN'];
  
  if (token == null || !isPersonalAccessToken(token)) {
    throw Exception('Invalid PAT token');
  }
  
  final client = CozeAPI(
    token: token,
    baseURL: CozeURLs.comBaseURL,
  );
}
```

---

## 2. Async PAT

当令牌需要从服务器动态获取时使用异步 PAT 认证。

### 适用场景

- 令牌存储在服务器，需要 API 获取
- 令牌定期轮换
- 多租户应用

### 使用示例

```dart
import 'package:coze_api_dart/coze_api_dart.dart';

void main() {
  final client = CozeAPI(
    token: () async {
      // 从服务器获取令牌
      final response = await http.get(
        Uri.parse('https://your-server.com/api/token'),
        headers: {'Authorization': 'Bearer $userToken'},
      );
      
      final data = jsonDecode(response.body);
      return data['coze_token'];
    },
    baseURL: CozeURLs.comBaseURL,
  );
}
```

### 完整示例

```dart
import 'package:coze_api_dart/coze_api_dart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TokenManager {
  String? _cachedToken;
  DateTime? _expiryTime;
  
  Future<String> getToken() async {
    // 检查缓存是否有效
    if (_cachedToken != null && 
        _expiryTime != null && 
        DateTime.now().isBefore(_expiryTime!)) {
      return _cachedToken!;
    }
    
    // 从服务器获取新令牌
    final response = await http.post(
      Uri.parse('https://api.yourapp.com/coze/token'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': currentUserId,
        'app_key': 'your_app_key',
      }),
    );
    
    if (response.statusCode != 200) {
      throw Exception('Failed to get token: ${response.body}');
    }
    
    final data = jsonDecode(response.body);
    _cachedToken = data['token'];
    _expiryTime = DateTime.now().add(
      Duration(seconds: data['expires_in'] - 60),  // 提前1分钟过期
    );
    
    return _cachedToken!;
  }
}

void main() {
  final tokenManager = TokenManager();
  
  final client = CozeAPI(
    token: () => tokenManager.getToken(),
    baseURL: CozeURLs.comBaseURL,
  );
}
```

---

## 3. OAuth Web 应用

适用于有后端服务器的 Web 应用。

### 认证流程

1. 用户点击登录按钮
2. 跳转到 Coze 授权页面
3. 用户授权后，Coze 重定向回你的应用
4. 你的后端用授权码换取访问令牌
5. 使用访问令牌调用 API

### 配置

```dart
import 'package:coze_api_dart/coze_api_dart.dart';

// 1. 创建 OAuth 配置
final oauthConfig = OAuthConfig(
  clientId: 'your_client_id',
  clientSecret: 'your_client_secret',
  redirectUri: 'https://yourapp.com/callback',
  scopes: ['bot', 'conversation'],
);

// 2. 创建 OAuth Web Auth
final oauthAuth = OAuthWebAuth(oauthConfig);

// 3. 生成授权 URL
final authUrl = oauthAuth.getAuthorizationUrl(
  state: 'random_state_string',  // 防止 CSRF 攻击
);

// 4. 引导用户访问 authUrl
print('请访问: $authUrl');
```

### 处理回调

```dart
import 'package:coze_api_dart/coze_api_dart.dart';

// 用户授权后，Coze 会重定向到:
// https://yourapp.com/callback?code=xxx&state=xxx

Future<void> handleCallback(String code, String state) async {
  // 验证 state 防止 CSRF
  if (state != savedState) {
    throw Exception('Invalid state');
  }
  
  // 用授权码换取令牌
  final token = await oauthAuth.exchangeCodeForToken(code);
  
  // 保存令牌
  await saveToken(token);
  
  // 创建客户端
  final client = CozeAPI(
    auth: OAuthWebAuth(oauthConfig, token: token),
    baseURL: CozeURLs.comBaseURL,
  );
}
```

### 完整 Web 应用示例

```dart
import 'package:coze_api_dart/coze_api_dart.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

final oauthConfig = OAuthConfig(
  clientId: 'your_client_id',
  clientSecret: 'your_client_secret',
  redirectUri: 'http://localhost:8080/callback',
  scopes: ['bot', 'conversation'],
);

final oauthAuth = OAuthWebAuth(oauthConfig);

void main() async {
  final app = Router();
  
  // 登录页面
  app.get('/login', (Request request) {
    final authUrl = oauthAuth.getAuthorizationUrl(
      state: generateRandomState(),
    );
    return Response.movedPermanently(authUrl);
  });
  
  // 回调处理
  app.get('/callback', (Request request) async {
    final params = request.url.queryParameters;
    final code = params['code'];
    final state = params['state'];
    
    if (code == null) {
      return Response.badRequest(body: 'Missing code');
    }
    
    try {
      final token = await oauthAuth.exchangeCodeForToken(code);
      
      // 创建客户端并测试
      final client = CozeAPI(
        auth: OAuthWebAuth(oauthConfig, token: token),
        baseURL: CozeURLs.comBaseURL,
      );
      
      final user = await client.users.retrieve();
      
      return Response.ok('登录成功！用户: ${user.userName}');
    } catch (e) {
      return Response.internalServerError(body: '登录失败: $e');
    }
  });
  
  final server = await io.serve(app, 'localhost', 8080);
  print('服务器运行在 http://localhost:8080');
}
```

---

## 4. OAuth PKCE

适用于移动端应用和单页应用（SPA），不需要 client_secret。

### 特点

- ✅ 更安全，适合移动端
- ✅ 不需要 client_secret
- ✅ 防止授权码拦截攻击

### 使用示例

```dart
import 'package:coze_api_dart/coze_api_dart.dart';

void main() async {
  // 1. 创建 PKCE 配置
  final pkceAuth = OAuthPKCEAuth(
    clientId: 'your_client_id',
    redirectUri: 'com.yourapp://callback',
    scopes: ['bot', 'conversation'],
  );
  
  // 2. 生成 PKCE 参数
  final codeVerifier = pkceAuth.generateCodeVerifier();
  final codeChallenge = pkceAuth.generateCodeChallenge(codeVerifier);
  
  // 3. 生成授权 URL
  final authUrl = pkceAuth.getAuthorizationUrl(
    codeChallenge: codeChallenge,
    state: 'random_state',
  );
  
  // 4. 在移动端打开浏览器或 WebView
  // await launchUrl(Uri.parse(authUrl));
  
  // 5. 用户授权后获取授权码
  final authorizationCode = await waitForAuthorizationCode();
  
  // 6. 用授权码换取令牌
  final token = await pkceAuth.exchangeCodeForToken(
    code: authorizationCode,
    codeVerifier: codeVerifier,
  );
  
  // 7. 创建客户端
  final client = CozeAPI(
    auth: OAuthPKCEAuth(
      clientId: 'your_client_id',
      redirectUri: 'com.yourapp://callback',
      scopes: ['bot', 'conversation'],
      token: token,
    ),
    baseURL: CozeURLs.comBaseURL,
  );
}
```

### Flutter 完整示例

```dart
import 'package:flutter/material.dart';
import 'package:coze_api_dart/coze_api_dart.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uni_links/uni_links.dart';

class OAuthLoginPage extends StatefulWidget {
  @override
  _OAuthLoginPageState createState() => _OAuthLoginPageState();
}

class _OAuthLoginPageState extends State<OAuthLoginPage> {
  late final OAuthPKCEAuth _pkceAuth;
  late final String _codeVerifier;
  String? _status;
  
  @override
  void initState() {
    super.initState();
    _pkceAuth = OAuthPKCEAuth(
      clientId: 'your_client_id',
      redirectUri: 'com.yourapp://callback',
      scopes: ['bot', 'conversation'],
    );
    _codeVerifier = _pkceAuth.generateCodeVerifier();
    
    // 监听深度链接
    initUniLinks();
  }
  
  Future<void> initUniLinks() async {
    // 处理应用启动时的链接
    final initialUri = await getInitialUri();
    if (initialUri != null) {
      handleCallback(initialUri);
    }
    
    // 监听应用运行时的链接
    uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        handleCallback(uri);
      }
    });
  }
  
  Future<void> handleCallback(Uri uri) async {
    if (uri.scheme == 'com.yourapp' && uri.host == 'callback') {
      final code = uri.queryParameters['code'];
      final state = uri.queryParameters['state'];
      
      if (code != null) {
        setState(() => _status = '正在获取令牌...');
        
        try {
          final token = await _pkceAuth.exchangeCodeForToken(
            code: code,
            codeVerifier: _codeVerifier,
          );
          
          // 保存令牌
          await saveToken(token);
          
          setState(() => _status = '登录成功！');
          
          // 跳转到主页
          Navigator.pushReplacementNamed(context, '/home');
        } catch (e) {
          setState(() => _status = '登录失败: $e');
        }
      }
    }
  }
  
  Future<void> login() async {
    final codeChallenge = _pkceAuth.generateCodeChallenge(_codeVerifier);
    final authUrl = _pkceAuth.getAuthorizationUrl(
      codeChallenge: codeChallenge,
      state: generateRandomState(),
    );
    
    setState(() => _status = '等待授权...');
    
    // 打开浏览器
    await launchUrl(
      Uri.parse(authUrl),
      mode: LaunchMode.externalApplication,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Coze 登录')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: login,
              child: Text('使用 Coze 登录'),
            ),
            if (_status != null) ...[
              SizedBox(height: 20),
              Text(_status!),
            ],
          ],
        ),
      ),
    );
  }
}
```

---

## 5. JWT 认证

适用于企业级应用，使用 JWT 令牌进行认证。

### 特点

- ✅ 适合微服务架构
- ✅ 支持令牌刷新
- ✅ 可自定义 claims

### 使用示例

```dart
import 'package:coze_api_dart/coze_api_dart.dart';

void main() {
  // 创建 JWT Auth
  final jwtAuth = JWTAuth(
    token: 'your_jwt_token',
    refreshToken: 'your_refresh_token',
    onTokenRefresh: (newToken, newRefreshToken) async {
      // 保存新令牌
      await saveToken(newToken);
      await saveRefreshToken(newRefreshToken);
    },
  );
  
  final client = CozeAPI(
    auth: jwtAuth,
    baseURL: CozeURLs.comBaseURL,
  );
}
```

### 自动刷新示例

```dart
import 'package:coze_api_dart/coze_api_dart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class JWTAuthWithRefresh extends JWTAuth {
  final String refreshEndpoint;
  
  JWTAuthWithRefresh({
    required super.token,
    required super.refreshToken,
    required this.refreshEndpoint,
  }) : super(
    onTokenRefresh: (token, refreshToken) async {
      await saveToken(token);
      await saveRefreshToken(refreshToken);
    },
  );
  
  @override
  Future<String> refreshAccessToken() async {
    final response = await http.post(
      Uri.parse(refreshEndpoint),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'refresh_token': refreshToken,
      }),
    );
    
    if (response.statusCode != 200) {
      throw Exception('Token refresh failed');
    }
    
    final data = jsonDecode(response.body);
    return data['access_token'];
  }
}

void main() {
  final auth = JWTAuthWithRefresh(
    token: 'current_token',
    refreshToken: 'current_refresh_token',
    refreshEndpoint: 'https://your-server.com/refresh',
  );
  
  final client = CozeAPI(
    auth: auth,
    baseURL: CozeURLs.comBaseURL,
  );
}
```

---

## 6. Device Code Flow

适用于无浏览器或输入受限的设备（如智能电视、IoT 设备）。

### 认证流程

1. 设备请求设备码和用户码
2. 设备显示用户码，提示用户在手机/电脑上输入
3. 用户在浏览器中授权
4. 设备轮询获取访问令牌

### 使用示例

```dart
import 'package:coze_api_dart/coze_api_dart.dart';

void main() async {
  // 1. 创建设备码认证
  final deviceAuth = DeviceCodeAuth(
    clientId: 'your_client_id',
    scopes: ['bot', 'conversation'],
  );
  
  // 2. 请求设备码
  final deviceCode = await deviceAuth.requestDeviceCode();
  
  // 3. 显示给用户
  print('请在浏览器中访问: ${deviceCode.verificationUri}');
  print('输入用户码: ${deviceCode.userCode}');
  print('过期时间: ${deviceCode.expiresIn} 秒');
  
  // 4. 轮询获取令牌
  final token = await deviceAuth.pollForToken(
    deviceCode: deviceCode,
    interval: Duration(seconds: 5),
    onWaiting: (remaining) {
      print('等待授权... 剩余 ${remaining.inSeconds} 秒');
    },
  );
  
  // 5. 创建客户端
  final client = CozeAPI(
    auth: DeviceCodeAuth(
      clientId: 'your_client_id',
      scopes: ['bot', 'conversation'],
      token: token,
    ),
    baseURL: CozeURLs.comBaseURL,
  );
  
  print('登录成功！');
}
```

### 完整设备示例

```dart
import 'dart:io';
import 'package:coze_api_dart/coze_api_dart.dart';

class SmartTVAuth {
  final DeviceCodeAuth _auth;
  
  SmartTVAuth() : _auth = DeviceCodeAuth(
    clientId: 'your_client_id',
    scopes: ['bot', 'conversation'],
  );
  
  Future<void> startAuth() async {
    // 显示二维码或用户码
    final deviceCode = await _auth.requestDeviceCode();
    
    // 在 TV 屏幕上显示
    displayOnScreen('''
╔════════════════════════════════════╗
║  请使用手机扫描二维码或访问:       ║
║  ${deviceCode.verificationUri}     ║
║                                    ║
║  用户码: ${deviceCode.userCode}    ║
╚════════════════════════════════════╝
    ''');
    
    try {
      // 开始轮询
      final token = await _auth.pollForToken(
        deviceCode: deviceCode,
        interval: Duration(seconds: 5),
        onWaiting: (remaining) {
          displayOnScreen('等待授权... ${remaining.inSeconds}秒');
        },
      );
      
      // 保存令牌
      await saveToken(token);
      
      displayOnScreen('登录成功！');
    } on TimeoutException {
      displayOnScreen('登录超时，请重试');
    }
  }
  
  void displayOnScreen(String text) {
    // 在 TV 屏幕上显示文本
    print(text);
  }
}

void main() async {
  final tvAuth = SmartTVAuth();
  await tvAuth.startAuth();
}
```

---

## 认证方式选择指南

### 决策树

```
开始
  │
  ├─ 个人开发/测试？
  │   └─ 是 → 使用 PAT
  │
  ├─ Web 应用（有后端）？
  │   └─ 是 → 使用 OAuth Web
  │
  ├─ 移动端/SPA？
  │   └─ 是 → 使用 OAuth PKCE
  │
  ├─ 无浏览器设备？
  │   └─ 是 → 使用 Device Code
  │
  └─ 企业级/微服务？
      └─ 是 → 使用 JWT
```

### 场景推荐

| 场景 | 推荐认证方式 | 理由 |
|------|-------------|------|
| 个人脚本 | PAT | 简单快捷 |
| Flutter 移动应用 | OAuth PKCE | 安全，无需后端 |
| React/Vue Web 应用 | OAuth PKCE | 安全，适合 SPA |
| Node.js/Java 后端 | OAuth Web | 标准 OAuth 流程 |
| 智能电视/IoT | Device Code | 适合无输入设备 |
| 企业 SaaS | JWT | 可集成现有认证系统 |

---

## 安全最佳实践

### 1. 令牌存储

```dart
// ❌ 错误：硬编码令牌
final client = CozeAPI(token: 'pat_xxx');

// ✅ 正确：使用环境变量或安全存储
final token = await SecureStorage.read('coze_token');
final client = CozeAPI(token: token);
```

### 2. 令牌轮换

```dart
// 定期轮换 PAT 令牌
// 在 Coze 开发者平台设置过期时间
// 实现令牌自动刷新逻辑
```

### 3. 最小权限原则

```dart
// 只申请必要的 scopes
final oauthConfig = OAuthConfig(
  clientId: 'xxx',
  scopes: ['bot'],  // 只申请 bot 权限，不要申请不需要的权限
);
```

### 4. HTTPS 传输

```dart
// 确保所有通信都使用 HTTPS
final client = CozeAPI(
  token: token,
  baseURL: CozeURLs.comBaseURL,  // 自动使用 HTTPS
);
```

---

## 常见问题

### Q: PAT 令牌过期了怎么办？

A: 访问 [Coze 开发者平台](https://www.coze.com/open/oauth/pats) 重新生成令牌，或设置自动轮换机制。

### Q: OAuth 回调地址如何配置？

A: 在 Coze 开发者平台的 OAuth 应用设置中添加回调地址，确保与代码中的 `redirectUri` 完全一致。

### Q: 移动端如何实现无缝登录？

A: 使用 OAuth PKCE + 深度链接（Deep Link），用户授权后自动返回应用。

### Q: 如何测试不同的认证方式？

A: 查看 [example/auth_example.dart](../../example/auth_example.dart) 获取完整的测试示例。

---

## 下一步

- [Chat 对话指南](chat.md) - 学习对话功能
- [错误处理](../advanced/error-handling.md) - 学习错误处理
- [完整示例](../examples/complete-examples.md) - 查看更多示例
