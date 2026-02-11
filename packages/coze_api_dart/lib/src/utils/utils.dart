/// 工具函数库
///
/// 提供常用的工具函数
library;

import 'dart:convert';

/// 安全解析 JSON
///
/// [jsonString] JSON 字符串
/// [defaultValue] 默认值
///
/// 返回解析后的对象或默认值
dynamic safeJsonParse(String jsonString, [dynamic defaultValue = '']) {
  try {
    return jsonDecode(jsonString);
  } catch (_) {
    return defaultValue;
  }
}

/// 休眠指定时间
///
/// [ms] 毫秒数
///
/// 返回 Future，在指定时间后完成
Future<void> sleep(int ms) {
  return Future.delayed(Duration(milliseconds: ms));
}

/// 检查是否为纯对象（Map）
///
/// [obj] 要检查的对象
///
/// 返回是否为纯对象
bool isPlainObject(dynamic obj) {
  return obj is Map<String, dynamic>;
}

/// 合并配置
///
/// [objects] 要合并的对象列表
///
/// 返回合并后的对象
Map<String, dynamic> mergeConfig(List<Map<String, dynamic>?> objects) {
  final result = <String, dynamic>{};

  for (final obj in objects) {
    if (obj == null) continue;

    for (final entry in obj.entries) {
      final key = entry.key;
      final value = entry.value;

      if (isPlainObject(value) &&
          !(value is List) &&
          isPlainObject(result[key])) {
        result[key] = mergeConfig([
          result[key] as Map<String, dynamic>,
          value as Map<String, dynamic>,
        ]);
      } else {
        result[key] = value;
      }
    }
  }

  return result;
}

/// 检查是否为个人访问令牌
///
/// [token] 令牌字符串
///
/// 返回是否为 PAT
bool isPersonalAccessToken(String? token) {
  return token?.startsWith('pat_') ?? false;
}

/// 构建 WebSocket URL
///
/// [path] 路径
/// [params] 查询参数
///
/// 返回完整的 WebSocket URL
String buildWebsocketUrl(String path, [Map<String, dynamic>? params]) {
  if (params == null || params.isEmpty) {
    return path;
  }

  final queryString = params.entries
      .where((e) =>
          e.value != null && e.value != '' && e.value.toString().isNotEmpty)
      .map((e) => '${e.key}=${Uri.encodeComponent(e.value.toString())}')
      .join('&');

  return queryString.isEmpty ? path : '$path?$queryString';
}

/// 生成 UUID
///
/// 返回 UUID 字符串
String generateUuid() {
  final random = DateTime.now().millisecondsSinceEpoch;
  return '$random-${random.hashCode}';
}

/// 深拷贝对象
///
/// [obj] 要拷贝的对象
///
/// 返回深拷贝后的对象
dynamic deepCopy(dynamic obj) {
  if (obj is Map<String, dynamic>) {
    return obj.map((key, value) => MapEntry(key, deepCopy(value)));
  } else if (obj is List) {
    return obj.map((item) => deepCopy(item)).toList();
  }
  return obj;
}

/// 检查字符串是否为空或 null
///
/// [str] 要检查的字符串
///
/// 返回是否为空
bool isEmpty(String? str) {
  return str == null || str.isEmpty;
}

/// 检查字符串是否不为空且不为 null
///
/// [str] 要检查的字符串
///
/// 返回是否不为空
bool isNotEmpty(String? str) {
  return str != null && str.isNotEmpty;
}
