/// 取消令牌
///
/// 用于取消异步操作，类似于 C# 的 CancellationToken
///
/// 使用示例：
/// ```dart
/// final cts = CancellationTokenSource();
/// final token = cts.token;
///
/// // 在请求中使用
/// final response = await client.get('/api/data', cancellationToken: token);
///
/// // 取消请求
/// cts.cancel();
/// ```
library;

import 'dart:async';

/// 取消令牌源
///
/// 用于创建和控制取消令牌
class CancellationTokenSource {
  final _controller = StreamController<void>.broadcast();
  bool _isCancelled = false;

  /// 获取与此源关联的取消令牌
  CancellationToken get token => CancellationToken._(this);

  /// 是否已请求取消
  bool get isCancelled => _isCancelled;

  /// 取消操作
  void cancel() {
    if (!_isCancelled) {
      _isCancelled = true;
      _controller.add(null);
      _controller.close();
    }
  }

  /// 在指定时间后自动取消
  void cancelAfter(Duration delay) {
    Future.delayed(delay, cancel);
  }

  /// 内部使用：获取取消流
  Stream<void> get _cancellationStream => _controller.stream;
}

/// 取消令牌
///
/// 传递给异步操作以支持取消
class CancellationToken {
  final CancellationTokenSource _source;

  CancellationToken._(this._source);

  /// 创建一个永远不会被取消的令牌
  factory CancellationToken.never() {
    return CancellationToken._(_NeverCancellationTokenSource());
  }

  /// 是否已请求取消
  bool get isCancellationRequested => _source.isCancelled;

  /// 注册取消回调
  void register(void Function() callback) {
    if (_source.isCancelled) {
      callback();
      return;
    }

    _source._cancellationStream.listen((_) => callback());
  }

  /// 如果已请求取消，则抛出异常
  void throwIfCancellationRequested() {
    if (_source.isCancelled) {
      throw OperationCanceledException();
    }
  }

  /// 内部使用：获取取消流
  Stream<void> get cancellationStream => _source._cancellationStream;
}

/// 永远不会取消的令牌源（内部使用）
class _NeverCancellationTokenSource extends CancellationTokenSource {
  @override
  bool get isCancelled => false;

  @override
  void cancel() {
    // 无操作
  }

  @override
  void cancelAfter(Duration delay) {
    // 无操作
  }

  @override
  Stream<void> get _cancellationStream => const Stream.empty();
}

/// 操作已取消异常
class OperationCanceledException implements Exception {
  final String? message;

  const OperationCanceledException([this.message]);

  @override
  String toString() => message ?? 'Operation was canceled';
}
