class PlayerModel {
  final int id;
  final int? userId;
  final int? teamId;
  final String matchName;
  final String gameId;
  final String regionGroup;
  final String regionSmall;
  final String position;
  final String onlineTime;
  final String bio;
  final String avatar;
  final int wins;
  final int losses;
  final int kills;
  final int deaths;
  final int assists;
  final int mvpCount;
  final int gamesPlayed;
  final int winStreak;
  final int winRate;
  final double kda;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PlayerModel({
    this.id = 0,
    this.userId,
    this.teamId,
    this.matchName = '',
    this.gameId = '',
    this.regionGroup = '',
    this.regionSmall = '',
    this.position = '全能',
    this.onlineTime = '',
    this.bio = '',
    this.avatar = '',
    this.wins = 0,
    this.losses = 0,
    this.kills = 0,
    this.deaths = 0,
    this.assists = 0,
    this.mvpCount = 0,
    this.gamesPlayed = 0,
    this.winStreak = 0,
    this.winRate = 0,
    this.kda = 0.0,
    this.createdAt,
    this.updatedAt,
  });

  factory PlayerModel.fromJson(Map<String, dynamic> json) {
    return PlayerModel(
      id: json['id'] ?? 0,
      userId: json['userId'],
      teamId: json['teamId'],
      matchName: json['matchName'] ?? '',
      gameId: json['gameId'] ?? '',
      regionGroup: json['regionGroup'] ?? '',
      regionSmall: json['regionSmall'] ?? '',
      position: json['position'] ?? '全能',
      onlineTime: json['onlineTime'] ?? '',
      bio: json['bio'] ?? '',
      avatar: json['avatar'] ?? '',
      wins: json['wins'] ?? 0,
      losses: json['losses'] ?? 0,
      kills: json['kills'] ?? 0,
      deaths: json['deaths'] ?? 0,
      assists: json['assists'] ?? 0,
      mvpCount: json['mvpCount'] ?? 0,
      gamesPlayed: json['gamesPlayed'] ?? 0,
      winStreak: json['winStreak'] ?? 0,
      winRate: json['winRate'] ?? 0,
      kda: (json['kda'] ?? 0).toDouble(),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'matchName': matchName,
      'gameId': gameId,
      'regionGroup': regionGroup,
      'regionSmall': regionSmall,
      'position': position,
      'onlineTime': onlineTime,
      'bio': bio,
    };
  }

  String get winRateDisplay => '${winRate}%';
  String get kdaDisplay => kda.toStringAsFixed(2);
  String get recordDisplay => '${wins}胜 ${losses}负';
}
