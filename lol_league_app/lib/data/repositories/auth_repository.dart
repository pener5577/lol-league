import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/user_model.dart';

class AuthRepository {
  final ApiClient _client = ApiClient();

  Future<ApiResponse> register({
    required String username,
    required String password,
    required String passwordConfirm,
    String inviteCode = '',
  }) async {
    return await _client.post(ApiConstants.register, data: {
      'username': username,
      'password': password,
      'passwordConfirm': passwordConfirm,
      'inviteCode': inviteCode,
    });
  }

  Future<ApiResponse> login({
    required String username,
    required String password,
  }) async {
    return await _client.post(ApiConstants.login, data: {
      'username': username,
      'password': password,
    });
  }

  Future<ApiResponse> getCurrentUser() async {
    return await _client.get(ApiConstants.me);
  }

  UserModel? parseUserFromResponse(ApiResponse response) {
    if (response.success && response.user != null) {
      return UserModel.fromJson(response.user!);
    }
    return null;
  }
}
