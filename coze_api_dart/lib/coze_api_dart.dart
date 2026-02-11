/// Coze API Dart SDK
///
/// 扣子 (Coze) API 的官方 Dart SDK。
/// 支持 Chat 对话、流式响应、WebSocket 实时通信、
/// Bot 管理、工作流、文件上传等完整功能。
/// 兼容 Flutter 全平台和纯 Dart 后端。
///
/// 使用示例：
/// ```dart
/// import 'package:coze_api_dart/coze_api_dart.dart';
///
/// void main() async {
///   // 初始化客户端
///   final client = CozeAPI(
///     token: 'your_pat_token',
///     baseURL: CozeURLs.comBaseURL,
///   );
///
///   // 发起简单对话
///   final result = await client.chat.createAndPoll(
///     CreateChatRequest(
///       botId: 'your_bot_id',
///       additionalMessages: [
///         Message.user(content: '你好！'),
///       ],
///     ),
///   );
///
///   print(result.messages.last.content);
/// }
/// ```
library;

// 核心客户端
export 'src/client/coze_client.dart';

// 认证模块
export 'src/auth/auth_base.dart';
export 'src/auth/pat_auth.dart';
export 'src/auth/oauth_auth.dart';
export 'src/auth/jwt_auth.dart';

// Voice API (TTS/STT)
export 'src/api/voice/voice_api.dart';
export 'src/api/voice/voice_models.dart' hide ListVoicesRequest, ListVoicesResponse;

// Audio Voices API (语音克隆)
export 'src/api/audio/voices/voices_api.dart';
export 'src/api/audio/voices/voices_models.dart';

// Datasets API
export 'src/api/datasets/datasets_api.dart';
export 'src/api/datasets/datasets_models.dart'
    hide
        ListDocumentsRequest,
        ListDocumentsResponse,
        CreateDocumentRequest,
        UpdateDocumentRequest,
        ChunkStrategy,
        DocumentBase,
        SourceInfo,
        UpdateRule;

// Variables API
export 'src/api/variables/variables_api.dart';
export 'src/api/variables/variables_models.dart';

// Templates API
export 'src/api/templates/templates_api.dart';
export 'src/api/templates/templates_models.dart';

// Users API
export 'src/api/users/users_api.dart';
export 'src/api/users/users_models.dart';

// 客户端Chat API
export 'src/api/chat/chat_api.dart';
export 'src/api/chat/chat_models.dart';

// Bot API
export 'src/api/bots/bots_api.dart';
export 'src/api/bots/bots_models.dart';

// 会话管理 API
export 'src/api/conversations/conversations_api.dart';
export 'src/api/conversations/conversations_models.dart';

// 会话消息 API
export 'src/api/conversations/messages/messages_api.dart';
export 'src/api/conversations/messages/messages_models.dart';

// Workspaces API
export 'src/api/workspaces/workspaces_api.dart';
export 'src/api/workspaces/workspaces_models.dart';

// 工作流 API
export 'src/api/workflows/workflows_api.dart';
export 'src/api/workflows/workflows_models.dart';

// 工作流对话 API
export 'src/api/workflows/chat/workflows_chat_api.dart';

// 文件 API
export 'src/api/files/files_api.dart';
export 'src/api/files/files_models.dart';

// WebSocket API
export 'src/websocket/websocket_client.dart';
export 'src/websocket/websocket_events.dart';

// WebSocket Audio Speech
export 'src/websocket/audio/speech/websocket_speech.dart';

// WebSocket Audio Transcriptions
export 'src/websocket/audio/transcriptions/websocket_transcriptions.dart';

// 工具类
export 'src/utils/constants.dart';
export 'src/utils/logger.dart';
export 'src/utils/extensions.dart';
export 'src/utils/cancellation_token.dart';
export 'src/utils/utils.dart';

// Audio Rooms API
export 'src/api/audio/rooms/rooms_api.dart';
export 'src/api/audio/rooms/rooms_models.dart';

// Audio Live API
export 'src/api/audio/live/live_api.dart';
export 'src/api/audio/live/live_models.dart';

// Audio Voiceprint API
export 'src/api/audio/voiceprint/voiceprint_api.dart';
export 'src/api/audio/voiceprint/voiceprint_models.dart';

// Datasets Images API
export 'src/api/datasets/images/images_api.dart';
export 'src/api/datasets/images/images_models.dart';

// Knowledge Documents API (新版)
export 'src/api/knowledge/documents/knowledge_documents_api.dart';
export 'src/api/knowledge/documents/knowledge_documents_models.dart';

// 枚举定义
export 'src/models/enums.dart';

// 错误定义
export 'src/models/errors.dart';
