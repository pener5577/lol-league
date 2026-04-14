import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/player_model.dart';
import '../models/stats_model.dart';

class PlayerRepository {
  final ApiClient _client = ApiClient();

  Future<ApiResponse> getPlayers({String? region, String? position, bool? teamless}) async {
    final params = <String, dynamic>{};
    if (region != null) params['region'] = region;
    if (position != null) params['position'] = position;
    if (teamless == true) params['teamless'] = 'true';
    return await _client.get(ApiConstants.players, params: params);
  }

  Future<ApiResponse> getCurrentPlayer() async {
    return await _client.get(ApiConstants.playerCurrent);
  }

  Future<ApiResponse> savePlayer(PlayerModel player) async {
    return await _client.post(ApiConstants.players, data: player.toJson());
  }

  Future<ApiResponse> getWinRateRanking() async {
    return await _client.get(ApiConstants.playerRankingsWinrate);
  }

  Future<ApiResponse> getKdaRanking() async {
    return await _client.get(ApiConstants.playerRankingsKda);
  }

  Future<ApiResponse> getMvpRanking() async {
    return await _client.get(ApiConstants.playerRankingsMvp);
  }

  Future<ApiResponse> updatePlayerStats(
    int playerId, {
    int? wins,
    int? losses,
    int? kills,
    int? deaths,
    int? assists,
    int? mvpCount,
    int? gamesPlayed,
    int? winStreak,
    int? winRate,
    double? kda,
  }) async {
    final data = <String, dynamic>{};
    if (wins != null) data['wins'] = wins;
    if (losses != null) data['losses'] = losses;
    if (kills != null) data['kills'] = kills;
    if (deaths != null) data['deaths'] = deaths;
    if (assists != null) data['assists'] = assists;
    if (mvpCount != null) data['mvpCount'] = mvpCount;
    if (gamesPlayed != null) data['gamesPlayed'] = gamesPlayed;
    if (winStreak != null) data['winStreak'] = winStreak;
    if (winRate != null) data['winRate'] = winRate;
    if (kda != null) data['kda'] = kda;

    return await _client.put('${ApiConstants.players}/$playerId/stats', data: data);
  }

  List<PlayerModel> parseList(ApiResponse response) {
    if (response.success && response.listData != null) {
      return response.listData!.map((json) => PlayerModel.fromJson(json)).toList();
    }
    return [];
  }

  PlayerModel? parseSingle(ApiResponse response) {
    if (response.success && response.data != null) {
      // 兼容 {"player": {...}} 格式
      if (response.data is Map<String, dynamic> && response.data.containsKey('player')) {
        return PlayerModel.fromJson(response.data['player']);
      }
      return PlayerModel.fromJson(response.data);
    }
    return null;
  }

  List<RankingItem> parseRanking(ApiResponse response) {
    if (response.success && response.listData != null) {
      return response.listData!.map((json) => RankingItem.fromJson(json)).toList();
    }
    return [];
  }
}
