import 'package:flutter/material.dart';
import '../../data/repositories/player_repository.dart';
import '../../data/models/player_model.dart';
import '../../data/models/stats_model.dart';

class PlayerProvider with ChangeNotifier {
  final PlayerRepository _repository = PlayerRepository();

  List<PlayerModel> _players = [];
  PlayerModel? _currentPlayer;
  List<RankingItem> _winRateRanking = [];
  List<RankingItem> _kdaRanking = [];
  List<RankingItem> _mvpRanking = [];
  bool _isLoading = false;
  String? _error;

  List<PlayerModel> get players => _players;
  PlayerModel? get currentPlayer => _currentPlayer;
  List<RankingItem> get winRateRanking => _winRateRanking;
  List<RankingItem> get kdaRanking => _kdaRanking;
  List<RankingItem> get mvpRanking => _mvpRanking;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadPlayers({String? region, String? position, bool? teamless}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _repository.getPlayers(region: region, position: position, teamless: teamless);
      if (response.success) {
        _players = _repository.parseList(response);
      } else {
        _error = response.message;
      }
    } catch (e) {
      _error = '加载选手列表失败';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadCurrentPlayer() async {
    try {
      final response = await _repository.getCurrentPlayer();
      debugPrint('loadCurrentPlayer response: ${response.success}, data: ${response.data}');
      if (response.success) {
        _currentPlayer = _repository.parseSingle(response);
        debugPrint('loadCurrentPlayer parsed player: regionGroup=${_currentPlayer?.regionGroup}, regionSmall=${_currentPlayer?.regionSmall}');
        notifyListeners();
      }
    } catch (e) {
      _error = '加载选手信息失败';
      notifyListeners();
    }
  }

  Future<bool> savePlayer(PlayerModel player) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _repository.savePlayer(player);
      if (response.success) {
        _currentPlayer = _repository.parseSingle(response);
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
      _error = '保存选手信息失败';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> loadWinRateRanking() async {
    try {
      final response = await _repository.getWinRateRanking();
      if (response.success) {
        _winRateRanking = _repository.parseRanking(response);
        notifyListeners();
      }
    } catch (e) {
      _error = '加载胜率榜失败';
      notifyListeners();
    }
  }

  Future<void> loadKdaRanking() async {
    try {
      final response = await _repository.getKdaRanking();
      if (response.success) {
        _kdaRanking = _repository.parseRanking(response);
        notifyListeners();
      }
    } catch (e) {
      _error = '加载KDA榜失败';
      notifyListeners();
    }
  }

  Future<void> loadMvpRanking() async {
    try {
      final response = await _repository.getMvpRanking();
      if (response.success) {
        _mvpRanking = _repository.parseRanking(response);
        notifyListeners();
      }
    } catch (e) {
      _error = '加载MVP榜失败';
      notifyListeners();
    }
  }

  Future<bool> updatePlayerStats(
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
    try {
      final response = await _repository.updatePlayerStats(
        playerId,
        wins: wins,
        losses: losses,
        kills: kills,
        deaths: deaths,
        assists: assists,
        mvpCount: mvpCount,
        gamesPlayed: gamesPlayed,
        winStreak: winStreak,
        winRate: winRate,
        kda: kda,
      );
      if (response.success) {
        await loadPlayers();
        await loadWinRateRanking();
        await loadKdaRanking();
        await loadMvpRanking();
        notifyListeners();
        return true;
      } else {
        _error = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = '更新选手数据失败';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
