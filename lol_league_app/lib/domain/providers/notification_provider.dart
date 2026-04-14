import 'package:flutter/material.dart';
import '../../data/repositories/notification_repository.dart';
import '../../data/models/notification_model.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationRepository _repository = NotificationRepository();

  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _error;

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadNotifications() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _repository.getNotifications();
      if (response.success) {
        _notifications = _repository.parseList(response);
      } else {
        _error = response.message;
      }
    } catch (e) {
      _error = '加载通知列表失败';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadUnreadCount() async {
    try {
      final response = await _repository.getUnreadCount();
      if (response.success && response.data != null) {
        _unreadCount = response.data['unreadCount'] ?? 0;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('加载未读数量失败: $e');
    }
  }

  Future<bool> acceptNotification(int id) async {
    try {
      final response = await _repository.updateNotification(id, status: 'accepted');
      if (response.success) {
        await loadNotifications();
        await loadUnreadCount();
        return true;
      } else {
        _error = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = '处理通知失败';
      notifyListeners();
      return false;
    }
  }

  Future<bool> rejectNotification(int id) async {
    try {
      final response = await _repository.updateNotification(id, status: 'rejected');
      if (response.success) {
        await loadNotifications();
        await loadUnreadCount();
        return true;
      } else {
        _error = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = '处理通知失败';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteNotification(int id) async {
    try {
      final response = await _repository.deleteNotification(id);
      if (response.success) {
        _notifications.removeWhere((n) => n.id == id);
        await loadUnreadCount();
        notifyListeners();
        return true;
      } else {
        _error = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = '删除通知失败';
      notifyListeners();
      return false;
    }
  }

  Future<bool> markAsRead(int id) async {
    try {
      final response = await _repository.markAsRead(id);
      if (response.success) {
        await loadUnreadCount();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> markAllAsRead() async {
    try {
      final response = await _repository.markAllAsRead();
      if (response.success) {
        await loadNotifications();
        _unreadCount = 0;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}