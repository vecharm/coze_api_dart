/// HTTP 客户端
///
/// 封装 HTTP 请求，提供统一的请求接口和错误处理
library;

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' as http_parser;

import '../auth/auth_base.dart';
import '../models/errors.dart';
import '../utils/cancellation_token.dart';
import '../utils/constants.dart';
import '../utils/extensions.dart';
import '../utils/logger.dart';

/// HTTP 响应封装
class HttpResponse {
  /// HTTP 状态码
  final int statusCode;

  /// 响应体
  final dynamic body;

  /// 响应头
  final Map<String, String> headers;

  /// 请求 ID
  final String? requestId;

  /// 创建 HTTP 响应
  const HttpResponse({
    required this.statusCode,
    this.body,
    this.headers = const {},
    this.requestId,
  });

  /// 检查响应是否成功
  bool get isSuccess => statusCode >= 200 && statusCode < 300;

  /// 将响应体解析为 JSON
  Map<String, dynamic> get jsonBody {
    if (body is Map<String, dynamic>) return body;
    if (body is String) {
      return jsonDecode(body) as Map<String, dynamic>;
    }
    return {};
  }

  /// 将响应体解析为列表
  List<dynamic> get listBody {
    if (body is List) return body as List<dynamic>;
    if (body is String) {
      return jsonDecode(body) as List<dynamic>;
    }
    return [];
  }
}

/// HTTP 客户端配置
class HttpClientConfig {
  /// 基础 URL
  final String baseURL;

  /// 请求超时时间
  final Duration timeout;

  /// 流式请求超时时间
  final Duration streamTimeout;

  /// 是否启用日志
  final bool enableLogging;

  /// 默认请求头
  final Map<String, String> defaultHeaders;

  /// 最大重试次数
  final int maxRetries;

  /// 重试延迟
  final Duration retryDelay;

  /// 创建 HTTP 客户端配置
  const HttpClientConfig({
    required this.baseURL,
    this.timeout = const Duration(milliseconds: DefaultConfig.timeout),
    this.streamTimeout = const Duration(milliseconds: DefaultConfig.streamTimeout),
    this.enableLogging = false,
    this.defaultHeaders = const {},
    this.maxRetries = DefaultConfig.maxRetries,
    this.retryDelay = const Duration(milliseconds: DefaultConfig.retryDelay),
  });
}

/// HTTP 客户端
class HttpClient {
  final http.Client _client;
  final AuthBase _auth;
  final HttpClientConfig _config;

  /// 创建 HTTP 客户端
  HttpClient({
    required AuthBase auth,
    required HttpClientConfig config,
    http.Client? client,
  })  : _auth = auth,
        _config = config,
        _client = client ?? http.Client();

  /// 发送 GET 请求
  Future<HttpResponse> get(
    String path, {
    Map<String, String>? headers,
    Map<String, String>? queryParameters,
    CancellationToken? cancellationToken,
  }) async {
    return _request(
      method: 'GET',
      path: path,
      headers: headers,
      queryParameters: queryParameters,
      cancellationToken: cancellationToken,
    );
  }

  /// 发送 POST 请求
  Future<HttpResponse> post(
    String path, {
    Map<String, String>? headers,
    Map<String, String>? queryParameters,
    dynamic body,
    CancellationToken? cancellationToken,
  }) async {
    return _request(
      method: 'POST',
      path: path,
      headers: headers,
      queryParameters: queryParameters,
      body: body,
      cancellationToken: cancellationToken,
    );
  }

  /// 发送 PUT 请求
  Future<HttpResponse> put(
    String path, {
    Map<String, String>? headers,
    Map<String, String>? queryParameters,
    dynamic body,
    CancellationToken? cancellationToken,
  }) async {
    return _request(
      method: 'PUT',
      path: path,
      headers: headers,
      queryParameters: queryParameters,
      body: body,
      cancellationToken: cancellationToken,
    );
  }

