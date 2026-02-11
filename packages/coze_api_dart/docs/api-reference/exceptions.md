# 异常处理参考

本文档详细介绍 Coze API Dart SDK 中的异常类。

## CozeException

SDK 基础异常类。

### 属性

| 属性 | 类型 | 说明 |
|------|------|------|
| `message` | `String` | 错误信息 |
| `code` | `String?` | 错误码 |

### 构造函数

```dart
CozeException({
  required String message,
  String? code,
})
```

---

## CancelledException

请求取消异常。

```dart
try {
  await operation();
} on CancelledException catch (e) {
  print('请求已取消');
}
```

---

## TimeoutException

请求超时异常。

```dart
try {
  await operation();
} on TimeoutException catch (e) {
  print('请求超时');
}
```

---

## 错误处理示例

```dart
try {
  final result = await client.chat.createAndPoll(...);
} on CozeException catch (e) {
  print('Coze 错误: ${e.message}, 码: ${e.code}');
} on CancelledException catch (e) {
  print('请求已取消');
} on TimeoutException catch (e) {
  print('请求超时');
} catch (e) {
  print('未知错误: $e');
}
```

---

## 相关链接

- [错误处理指南](../advanced/error-handling.md) - 最佳实践
