# 工具函数参考

本文档详细介绍 Coze API Dart SDK 中的工具函数。

## 安全解析

### safeJsonParse()

安全解析 JSON 字符串。

```dart
dynamic safeJsonParse(String jsonString, [dynamic defaultValue = ''])
```

**示例：**

```dart
final data = safeJsonParse(jsonString, {});
```

---

## 时间工具

### sleep()

休眠指定时间。

```dart
Future<void> sleep(int ms)
```

**示例：**

```dart
await sleep(1000);  // 休眠 1 秒
```

---

## 配置工具

### mergeConfig()

合并配置对象。

```dart
Map<String, dynamic> mergeConfig(List<Map<String, dynamic>?> objects)
```

**示例：**

```dart
final config = mergeConfig([
  {'a': 1},
  {'b': 2},
]);
// 结果: {'a': 1, 'b': 2}
```

---

## 认证工具

### isPersonalAccessToken()

检查是否为 PAT。

```dart
bool isPersonalAccessToken(String? token)
```

**示例：**

```dart
if (isPersonalAccessToken(token)) {
  print('是 PAT');
}
```

---

## URL 工具

### buildWebsocketUrl()

构建 WebSocket URL。

```dart
String buildWebsocketUrl(String path, [Map<String, dynamic>? params])
```

---

## 其他工具

### generateUuid()

生成 UUID。

```dart
String generateUuid()
```

### deepCopy()

深拷贝对象。

```dart
dynamic deepCopy(dynamic obj)
```

### isEmpty() / isNotEmpty()

检查字符串是否为空。

```dart
bool isEmpty(String? str)
bool isNotEmpty(String? str)
```

---

## 相关链接

- [工具函数源码](../../lib/src/utils/utils.dart) - 源码查看
