
/// Coze API 枚举定义
/// 
/// 包含角色类型、消息类型、对话状态等枚举
library;

/// 角色类型
/// 
/// 定义对话中消息的发送者角色
enum RoleType {
  /// 用户
  user,
  
  /// 助手 (AI)
  assistant,
  
  /// 系统
  system,
  
  /// 工具
  tool,
}

/// 消息内容类型
/// 
/// 定义消息内容的格式类型
enum ContentType {
  /// 纯文本
  text,
  
  /// 富文本 (Markdown)
  objectString,
  
  /// 卡片
  card,
}

/// 消息类型
/// 
/// 定义消息的具体类型
enum MessageType {
  /// 问题
  question,
  
  /// 答案
  answer,
  
  /// 功能调用
  functionCall,
  
  /// 工具输出
  toolOutput,
  
  /// 工具响应
  toolResponse,
  
  /// 知识
  knowledge,
  
  /// 图片
  image,
  
  /// 语音
  audio,
  
  /// 视频
  video,
  
  /// 文件
  file,
  
  /// 引用
  citation,
  
  /// 调试信息
  debug,
  
  /// 主动消息
  proactiveMessage,
  
  /// 跟随卡片
  followUp,
  
  /// 生成结束
  generateFinished,
  
  /// 对话异常
  verbose,
}

/// 对话状态
/// 
/// 定义对话的当前状态
enum ChatStatus {
  /// 创建中
  created,
  
  /// 进行中
  inProgress,
  
  /// 已完成
  completed,
  
  /// 失败
  failed,
  
  /// 需要操作
  requiresAction,
  
  /// 已取消
  cancelled,
  
  /// 已过期
  expired,
}

/// 流式事件类型
/// 
/// 定义流式响应中的事件类型
enum ChatEventType {
  /// 对话创建
  conversationChatCreated,
  
  /// 对话进行中
  conversationChatInProgress,
  
  /// 消息创建
  conversationMessageDelta,
  
  /// 消息完成
  conversationMessageCompleted,
  
  /// 对话完成
  conversationChatCompleted,
  
  /// 对话失败
  conversationChatFailed,
  
  /// 需要操作
  conversationChatRequiresAction,
  
  /// 工具调用创建
  conversationToolCallsCreated,
  
  /// 工具调用进行中
  conversationToolCallsInProgress,
  
  /// 工具调用完成
  conversationToolCallsCompleted,
  
  /// 音频完成
  conversationAudioCompleted,
  
  /// 音频转录更新
  conversationAudioTranscriptUpdate,
  
  /// 音频转录完成
  conversationAudioTranscriptCompleted,
  
  /// 错误
  error,
  
  /// 完成
  done,
}

/// WebSocket 事件类型
/// 
/// 定义 WebSocket 通信中的事件类型
enum WebsocketsEventType {
  /// 错误
  error,
  
  /// 对话更新
  chatUpdate,
  
  /// 消息创建
  conversationMessageCreate,
  
  /// 消息更新
  conversationMessageUpdate,
  
  /// 消息完成
  conversationMessageCompleted,
  
  /// 消息增量
  conversationMessageDelta,
  
  /// 对话完成
  conversationChatCompleted,
  
  /// 对话创建
  conversationChatCreated,
  
  /// 对话进行中
  conversationChatInProgress,
  
  /// 对话失败
  conversationChatFailed,
  
  /// 需要操作
  conversationChatRequiresAction,
  
  /// 输入音频缓冲区完成
  inputAudioBufferCompleted,
  
  /// 输入音频缓冲区清除
  inputAudioBufferCleared,
  
  /// 音频转录更新
  conversationAudioTranscriptUpdate,
  
  /// 音频转录完成
  conversationAudioTranscriptCompleted,
  
  /// 音频完成
  conversationAudioCompleted,
  
  /// TTS 消息创建
  conversationTtsMessageCreate,
  
  /// TTS 消息更新
  conversationTtsMessageUpdate,
  
  /// TTS 消息完成
  conversationTtsMessageCompleted,
  
  /// 语音转文本创建
  conversationSpeechToTextCreated,
  
  /// 语音转文本更新
  conversationSpeechToTextUpdated,
  
  /// 语音转文本完成
  conversationSpeechToTextCompleted,
  
  /// Ping
  ping,
  
  /// Pong
  pong,
}

/// 工具调用类型
/// 
/// 定义工具调用的类型
enum ToolCallType {
  /// 功能
  function,
}

/// 工具选择类型
/// 
/// 定义工具选择策略
enum ToolChoiceType {
  /// 不调用工具
  none,
  
  /// 自动选择
  auto,
  
  /// 必须调用
  required,
}

/// 文件类型
/// 
/// 定义支持的文件类型
enum FileType {
  /// 图片
  image,
  
  /// 文档
  document,
  
  /// 音频
  audio,
  
  /// 视频
  video,
}

/// 语音格式
/// 
/// 定义语音数据的格式
enum AudioFormat {
  /// PCM 格式
  pcm,
  
  /// MP3 格式
  mp3,
  
  /// WAV 格式
  wav,
  
  /// OGG 格式
  ogg,
}

/// 语音转文本状态
/// 
/// 定义语音转文本任务的状态
enum TranscriptionStatus {
  /// 处理中
  processing,
  
  /// 已完成
  completed,
  
  /// 失败
  failed,
}

/// 工作流执行状态
/// 
/// 定义工作流执行的状态
enum WorkflowStatus {
  /// 运行中
  running,
  
  /// 成功
  success,
  
  /// 失败
  fail,
}

/// 数据集格式类型
/// 
/// 定义数据集的格式类型
enum DatasetFormatType {
  /// 问答对格式
  qa,
  
  /// 文档格式
  document,
}

/// 数据集状态
/// 
/// 定义数据集的当前状态
enum DatasetStatus {
  /// 启用
  enabled,
  
  /// 禁用
  disabled,
}

/// 文档类型
/// 
/// 定义文档的类型
enum DocumentType {
  /// 文本
  text,
  
  /// 问答对
  qa,
  
  /// 表格
  table,
}

/// 文档处理状态
/// 
/// 定义文档的处理状态
enum DocumentStatus {
  /// 处理中
  processing,
  
  /// 已完成
  completed,
  
  /// 失败
  failed,
}
