import 'team_model.dart';

class MatchModel {
  final int id;
  final int teamId;
  final TeamModel? team;
  final int? opponentId;
  final TeamModel? opponent;
  final String mode;
  final DateTime? time;
  final String status;
  final String note;
  final int? createdBy;
  final String? creatorUsername;
  final int? winnerId;
  final int? loserId;
  final int? mvpPlayerId;
  final String screenshot;
  final int? reviewedBy;
  final String? reviewedByUsername;
  final DateTime? reviewedAt;
  final String rejectReason;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  MatchModel({
    this.id = 0,
    this.teamId = 0,
    this.team,
    this.opponentId,
    this.opponent,
    this.mode = '5v5',
    this.time,
    this.status = '待审核',
    this.note = '',
    this.createdBy,
    this.creatorUsername,
    this.winnerId,
    this.loserId,
    this.mvpPlayerId,
    this.screenshot = '',
    this.reviewedBy,
    this.reviewedByUsername,
    this.reviewedAt,
    this.rejectReason = '',
    this.createdAt,
    this.updatedAt,
  });

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    return MatchModel(
      id: json['id'] ?? 0,
      teamId: json['teamId'] ?? 0,
      team: json['team'] != null ? TeamModel.fromJson(json['team']) : null,
      opponentId: json['opponentId'],
      opponent: json['opponent'] != null ? TeamModel.fromJson(json['opponent']) : null,
      mode: json['mode'] ?? '5v5',
      time: json['time'] != null ? DateTime.parse(json['time']) : null,
      status: json['status'] ?? '待审核',
      note: json['note'] ?? '',
      createdBy: json['createdBy'],
      creatorUsername: json['creatorUsername'],
      winnerId: json['winnerId'],
      loserId: json['loserId'],
      mvpPlayerId: json['mvpPlayerId'],
      screenshot: json['screenshot'] ?? '',
      reviewedBy: json['reviewedBy'],
      reviewedByUsername: json['reviewedByUsername'],
      reviewedAt: json['reviewedAt'] != null ? DateTime.parse(json['reviewedAt']) : null,
      rejectReason: json['rejectReason'] ?? '',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'teamId': teamId,
      'mode': mode,
      'time': time?.toIso8601String(),
      'note': note,
    };
  }

  bool get isPending => status == '待审核';
  bool get isWaitingOpponent => status == '待应战';
  bool get isScheduled => status == '已约战';
  bool get isFinished => status == '已结束';
  bool get isCancelled => status == '已取消';
  bool get isRejected => status == '未通过';

  String get regionGroup => team?.regionGroup ?? '';
}

// 约战创建请求
class MatchCreateRequest {
  final int teamId;
  final String mode;
  final DateTime time;
  final String note;

  MatchCreateRequest({
    required this.teamId,
    this.mode = '5v5',
    required this.time,
    this.note = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'teamId': teamId,
      'mode': mode,
      'time': time.toIso8601String(),
      'note': note,
    };
  }
}

// 约战应战请求
class MatchAcceptRequest {
  final int opponentTeamId;

  MatchAcceptRequest({required this.opponentTeamId});

  Map<String, dynamic> toJson() => {'opponentTeamId': opponentTeamId};
}

// 约战审核请求
class MatchReviewRequest {
  final String action; // approve 或 reject
  final String? rejectReason;

  MatchReviewRequest({required this.action, this.rejectReason});

  Map<String, dynamic> toJson() {
    return {
      'action': action,
      if (rejectReason != null) 'rejectReason': rejectReason,
    };
  }
}

// 战绩录入请求
class MatchResultRequest {
  final int winnerId;
  final int loserId;
  final List<PlayerStat> playerStats;

  MatchResultRequest({
    required this.winnerId,
    required this.loserId,
    required this.playerStats,
  });

  Map<String, dynamic> toJson() {
    return {
      'winnerId': winnerId,
      'loserId': loserId,
      'playerStats': playerStats.map((p) => p.toJson()).toList(),
    };
  }
}

class PlayerStat {
  final int playerId;
  final int teamId;
  final int kills;
  final int deaths;
  final int assists;

  PlayerStat({
    required this.playerId,
    required this.teamId,
    required this.kills,
    required this.deaths,
    required this.assists,
  });

  Map<String, dynamic> toJson() {
    return {
      'playerId': playerId,
      'teamId': teamId,
      'kills': kills,
      'deaths': deaths,
      'assists': assists,
    };
  }
}
