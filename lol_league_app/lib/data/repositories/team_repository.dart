import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/team_model.dart';
import '../models/stats_model.dart';

class TeamRepository {
  final ApiClient _client = ApiClient();

  Future<ApiResponse> getTeams({String? region}) async {
    final params = <String, dynamic>{};
    if (region != null) params['region'] = region;
    return await _client.get(ApiConstants.teams, params: params);
  }

  Future<ApiResponse> getTeamById(int id) async {
    return await _client.get('${ApiConstants.teams}/$id');
  }

  Future<ApiResponse> createTeam(TeamModel team) async {
    return await _client.post(ApiConstants.teams, data: team.toJson());
  }

  Future<ApiResponse> updateTeam(int id, Map<String, dynamic> data) async {
    return await _client.put('${ApiConstants.teams}/$id', data: data);
  }

  Future<ApiResponse> deleteTeam(int id) async {
    return await _client.delete('${ApiConstants.teams}/$id');
  }

  Future<ApiResponse> joinTeam(int teamId) async {
    return await _client.post('${ApiConstants.teams}/$teamId/recruit');
  }

  Future<ApiResponse> leaveTeam(int teamId) async {
    return await _client.post('${ApiConstants.teams}/$teamId/leave');
  }

  Future<ApiResponse> invitePlayer(int teamId, int playerId) async {
    return await _client.post(
      '${ApiConstants.teams}/$teamId/invite',
      data: {'playerId': playerId},
    );
  }

  Future<ApiResponse> kickPlayer(int teamId, int playerId) async {
    return await _client.post(
      '${ApiConstants.teams}/$teamId/kick',
      data: {'playerId': playerId},
    );
  }

  Future<ApiResponse> getScoreRanking() async {
    return await _client.get(ApiConstants.teamRankingsScore);
  }

  Future<ApiResponse> getWinStreakRanking() async {
    return await _client.get(ApiConstants.teamRankingsWinStreak);
  }

  Future<ApiResponse> updateTeamStats(
    int teamId, {
    int? wins,
    int? losses,
    int? score,
    int? winStreak,
  }) async {
    final data = <String, dynamic>{};
    if (wins != null) data['wins'] = wins;
    if (losses != null) data['losses'] = losses;
    if (score != null) data['score'] = score;
    if (winStreak != null) data['winStreak'] = winStreak;

    return await _client.put('${ApiConstants.teams}/$teamId/stats', data: data);
  }

  List<TeamModel> parseList(ApiResponse response) {
    if (response.success && response.listData != null) {
      return response.listData!.map((json) => TeamModel.fromJson(json)).toList();
    }
    return [];
  }

  TeamModel? parseSingle(ApiResponse response) {
    if (response.success && response.data != null) {
      // 兼容 {"team": {...}} 格式
      if (response.data is Map<String, dynamic> && response.data.containsKey('team')) {
        return TeamModel.fromJson(response.data['team']);
      }
      return TeamModel.fromJson(response.data);
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
