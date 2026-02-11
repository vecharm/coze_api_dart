
/// Users API 数据模型
///
/// 包含用户管理相关的所有数据模型定义
library;

/// 用户信息
class User {
  /// 用户 ID
  final String id;

  /// 用户名
  final String? username;

  /// 昵称
  final String? nickname;

  /// 头像 URL
  final String? avatarUrl;

  /// 邮箱
  final String? email;

  /// 手机号
  final String? phone;

  /// 创建时间
  final DateTime createdAt;

  /// 更新时间
  final DateTime updatedAt;

  User({
    required this.id,
    this.username,
    this.nickname,
    this.avatarUrl,
    this.email,
    this.phone,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['user_id'] as String,
      username: json['username'] as String?,
      nickname: json['nickname'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (json['create_time'] as int) * 1000,
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        (json['update_time'] as int) * 1000,
      ),
    );
  }
}

/// 当前用户信息（包含更多详细信息）
class CurrentUser extends User {
  /// 用户状态
  final UserStatus status;

  /// 用户角色
  final List<UserRole> roles;

  /// 所属空间列表
  final List<String>? spaceIds;

  /// 最后登录时间
  final DateTime? lastLoginAt;

  CurrentUser({
    required super.id,
    super.username,
    super.nickname,
    super.avatarUrl,
    super.email,
    super.phone,
    required super.createdAt,
    required super.updatedAt,
    required this.status,
    required this.roles,
    this.spaceIds,
    this.lastLoginAt,
  });

  factory CurrentUser.fromJson(Map<String, dynamic> json) {
    return CurrentUser(
      id: json['user_id'] as String,
      username: json['username'] as String?,
      nickname: json['nickname'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (json['create_time'] as int) * 1000,
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        (json['update_time'] as int) * 1000,
      ),
      status: UserStatus.values.firstWhere(
        (e) => e.name == (json['status'] ?? 'active'),
        orElse: () => UserStatus.active,
      ),
      roles: (json['roles'] as List<dynamic>?)
              ?.map((e) => UserRole.values.firstWhere(
                    (r) => r.name == e,
                    orElse: () => UserRole.user,
                  ))
              .toList() ??
          [UserRole.user],
      spaceIds: (json['space_ids'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      lastLoginAt: json['last_login_time'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (json['last_login_time'] as int) * 1000,
            )
          : null,
    );
  }
}

/// 用户状态
enum UserStatus {
  /// 活跃
  active,

  /// 已禁用
  disabled,

  /// 已删除
  deleted,
}

/// 用户角色
enum UserRole {
  /// 普通用户
  user,

  /// 管理员
  admin,

  /// 超级管理员
  superAdmin,
}

/// 更新用户请求
class UpdateUserRequest {
  /// 用户 ID
  final String userId;

  /// 昵称
  final String? nickname;

  /// 头像 URL
  final String? avatarUrl;

  /// 邮箱
  final String? email;

  /// 手机号
  final String? phone;

  UpdateUserRequest({
    required this.userId,
    this.nickname,
    this.avatarUrl,
    this.email,
    this.phone,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      if (nickname != null) 'nickname': nickname,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
    };
  }
}

/// 用户配额信息
class UserQuota {
  /// 用户 ID
  final String userId;

  /// 总请求配额
  final int totalQuota;

  /// 已使用配额
  final int usedQuota;

  /// 剩余配额
  final int remainingQuota;

  /// 配额重置时间
  final DateTime? resetTime;

  UserQuota({
    required this.userId,
    required this.totalQuota,
    required this.usedQuota,
    required this.remainingQuota,
    this.resetTime,
  });

  factory UserQuota.fromJson(Map<String, dynamic> json) {
    return UserQuota(
      userId: json['user_id'] as String,
      totalQuota: json['total_quota'] as int? ?? 0,
      usedQuota: json['used_quota'] as int? ?? 0,
      remainingQuota: json['remaining_quota'] as int? ?? 0,
      resetTime: json['reset_time'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (json['reset_time'] as int) * 1000,
            )
          : null,
    );
  }
}

/// 用户使用统计
class UserUsageStats {
  /// 用户 ID
  final String userId;

  /// 总请求数
  final int totalRequests;

  /// 总 Token 数
  final int totalTokens;

  /// 本月请求数
  final int monthlyRequests;

  /// 本月 Token 数
  final int monthlyTokens;

  /// 统计时间
  final DateTime statsTime;

  UserUsageStats({
    required this.userId,
    required this.totalRequests,
    required this.totalTokens,
    required this.monthlyRequests,
    required this.monthlyTokens,
    required this.statsTime,
  });

  factory UserUsageStats.fromJson(Map<String, dynamic> json) {
    return UserUsageStats(
      userId: json['user_id'] as String,
      totalRequests: json['total_requests'] as int? ?? 0,
      totalTokens: json['total_tokens'] as int? ?? 0,
      monthlyRequests: json['monthly_requests'] as int? ?? 0,
      monthlyTokens: json['monthly_tokens'] as int? ?? 0,
      statsTime: DateTime.fromMillisecondsSinceEpoch(
        (json['stats_time'] as int) * 1000,
      ),
    );
  }
}
