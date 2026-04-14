import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/stats_model.dart';

class StatsRepository {
  final ApiClient _client = ApiClient();

  Future<ApiResponse> getOverview() async {
    return await _client.get(ApiConstants.statsOverview);
  }

  Future<ApiResponse> getPublic() async {
    return await _client.get(ApiConstants.statsPublic);
  }

  StatsModel? parseOverview(ApiResponse response) {
    if (response.success && response.data != null) {
      return StatsModel.fromJson(response.data);
    }
    return null;
  }
}
