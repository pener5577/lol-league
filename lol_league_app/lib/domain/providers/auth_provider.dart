import 'package:flutter/material.dart';
import '../../core/network/api_client.dart';
import '../../core/storage/local_storage.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/models/user_model.dart';
import '../../data/models/player_model.dart';

class AuthProvider with ChangeNotifier {
  final AuthRepository _repository = AuthRepository();
  final LocalStorage _storage = LocalStorage();

  UserModel? _user;
  PlayerModel? _currentPlayer;
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _error;

  UserModel? get user => _user;
  PlayerModel? get currentPlayer => _currentPlayer;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;
  bool get isAdmin => _user?.isAdmin ?? false;
  bool get isInitialized => _isInitialized;
  String? get error => _error;

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      final token = await _storage.getToken();
      if (token != null) {
        ApiClient().setToken(token);
        await getCurrentUser().timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            logout();
          },
        );
      }
    } catch (e) {
      debugPrint('Auth init error: $e');
    } finally {
      _isInitialized = true;
    }
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _repository.login(
        username: username,
        password: password,
      );

      if (response.success && response.token != null) {
        await _storage.saveToken(response.token!);
        ApiClient().setToken(response.token);
        _user = _repository.parseUserFromResponse(response);
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
      _error = '登录失败: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String username,
    required String password,
    required String passwordConfirm,
    String inviteCode = '',
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _repository.register(
        username: username,
        password: password,
        passwordConfirm: passwordConfirm,
        inviteCode: inviteCode,
      );

      if (response.success && response.token != null) {
        await _storage.saveToken(response.token!);
        ApiClient().setToken(response.token);
        _user = _repository.parseUserFromResponse(response);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = _error = response.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = '注册失败: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> getCurrentUser() async {
    try {
      final response = await _repository.getCurrentUser();
      if (response.success) {
        _user = _repository.parseUserFromResponse(response);
        notifyListeners();
      }
    } catch (e) {
      // Token 可能过期
      await logout();
    }
  }

  void setCurrentPlayer(PlayerModel? player) {
    _currentPlayer = player;
    notifyListeners();
  }

  Future<void> logout() async {
    await _storage.clearAll();
    ApiClient().clearToken();
    _user = null;
    _currentPlayer = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
