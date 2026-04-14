class StatsModel {
  final int players;
  final int teams;
  final int totalMatches;
  final int totalKills;
  final int totalAssists;
  final int totalMVP;

  StatsModel({
    this.players = 0,
    this.teams = 0,
    this.totalMatches = 0,
    this.totalKills = 0,
    this.totalAssists = 0,
    this.totalMVP = 0,
  });

  factory StatsModel.fromJson(Map<String, dynamic> json) {
    return StatsModel(
      players: json['players'] ?? 0,
      teams: json['teams'] ?? 0,
      totalMatches: json['totalMatches'] ?? 0,
      totalKills: json['totalKills'] ?? 0,
      totalAssists: json['totalAssists'] ?? 0,
      totalMVP: json['totalMVP'] ?? 0,
    );
  }
}

class RankingItem {
  final int id;
  final String name;
  final String? logo;
  final dynamic value;
  final int? rank;

  RankingItem({
    required this.id,
    required this.name,
    this.logo,
    this.value,
    this.rank,
  });

  factory RankingItem.fromJson(Map<String, dynamic> json) {
    return RankingItem(
      id: json['id'] ?? 0,
      name: json['name'] ?? json['matchName'] ?? '',
      logo: json['logo'],
      value: json['value'] ?? json['winRate'] ?? json['kda'] ?? json['mvpCount'] ?? json['score'] ?? json['winStreak'] ?? 0,
      rank: json['rank'],
    );
  }
}
