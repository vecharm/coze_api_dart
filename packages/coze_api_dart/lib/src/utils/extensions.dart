
/// Coze API 扩展方法
///
/// 提供常用的扩展方法，简化代码编写
library;

import '../models/enums.dart';

/// String 扩展
extension StringExtension on String {
  /// 将字符串转换为 RoleType 枚举
  RoleType? toRoleType() {
    return RoleType.values.cast<RoleType?>().firstWhere(
          (e) => e?.name == this,
          orElse: () => null,
        );
  }
  
  /// 将字符串转换为 ContentType 枚举
  ContentType? toContentType() {
    return ContentType.values.cast<ContentType?>().firstWhere(
          (e) => e?.name == this,
          orElse: () => null,
        );
  }
  
  /// 将字符串转换为 MessageType 枚举
  MessageType? toMessageType() {
    return MessageType.values.cast<MessageType?>().firstWhere(
          (e) => e?.name == this,
          orElse: () => null,
        );
  }
  
  /// 将字符串转换为 ChatStatus 枚举
  ChatStatus? toChatStatus() {
    return ChatStatus.values.cast<ChatStatus?>().firstWhere(
          (e) => e?.name == this,
          orElse: () => null,
        );
  }
  
  /// 将字符串转换为 ChatEventType 枚举
  ChatEventType? toChatEventType() {
    return ChatEventType.values.cast<ChatEventType?>().firstWhere(
          (e) => e?.name == this,
          orElse: () => null,
        );
  }
  
  /// 将字符串转换为 WebsocketsEventType 枚举
  WebsocketsEventType? toWebsocketsEventType() {
    return WebsocketsEventType.values.cast<WebsocketsEventType?>().firstWhere(
          (e) => e?.name == this,
          orElse: () => null,
        );
  }
  
  /// 截断字符串，超过长度时添加省略号
  String truncate(int maxLength, {String ellipsis = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - ellipsis.length)}$ellipsis';
  }
  
  /// 检查字符串是否为有效的 URL
  bool get isValidUrl {
    final uri = Uri.tryParse(this);
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
  }
  
  /// 检查字符串是否为有效的 WebSocket URL
  bool get isValidWsUrl {
    final uri = Uri.tryParse(this);
    return uri != null && (uri.scheme == 'ws' || uri.scheme == 'wss');
  }
}

/// Map 扩展
extension MapExtension<K, V> on Map<K, V> {
  /// 安全地获取值，如果键不存在或类型不匹配则返回 null
  T? get<T>(K key) {
    final value = this[key];
    if (value is T) return value;
    return null;
  }
  
  /// 获取字符串值，如果不存在或不是字符串则返回默认值
  String getString(K key, {String defaultValue = ''}) {
    final value = this[key];
    if (value is String) return value;
    return defaultValue;
  }
  
  /// 获取整数值，如果不存在或不是整数则返回默认值
  int getInt(K key, {int defaultValue = 0}) {
    final value = this[key];
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }
  
  /// 获取双精度浮点数值，如果不存在或不是数字则返回默认值
  double getDouble(K key, {double defaultValue = 0.0}) {
    final value = this[key];
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? defaultValue;
    return defaultValue;
  }
  
  /// 获取布尔值，如果不存在或不是布尔值则返回默认值
  bool getBool(K key, {bool defaultValue = false}) {
    final value = this[key];
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }
    if (value is int) return value == 1;
    return defaultValue;
  }
  
  /// 获取列表值，如果不存在或不是列表则返回空列表
  List<T> getList<T>(K key) {
    final value = this[key];
    if (value is List<T>) return value;
    if (value is List) {
      return value.whereType<T>().toList();
    }
    return <T>[];
  }
  
  /// 获取嵌套 Map 值，如果不存在或不是 Map 则返回空 Map
  Map<String, dynamic> getMap(K key) {
    final value = this[key];
    if (value is Map<String, dynamic>) return value;
    return <String, dynamic>{};
  }
  
  /// 移除所有值为 null 的键
  Map<K, V> removeNullValues() {
    return Map<K, V>.fromEntries(
      entries.where((entry) => entry.value != null),
    );
  }
}

/// List 扩展
extension ListExtension<T> on List<T> {
  /// 安全地获取元素，如果索引越界则返回 null
  T? getOrNull(int index) {
    if (index < 0 || index >= length) return null;
    return this[index];
  }
  
  /// 安全地获取元素，如果索引越界则返回默认值
  T getOrElse(int index, T defaultValue) {
    if (index < 0 || index >= length) return defaultValue;
    return this[index];
  }
  
  /// 获取第一个元素，如果列表为空则返回 null
  T? get firstOrNull => isEmpty ? null : first;
  
  /// 获取最后一个元素，如果列表为空则返回 null
  T? get lastOrNull => isEmpty ? null : last;
}

/// DateTime 扩展
extension DateTimeExtension on DateTime {
  /// 格式化为 ISO 8601 字符串（带时区）
  String toIso8601StringWithTimezone() {
    final utc = toUtc();
    return utc.toIso8601String();
  }
  
  /// 检查是否已过期（与当前时间比较）
  bool get isExpired => isBefore(DateTime.now());
  
  /// 获取距离现在的时间差文本
  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(this);
    
    if (diff.inSeconds < 60) return '${diff.inSeconds}秒前';
    if (diff.inMinutes < 60) return '${diff.inMinutes}分钟前';
    if (diff.inHours < 24) return '${diff.inHours}小时前';
    if (diff.inDays < 30) return '${diff.inDays}天前';
    if (diff.inDays < 365) return '${diff.inDays ~/ 30}个月前';
    return '${diff.inDays ~/ 365}年前';
  }
}

/// Duration 扩展
extension DurationExtension on Duration {
  /// 格式化为易读的字符串
  String get format {
    if (inDays > 0) return '${inDays}天${inHours % 24}小时';
    if (inHours > 0) return '${inHours}小时${inMinutes % 60}分钟';
    if (inMinutes > 0) return '${inMinutes}分钟${inSeconds % 60}秒';
    if (inSeconds > 0) return '${inSeconds}秒';
    return '${inMilliseconds}毫秒';
  }
  
  /// 格式化为 HH:MM:SS
  String get toHms {
    final hours = inHours.toString().padLeft(2, '0');
    final minutes = (inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }
}

/// Uri 扩展
extension UriExtension on Uri {
  /// 添加查询参数
  Uri addQueryParameters(Map<String, String> params) {
    final queryParams = Map<String, String>.from(queryParameters);
    queryParams.addAll(params);
    return replace(queryParameters: queryParams);
  }
  
  /// 获取基础 URL（不含路径和查询参数）
  String get baseUrl {
    return '${scheme}://${host}${port != 80 && port != 443 ? ':$port' : ''}';
  }
}