  /// 发送 PATCH 请求
  Future<HttpResponse> patch(
    String path, {
    Map<String, String>? headers,
    Map<String, String>? queryParameters,
    dynamic body,
    CancellationToken? cancellationToken,
  }) async {
    return _request(
      method: 'PATCH',
      path: path,
      headers: headers,
      queryParameters: queryParameters,
      body: body,
      cancellationToken: cancellationToken,
    );
  }

  /// 发送 DELETE 请求
  Future<HttpResponse> delete(
    String path, {
    Map<String, String>? headers,
    Map<String, String>? queryParameters,
    dynamic body,
    CancellationToken? cancellationToken,
  }) async {
    return _request(
      method: 'DELETE',
      path: path,
      headers: headers,
      queryParameters: queryParameters,
      body: body,
      cancellationToken: cancellationToken,
    );
  }

  /// 发送流式请求
  Stream<String> stream(
    String path, {
    String method = 'POST',
    Map<String, String>? headers,
    Map<String, String>? queryParameters,
    dynamic body,
    CancellationToken? cancellationToken,
  }) async* {
    // 检查是否已请求取消
    cancellationToken?.throwIfCancellationRequested();

    final uri = _buildUri(path, queryParameters);
    final requestHeaders = await _buildHeaders(headers);

    if (_config.enableLogging) {
      logD('Stream Request: $method $uri');
    }

    final request = http.Request(method, uri);
    request.headers.addAll(requestHeaders);

    if (body != null) {
      if (body is String) {
        request.body = body;
      } else if (body is Map || body is List) {
        request.body = jsonEncode(body);
      } else if (body is Uint8List) {
        request.bodyBytes = body;
      }
    }

    // 发送请求并支持取消
    late final http.StreamedResponse streamedResponse;
    
    if (cancellationToken != null) {
      final completer = Completer<http.StreamedResponse>();
      late StreamSubscription<void> cancelSubscription;

      cancelSubscription = cancellationToken.cancellationStream.listen((_) {
        if (!completer.isCompleted) {
          completer.completeError(const OperationCanceledException());
        }
      });

      _client.send(request)
          .timeout(_config.streamTimeout)
          .then((response) {
            if (!completer.isCompleted) {
              completer.complete(response);
            }
          })
          .catchError((error) {
            if (!completer.isCompleted) {
              completer.completeError(error);
            }
          });

      streamedResponse = await completer.future;
      await cancelSubscription.cancel();
    } else {
      streamedResponse = await _client.send(request).timeout(
        _config.streamTimeout,
        onTimeout: () {
          throw TimeoutException(
            timeoutMs: _config.streamTimeout.inMilliseconds,
          );
        },
      );
    }

    if (streamedResponse.statusCode < 200 || streamedResponse.statusCode >= 300) {
      final body = await streamedResponse.stream.bytesToString();
      _handleError(streamedResponse.statusCode, body, requestHeaders['X-Request-Id']);
    }

    // 使用更健壮的 SSE 解析
    final buffer = StringBuffer();
    
    await for (final chunk in streamedResponse.stream.transform(utf8.decoder)) {
      // 检查取消
      cancellationToken?.throwIfCancellationRequested();
      
      buffer.write(chunk);
      
      // 处理 SSE 格式的数据
      final lines = buffer.toString().split('\n');
      buffer.clear();
      
      // 保留最后一个不完整的行到缓冲区
      if (lines.isNotEmpty && !chunk.endsWith('\n')) {
        buffer.write(lines.last);
        lines.removeLast();
      }
      
      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.isEmpty) continue;
        
        // SSE 格式: data: {...}
        if (trimmed.startsWith('data:')) {
          final data = trimmed.substring(5).trim();
          
          // 检查流结束标记
          if (data == '[DONE]') {
            yield data;
            return;
          }
          
          // 验证 JSON 格式
          try {
            jsonDecode(data);
            yield data;
          } catch (e) {
            logW('Invalid JSON in SSE stream: $data');
            // 继续处理下一行，不中断流
          }
        } else if (trimmed.startsWith('event:')) {
          // SSE 事件类型行，可以记录但不需要返回
          if (_config.enableLogging) {
            logD('SSE Event: ${trimmed.substring(6).trim()}');
          }
        } else if (trimmed.startsWith('id:')) {
          // SSE ID 行
          if (_config.enableLogging) {
            logD('SSE ID: ${trimmed.substring(3).trim()}');
          }
        } else if (trimmed.startsWith(':')) {
          // SSE 注释行，忽略
          continue;
        } else {
          // 非标准 SSE 行，尝试作为数据返回
          yield trimmed;
        }
      }
    }
    
    // 处理缓冲区中剩余的数据
    if (buffer.isNotEmpty) {
      final remaining = buffer.toString().trim();
      if (remaining.isNotEmpty) {
        yield remaining;
      }
    }
  }

  /// 发送文件上传请求
  Future<HttpResponse> uploadFile(
    String path, {
    required List<int> fileBytes,
    required String filename,
    String? contentType,
    Map<String, String>? headers,
    Map<String, String>? queryParameters,
    Map<String, String>? fields,
  }) async {
    final uri = _buildUri(path, queryParameters);
    final requestHeaders = await _buildHeaders(headers);

    final request = http.MultipartRequest('POST', uri);
    request.headers.addAll(requestHeaders);

    // 添加文件
    final multipartFile = http.MultipartFile.fromBytes(
      'file',
      fileBytes,
      filename: filename,
      contentType: contentType != null 
          ? http_parser.MediaType.parse(contentType) 
          : null,
    );
    request.files.add(multipartFile);

    // 添加其他字段
    if (fields != null) {
      request.fields.addAll(fields);
    }

    final streamedResponse = await request.send().timeout(_config.timeout);
    final response = await http.Response.fromStream(streamedResponse);

    return _processResponse(response);
  }

  /// 内部请求方法
  Future<HttpResponse> _request({
    required String method,
    required String path,
    Map<String, String>? headers,
    Map<String, String>? queryParameters,
    dynamic body,
    CancellationToken? cancellationToken,
  }) async {
    // 检查是否已请求取消
    cancellationToken?.throwIfCancellationRequested();

    final uri = _buildUri(path, queryParameters);
    final requestHeaders = await _buildHeaders(headers);

    if (_config.enableLogging) {
      logD('Request: $method $uri');
      if (body != null) {
        logD('Body: ${body is String ? body : jsonEncode(body)}');
      }
    }

    late final http.Response response;
    var retries = 0;

    while (true) {
      try {
        // 创建可取消的请求
        Future<http.Response> requestFuture;
        switch (method) {
          case 'GET':
            requestFuture = _client.get(uri, headers: requestHeaders);
            break;
          case 'POST':
            requestFuture = _client.post(
              uri,
              headers: requestHeaders,
              body: body != null ? (body is String ? body : jsonEncode(body)) : null,
            );
            break;
          case 'PUT':
            requestFuture = _client.put(
              uri,
              headers: requestHeaders,
              body: body != null ? (body is String ? body : jsonEncode(body)) : null,
            );
            break;
          case 'PATCH':
            requestFuture = _client.patch(
              uri,
              headers: requestHeaders,
              body: body != null ? (body is String ? body : jsonEncode(body)) : null,
            );
            break;
          case 'DELETE':
            requestFuture = _client.delete(
              uri,
              headers: requestHeaders,
              body: body != null ? (body is String ? body : jsonEncode(body)) : null,
            );
            break;
          default:
            throw UnsupportedError('不支持的 HTTP 方法: $method');
        }

        // 应用超时和取消令牌
        if (cancellationToken != null) {
          // 使用取消令牌包装请求
          final completer = Completer<http.Response>();
          late StreamSubscription<void> cancelSubscription;

          cancelSubscription = cancellationToken.cancellationStream.listen((_) {
            if (!completer.isCompleted) {
              completer.completeError(const OperationCanceledException());
            }
          });

          requestFuture
              .timeout(_config.timeout)
              .then((response) {
                if (!completer.isCompleted) {
                  completer.complete(response);
                }
              })
              .catchError((error) {
                if (!completer.isCompleted) {
                  completer.completeError(error);
                }
              });

          response = await completer.future;
          await cancelSubscription.cancel();
        } else {
          response = await requestFuture.timeout(_config.timeout);
        }

        break; // 请求成功，跳出重试循环
      } on TimeoutException {
        retries++;
        if (retries >= _config.maxRetries) {
          rethrow;
        }
        await Future.delayed(_config.retryDelay * retries);
      } on http.ClientException catch (e) {
        retries++;
        if (retries >= _config.maxRetries) {
          throw NetworkException(
            message: '网络请求失败: ${e.message}',
            originalError: e,
          );
        }
        await Future.delayed(_config.retryDelay * retries);
      } on OperationCanceledException {
        rethrow;
      }
    }

    return _processResponse(response);
  }

  /// 构建请求 URI
  Uri _buildUri(String path, Map<String, String>? queryParameters) {
    final baseUri = Uri.parse(_config.baseURL);
    var uri = baseUri.replace(path: '${baseUri.path}$path');
    
    if (queryParameters != null && queryParameters.isNotEmpty) {
      uri = uri.addQueryParameters(queryParameters);
    }
    
    return uri;
  }

  /// 构建请求头
  Future<Map<String, String>> _buildHeaders(Map<String, String>? extraHeaders) async {
    final headers = <String, String>{
      Headers.contentType: Headers.contentTypeJson,
      Headers.accept: Headers.acceptJson,
      ..._config.defaultHeaders,
    };

    // 添加认证头
    final authHeaders = await _auth.getHeaders();
    headers.addAll(authHeaders);

    // 添加额外请求头
    if (extraHeaders != null) {
      headers.addAll(extraHeaders);
    }

    return headers;
  }

  /// 处理响应
  HttpResponse _processResponse(http.Response response) {
    final requestId = response.headers['x-request-id'];

    if (_config.enableLogging) {
      logD('Response: ${response.statusCode}');
      logD('Body: ${response.body}');
    }

    dynamic body;
    if (response.body.isNotEmpty) {
      try {
        body = jsonDecode(response.body);
      } catch (_) {
        body = response.body;
      }
    }

    final httpResponse = HttpResponse(
      statusCode: response.statusCode,
      body: body,
      headers: response.headers,
      requestId: requestId,
    );

    if (!httpResponse.isSuccess) {
      _handleError(
        response.statusCode,
        response.body,
        requestId,
      );
    }

    return httpResponse;
  }

  /// 处理错误
  void _handleError(int statusCode, String body, String? requestId) {
    Map<String, dynamic>? errorBody;
    try {
      errorBody = jsonDecode(body) as Map<String, dynamic>;
    } catch (_) {
      errorBody = {'message': body};
    }

    throw ErrorFactory.create(
      statusCode: statusCode,
      responseBody: errorBody,
      requestId: requestId,
    );
  }

  /// 关闭客户端
  void close() {
    _client.close();
  }

  /// 构建 WebSocket URL
  ///
  /// [path] WebSocket 路径
  /// [queryParameters] 查询参数
  ///
  /// 返回完整的 WebSocket URL
  Future<String> buildWebSocketUrl(
    String path, {
    Map<String, String>? queryParameters,
  }) async {
    final baseUri = Uri.parse(_config.baseURL);

    // 将 http/https 转换为 ws/wss
    var scheme = baseUri.scheme;
    if (scheme == 'https') {
      scheme = 'wss';
    } else if (scheme == 'http') {
      scheme = 'ws';
    }

    var uri = Uri(
      scheme: scheme,
      host: baseUri.host,
      port: baseUri.port,
      path: '${baseUri.path}$path',
    );

    // 添加查询参数
    if (queryParameters != null && queryParameters.isNotEmpty) {
      uri = uri.addQueryParameters(queryParameters);
    }

    // 添加认证 token 作为查询参数
    final authHeaders = await _auth.getHeaders();
    final token = authHeaders['Authorization'];
    if (token != null) {
      final tokenValue = token.startsWith('Bearer ') ? token.substring(7) : token;
      uri = uri.addQueryParameters({'token': tokenValue});
    }

    return uri.toString();
  }
}
