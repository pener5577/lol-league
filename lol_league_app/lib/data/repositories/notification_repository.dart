import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/notification_model.dart';

class NotificationRepository {
  final ApiClient _client = ApiClient();

  Future<ApiResponse> getNotifications() async {
    return await _client.get(ApiConstants.notifications);
  }

  Future<ApiResponse> getNotificationById(int id) async {
    return await _client.get('${ApiConstants.notifications}/$id');
  }

  Future<ApiResponse> createNotification({
    required String type,
    required int toUserId,
    int? teamId,
    int? matchId,
    String? message,
  }) async {
    return await _client.post(ApiConstants.notifications, data: {
      'type': type,
      'toUserId': toUserId,
      if (teamId != null) 'teamId': teamId,
      if (matchId != null) 'matchId': matchId,
      if (message != null) 'message': message,
    });
  }

  Future<ApiResponse> updateNotification(int id, {
    required String status,
    bool? read,
  }) async {
    return await _client.put('${ApiConstants.notifications}/$id', data: {
      'status': status,
      if (read != null) 'read': read,
    });
  }

  Future<ApiResponse> deleteNotification(int id) async {
    return await _client.delete('${ApiConstants.notifications}/$id');
  }

  Future<ApiResponse> markAsRead(int id) async {
    return await _client.put('${ApiConstants.notifications}/$id/read');
  }

  Future<ApiResponse> markAllAsRead() async {
    return await _client.put('${ApiConstants.notifications}/read-all');
  }

  Future<ApiResponse> getUnreadCount() async {
    return await _client.get(ApiConstants.notificationsUnreadCount);
  }

  List<NotificationModel> parseList(ApiResponse response) {
    if (response.success && response.listData != null) {
      return response.listData!.map((json) => NotificationModel.fromJson(json)).toList();
    }
    return [];
  }

  NotificationModel? parseSingle(ApiResponse response) {
    if (response.success && response.data != null) {
      return NotificationModel.fromJson(response.data);
    }
    return null;
  }
}