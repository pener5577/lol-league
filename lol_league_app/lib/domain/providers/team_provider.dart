import 'package:flutter/material.dart';
import '../../data/repositories/team_repository.dart';
import '../../data/models/team_model.dart';
import '../../data/models/stats_model.dart';

class TeamProvider with ChangeNotifier {
  final TeamRepository _repository = TeamRepository();

  List<TeamModel> _teams = [];
  TeamModel? _currentTeam;
  List<RankingItem> _scoreRanking = [];
  List<RankingItem> _winStreakRanking = [];
  bool _isLoading = false;
  String? _error;

  List<TeamModel> get teams => _teams;
  TeamModel? get currentTeam => _currentTeam;
  List<RankingItem> get scoreRanking => _scoreRanking;
  List<RankingItem> get winStreakRanking => _winStreakRanking;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadTeams({String? region}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _repository.getTeams(region: region);
      if (response.success) {
        _teams = _repository.parseList(response);
      } else {
        _error = response.message;
      }
    } catch (e) {
      _error = '加载战队列表失败';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadTeamById(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _repository.getTeamById(id);
      if (response.success) {
        _currentTeam = _repository.parseSingle(response);
      } else {
        _error = response.message;
      }
    } catch (e) {
      _error = '加载战队详情失败';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createTeam(TeamModel team) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _repository.createTeam(team);
      if (response.success) {
        _currentTeam = _repository.parseSingle(response);
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
      _error = '创建战队失败';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTeam(int id, {String? name, String? description, String? regionGroup, String? regionSmall}) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (description != null) data['description'] = description;
      if (regionGroup != null) data['region_group'] = regionGroup;
      if (regionSmall != null) data['region_small'] = regionSmall;

      debugPrint('updateTeam sending data: $data');

      final response = await _repository.updateTeam(id, data);
      debugPrint('updateTeam response: ${response.success}, message: ${response.message}');
      if (response.success) {
        await loadTeamById(id);
        notifyListeners();
        return true;
      } else {
        _error = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = '更新战队失败: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTeam(int id) async {
    try {
      final response = await _repository.deleteTeam(id);
      if (response.success) {
        _teams.removeWhere((t) => t.id == id);
        _currentTeam = null;
        notifyListeners();
        return true;
      } else {
        _error = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = '删除战队失败';
      notifyListeners();
      return false;
    }
  }

  Future<bool> joinTeam(int teamId) async {
    try {
      final response = await _repository.joinTeam(teamId);
      if (response.success) {
        await loadTeamById(teamId);
        notifyListeners();
        return true;
      } else {
        _error = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = '加入战队失败';
      notifyListeners();
      return false;
    }
  }

  Future<bool> leaveTeam(int teamId) async {
    try {
      final response = await _repository.leaveTeam(teamId);
      if (response.success) {
        _currentTeam = null;
        notifyListeners();
        return true;
      } else {
        _error = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = '退出战队失败';
      notifyListeners();
      return false;
    }
  }

  Future<bool> invitePlayer(int teamId, int playerId) async {
    try {
      final response = await _repository.invitePlayer(teamId, playerId);
      if (response.success) {
        await loadTeamById(teamId);
        notifyListeners();
        return true;
      } else {
        _error = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = '邀请选手失败';
      notifyListeners();
      return false;
    }
  }

  Future<bool> kickTeamMember(int teamId, int playerId) async {
    try {
      final response = await _repository.kickPlayer(teamId, playerId);
      if (response.success) {
        await loadTeamById(teamId);
        notifyListeners();
        return true;
      } else {
        _error = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = '移除队员失败';
      notifyListeners();
      return false;
    }
  }

  Future<void> loadScoreRanking() async {
    try {
      final response = await _repository.getScoreRanking();
      if (response.success) {
        _scoreRanking = _repository.parseRanking(response);
        notifyListeners();
      }
    } catch (e) {
      _error = '加载积分榜失败';
      notifyListeners();
    }
  }

  Future<void> loadWinStreakRanking() async {
    try {
      final response = await _repository.getWinStreakRanking();
      if (response.success) {
        _winStreakRanking = _repository.parseRanking(response);
        notifyListeners();
      }
    } catch (e) {
      _error = '加载连胜榜失败';
      notifyListeners();
    }
  }

  Future<bool> updateTeamStats(
    int teamId, {
    int? wins,
    int? losses,
    int? score,
    int? winStreak,
  }) async {
    try {
      final response = await _repository.updateTeamStats(
        teamId,
        wins: wins,
        losses: losses,
        score: score,
        winStreak: winStreak,
      );
      if (response.success) {
        await loadTeams();
        await loadScoreRanking();
        await loadWinStreakRanking();
        notifyListeners();
        return true;
      } else {
        _error = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = '更新战队数据失败';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
