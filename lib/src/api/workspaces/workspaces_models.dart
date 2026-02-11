/// Workspaces API 数据模型
///
/// 包含工作空间管理相关的所有数据模型定义
library;

/// 列出工作空间请求
class ListWorkspacesRequest {
  /// 页码
  final int? pageNum;

  /// 分页大小
  final int? pageSize;

  /// 企业 ID
  final String? enterpriseId;

  /// 用户 ID
  final String? userId;

  /// Coze 账号 ID
  final String? cozeAccountId;

  ListWorkspacesRequest({
    this.pageNum,
    this.pageSize,
    this.enterpriseId,
    this.userId,
    this.cozeAccountId,
  });

  Map<String, dynamic> toJson() {
    return {
      if (pageNum != null) 'page_num': pageNum.toString(),
      if (pageSize != null) 'page_size': pageSize.toString(),
      if (enterpriseId != null) 'enterprise_id': enterpriseId,
      if (userId != null) 'user_id': userId,
      if (cozeAccountId != null) 'coze_account_id': cozeAccountId,
    };
  }
}

/// 列出工作空间响应
class ListWorkspacesResponse {
  /// 工作空间列表
  final List<Workspace> workspaces;

  /// 总数
  final int totalCount;

  ListWorkspacesResponse({
    required this.workspaces,
    required this.totalCount,
  });

  factory ListWorkspacesResponse.fromJson(Map<String, dynamic> json) {
    return ListWorkspacesResponse(
      workspaces: (json['workspaces'] as List<dynamic>?)
              ?.map((e) => Workspace.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      totalCount: json['total_count'] as int? ?? 0,
    );
  }
}

/// 工作空间
class Workspace {
  /// 工作空间 ID
  final String id;

  /// 工作空间名称
  final String name;

  /// 图标 URL
  final String iconUrl;

  /// 角色类型
  final String roleType;

  /// 工作空间类型
  final String workspaceType;

  /// 企业 ID
  final String? enterpriseId;

  Workspace({
    required this.id,
    required this.name,
    required this.iconUrl,
    required this.roleType,
    required this.workspaceType,
    this.enterpriseId,
  });

  factory Workspace.fromJson(Map<String, dynamic> json) {
    return Workspace(
      id: json['id'] as String,
      name: json['name'] as String,
      iconUrl: json['icon_url'] as String,
      roleType: json['role_type'] as String,
      workspaceType: json['workspace_type'] as String,
      enterpriseId: json['enterprise_id'] as String?,
    );
  }
}
