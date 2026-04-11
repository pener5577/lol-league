import 'package:flutter/material.dart';
import '../../data/repositories/stats_repository.dart';
import '../../data/models/stats_model.dart';

class StatsProvider with ChangeNotifier {
  final StatsRepository _repository = StatsRepository();

  StatsModel? _overview;
  StatsModel? _publicStats;
  bool _isLoading = false;
  String? _error;

  StatsModel? get overview => _overview;
  StatsModel? get publicStats => _publicStats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadOverview() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _repository.getOverview();
      if (response.success) {
        _overview = _repository.parseOverview(response);
      } else {
        _error = response.message;
      }
    } catch (e) {
      _error = '加载统计概览失败';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadPublicStats() async {
    try {
      final response = await _repository.getPublic();
      if (response.success) {
        _publicStats = _repository.parseOverview(response);
        notifyListeners();
      }
    } catch (e) {
      _error = '加载公开统计失败';
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
