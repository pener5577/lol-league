class NotificationModel {
  final int id;
  final String type;
  final String status;
  final int fromUserId;
  final int? fromPlayerId;
  final String? fromPlayerName;
  final int toUserId;
  final int? toPlayerId;
  final int? teamId;
  final String? teamName;
  final int? matchId;
  final String message;
  final bool read;
  final DateTime? createdAt;

  NotificationModel({
    this.id = 0,
    this.type = '',
    this.status = 'pending',
    this.fromUserId = 0,
    this.fromPlayerId,
    this.fromPlayerName,
    this.toUserId = 0,
    this.toPlayerId,
    this.teamId,
    this.teamName,
    this.matchId,
    this.message = '',
    this.read = false,
    this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? 0,
      type: json['type'] ?? '',
      status: json['status'] ?? 'pending',
      fromUserId: json['fromUserId'] ?? 0,
      fromPlayerId: json['fromPlayerId'],
      fromPlayerName: json['fromPlayerName'],
      toUserId: json['toUserId'] ?? 0,
      toPlayerId: json['toPlayerId'],
      teamId: json['teamId'],
      teamName: json['teamName'],
      matchId: json['matchId'],
      message: json['message'] ?? '',
      read: json['read'] ?? false,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'status': status,
      'fromUserId': fromUserId,
      'fromPlayerId': fromPlayerId,
      'fromPlayerName': fromPlayerName,
      'toUserId': toUserId,
      'toPlayerId': toPlayerId,
      'teamId': teamId,
      'teamName': teamName,
      'matchId': matchId,
      'message': message,
      'read': read,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  String get typeDisplayName {
    switch (type) {
      case 'team_invite':
        return '战队邀请';
      case 'team_apply':
        return '入队申请';
      case 'match_invite':
        return '约战邀请';
      case 'match_accept':
        return '约战接受';
      case 'match_reject':
        return '约战拒绝';
      default:
        return '通知';
    }
  }

  String get statusDisplayName {
    switch (status) {
      case 'pending':
        return '待处理';
      case 'accepted':
        return '已接受';
      case 'rejected':
        return '已拒绝';
      case 'cancelled':
        return '已取消';
      default:
        return status;
    }
  }

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isRejected => status == 'rejected';

  NotificationModel copyWith({
    int? id,
    String? type,
    String? status,
    int? fromUserId,
    int? fromPlayerId,
    String? fromPlayerName,
    int? toUserId,
    int? toPlayerId,
    int? teamId,
    String? teamName,
    int? matchId,
    String? message,
    bool? read,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      type: type ?? this.type,
      status: status ?? this.status,
      fromUserId: fromUserId ?? this.fromUserId,
      fromPlayerId: fromPlayerId ?? this.fromPlayerId,
      fromPlayerName: fromPlayerName ?? this.fromPlayerName,
      toUserId: toUserId ?? this.toUserId,
      toPlayerId: toPlayerId ?? this.toPlayerId,
      teamId: teamId ?? this.teamId,
      teamName: teamName ?? this.teamName,
      matchId: matchId ?? this.matchId,
      message: message ?? this.message,
      read: read ?? this.read,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}