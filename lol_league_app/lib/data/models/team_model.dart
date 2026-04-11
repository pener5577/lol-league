import 'player_model.dart';

class TeamModel {
  final int id;
  final String name;
  final String logo;
  final int? captainId;
  final PlayerModel? captain;
  final String regionGroup;
  final String regionSmall;
  final String description;
  final String level;
  final int wins;
  final int losses;
  final int winStreak;
  final int score;
  final String recruitStatus;
  final int memberCount;
  final List<PlayerModel> members;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TeamModel({
    this.id = 0,
    this.name = '',
    this.logo = '',
    this.captainId,
    this.captain,
    this.regionGroup = '',
    this.regionSmall = '',
    this.description = '',
    this.level = '',
    this.wins = 0,
    this.losses = 0,
    this.winStreak = 0,
    this.score = 0,
    this.recruitStatus = '',
    this.memberCount = 0,
    this.members = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory TeamModel.fromJson(Map<String, dynamic> json) {
    return TeamModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      logo: json['logo'] ?? '',
      captainId: json['captainId'],
      captain: json['captain'] != null ? PlayerModel.fromJson(json['captain']) : null,
      regionGroup: json['regionGroup'] ?? '',
      regionSmall: json['regionSmall'] ?? '',
      description: json['description'] ?? '',
      level: json['level'] ?? '',
      wins: json['wins'] ?? 0,
      losses: json['losses'] ?? 0,
      winStreak: json['winStreak'] ?? 0,
      score: json['score'] ?? 0,
      recruitStatus: json['recruitStatus'] ?? '',
      memberCount: json['memberCount'] ?? 0,
      members: (json['members'] as List<dynamic>?)
              ?.map((m) => PlayerModel.fromJson(m))
              .toList() ??
          [],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'logo': logo,
      'regionGroup': regionGroup,
      'regionSmall': regionSmall,
      'description': description,
    };
  }

  String get recordDisplay => '${wins}胜 ${losses}负';
}
