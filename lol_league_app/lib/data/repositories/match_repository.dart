import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/match_model.dart';

class MatchRepository {
  final ApiClient _client = ApiClient();

  Future<ApiResponse> getMatches({String? status, String? region}) async {
    final params = <String, dynamic>{};
    if (status != null) params['status'] = status;
    if (region != null) params['region'] = region;
    return await _client.get(ApiConstants.matches, params: params);
  }

  Future<ApiResponse> getMatchById(int id) async {
    return await _client.get('${ApiConstants.matches}/$id');
  }

  Future<ApiResponse> createMatch(MatchCreateRequest request) async {
    return await _client.post(ApiConstants.matches, data: request.toJson());
  }

  Future<ApiResponse> acceptMatch(int matchId, int opponentTeamId) async {
    return await _client.post(
      '${ApiConstants.matches}/$matchId/accept',
      data: MatchAcceptRequest(opponentTeamId: opponentTeamId).toJson(),
    );
  }

  Future<ApiResponse> cancelMatch(int matchId) async {
    return await _client.post('${ApiConstants.matches}/$matchId/cancel');
  }

  Future<ApiResponse> reviewMatch(int matchId, MatchReviewRequest request) async {
    return await _client.post(
      '${ApiConstants.matches}/$matchId/review',
      data: request.toJson(),
    );
  }

  Future<ApiResponse> uploadScreenshot(int matchId, String screenshot) async {
    return await _client.post(
      '${ApiConstants.matches}/$matchId/screenshot',
      data: {'screenshot': screenshot},
    );
  }

  Future<ApiResponse> submitResult(int matchId, MatchResultRequest request) async {
    return await _client.post(
      '${ApiConstants.matches}/$matchId/result',
      data: request.toJson(),
    );
  }

  Future<ApiResponse> getResultsList() async {
    return await _client.get(ApiConstants.matchResultsList);
  }

  List<MatchModel> parseList(ApiResponse response) {
    if (response.success && response.listData != null) {
      return response.listData!.map((json) => MatchModel.fromJson(json)).toList();
    }
    return [];
  }

  MatchModel? parseSingle(ApiResponse response) {
    if (response.success && response.data != null) {
      return MatchModel.fromJson(response.data);
    }
    return null;
  }
}
