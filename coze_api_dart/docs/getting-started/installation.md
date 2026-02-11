# 安装指南

本文档介绍如何安装和配置 Coze API Dart SDK。

## 环境要求

- **Dart SDK**: >= 3.2.0
- **Flutter**: >= 3.16.0（如使用 Flutter）
- **平台支持**: iOS、Android、Web、macOS、Windows、Linux

## 安装依赖

### 1. 添加依赖

在项目的 `pubspec.yaml` 文件中添加依赖：

```yaml
dependencies:
  coze_api_dart: ^0.1.0
```

### 2. 安装包

运行以下命令安装依赖：

```bash
dart pub get
```

或对于 Flutter 项目：

```bash
flutter pub get
```

## 导入包

在 Dart 代码中导入 SDK：

```dart
import 'package:coze_api_dart/coze_api_dart.dart';
```

## 验证安装

创建一个测试文件验证安装是否成功：

```dart
import 'package:coze_api_dart/coze_api_dart.dart';

void main() {
  print('Coze API Dart SDK 版本检查');
  print('CozeURLs.comBaseURL: ${CozeURLs.comBaseURL}');
  print('安装成功！');
}
```

运行测试：

```bash
dart test_installation.dart
```

## 下一步

- [快速开始](quick-start.md) - 5 分钟完成第一个对话
- [配置说明](configuration.md) - 了解高级配置选项
