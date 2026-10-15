import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  static const _storage = FlutterSecureStorage();

  static const String _tokenKey = 'jwt_token';
  static const String _refreshTokenKey = 'jwt_refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';

  static Future<void> saveAuthData({
    required String token,
    required String refreshToken,
    required String userId,
    required String userName,
    required String userEmail,
  }) async {
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
    await _storage.write(key: _userIdKey, value: userId);
    await _storage.write(key: _userNameKey, value: userName);
    await _storage.write(key: _userEmailKey, value: userEmail);
  }

  static Future<String?> getToken() async => await _storage.read(key: _tokenKey);
  static Future<String?> getRefreshToken() async => await _storage.read(key: _refreshTokenKey);
  static Future<String?> getUserId() async => await _storage.read(key: _userIdKey);
  static Future<String?> getUserName() async => await _storage.read(key: _userNameKey);
  static Future<String?> getUserEmail() async => await _storage.read(key: _userEmailKey);

  static Future<void> clearAuthData() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _userIdKey);
    await _storage.delete(key: _userNameKey);
    await _storage.delete(key: _userEmailKey);
  }
}
