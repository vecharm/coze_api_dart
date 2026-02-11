# Audio API 参考

本文档详细介绍 Audio API（语音克隆、音频房间、声纹管理）的所有类和方法。

## AudioAPI 类

音频相关 API 的主类。

### 属性

#### voices → AudioVoicesAPI

语音克隆 API。

#### rooms → AudioRoomsAPI

音频房间 API。

#### voiceprint → AudioVoiceprintAPI

声纹管理 API。

---

## AudioVoicesAPI 类

语音克隆 API。

### 方法

#### clone()

克隆语音。

```dart
Future<CloneVoiceResponse> clone(CloneVoiceRequest request)
```

#### list()

列出语音列表。

```dart
Future<ListVoicesResponse> list(ListVoicesRequest request)
```

---

## AudioRoomsAPI 类

音频房间 API。

### 方法

#### create()

创建音频房间。

```dart
Future<CreateRoomResponse> create(CreateRoomRequest request)
```

---

## AudioVoiceprintAPI 类

声纹管理 API。

### 方法

#### createFeature()

创建声纹特征。

```dart
Future<CreateVoiceprintFeatureResponse> createFeature(
  String groupId,
  CreateVoiceprintFeatureRequest request,
)
```

#### updateFeature()

更新声纹特征。

```dart
Future<void> updateFeature(
  String groupId,
  String featureId,
  UpdateVoiceprintFeatureRequest request,
)
```

#### deleteFeature()

删除声纹特征。

```dart
Future<void> deleteFeature(String groupId, String featureId)
```

#### listFeatures()

列出声纹特征。

```dart
Future<ListVoiceprintFeatureResponse> listFeatures(
  String groupId, {
  ListVoiceprintFeatureRequest? request,
})
```

#### speakerIdentify()

说话人识别。

```dart
Future<SpeakerIdentifyResponse> speakerIdentify(
  String groupId,
  SpeakerIdentifyRequest request,
)
```

---

## 相关链接

- [音频处理指南](../guides/audio.md) - 使用指南
