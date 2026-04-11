import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocalStorage {
  static final LocalStorage _instance = LocalStorage._internal();
  factory LocalStorage() => _instance;

  LocalStorage._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  // Token 管理
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> removeToken() async {
    await _storage.delete(key: _tokenKey);
  }

  // 用户数据管理
  Future<void> saveUser(Map<String, dynamic> userData) async {
    final String encoded = userData.toString();
    await _storage.write(key: _userKey, value: encoded);
  }

  Future<Map<String, dynamic>?> getUser() async {
    final String? data = await _storage.read(key: _userKey);
    return null; // 简化处理，实际应该解析
  }

  Future<void> removeUser() async {
    await _storage.delete(key: _userKey);
  }

  // 清除所有
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
