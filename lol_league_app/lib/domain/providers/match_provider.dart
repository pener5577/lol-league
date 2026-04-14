import 'package:flutter/material.dart';
import '../../data/repositories/match_repository.dart';
import '../../data/models/match_model.dart';

class MatchProvider with ChangeNotifier {
  final MatchRepository _repository = MatchRepository();

  List<MatchModel> _matches = [];
  List<MatchModel> _results = [];
  MatchModel? _currentMatch;
  bool _isLoading = false;
  String? _error;

  List<MatchModel> get matches => _matches;
  List<MatchModel> get results => _results;
  MatchModel? get currentMatch => _currentMatch;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<MatchModel> get pendingMatches =>
      _matches.where((m) => m.status == '待审核').toList();

  List<MatchModel> get waitingMatches =>
      _matches.where((m) => m.status == '待应战').toList();

  List<MatchModel> get scheduledMatches =>
      _matches.where((m) => m.status == '已约战').toList();

  Future<void> loadMatches({String? status, String? region}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _repository.getMatches(status: status, region: region);
      if (response.success) {
        _matches = _repository.parseList(response);
      } else {
        _error = response.message;
      }
    } catch (e) {
      _error = '加载约战列表失败';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadMatchById(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _repository.getMatchById(id);
      if (response.success) {
        _currentMatch = _repository.parseSingle(response);
      } else {
        _error = response.message;
      }
    } catch (e) {
      _error = '加载约战详情失败';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createMatch(MatchCreateRequest request) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _repository.createMatch(request);
      if (response.success) {
        final newMatch = _repository.parseSingle(response);
        if (newMatch != null) {
          _matches.insert(0, newMatch);
        }
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = '发布约战失败';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> acceptMatch(int matchId, int opponentTeamId) async {
    try {
      final response = await _repository.acceptMatch(matchId, opponentTeamId);
      if (response.success) {
        await loadMatchById(matchId);
        notifyListeners();
        return true;
      } else {
        _error = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = '应战失败';
      notifyListeners();
      return false;
    }
  }

  Future<bool> cancelMatch(int matchId) async {
    try {
      final response = await _repository.cancelMatch(matchId);
      if (response.success) {
        await loadMatches();
        notifyListeners();
        return true;
      } else {
        _error = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = '取消约战失败';
      notifyListeners();
      return false;
    }
  }

  Future<bool> reviewMatch(int matchId, MatchReviewRequest request) async {
    try {
      final response = await _repository.reviewMatch(matchId, request);
      if (response.success) {
        await loadMatchById(matchId);
        notifyListeners();
        return true;
      } else {
        _error = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = '审核失败';
      notifyListeners();
      return false;
    }
  }

  Future<bool> uploadScreenshot(int matchId, String screenshot) async {
    try {
      final response = await _repository.uploadScreenshot(matchId, screenshot);
      if (response.success) {
        await loadMatchById(matchId);
        notifyListeners();
        return true;
      } else {
        _error = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = '上传截图失败';
      notifyListeners();
      return false;
    }
  }

  Future<bool> submitResult(int matchId, MatchResultRequest request) async {
    try {
      final response = await _repository.submitResult(matchId, request);
      if (response.success) {
        await loadMatchById(matchId);
        notifyListeners();
        return true;
      } else {
        _error = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = '录入战绩失败';
      notifyListeners();
      return false;
    }
  }

  Future<void> loadResults() async {
    try {
      final response = await _repository.getResultsList();
      if (response.success) {
        _results = _repository.parseList(response);
        notifyListeners();
      }
    } catch (e) {
      _error = '加载战绩列表失败';
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
