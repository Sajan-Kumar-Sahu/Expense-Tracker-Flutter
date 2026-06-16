import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Persists authentication tokens and basic user info across app restarts.
class AuthStorage {
  static const _keyAccessToken = 'auth_access_token';
  static const _keyRefreshToken = 'auth_refresh_token';
  static const _keyUserId = 'auth_user_id';
  static const _keyFullName = 'auth_full_name';
  static const _keyEmail = 'auth_email';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<void> saveAuth({
    required String accessToken,
    required String refreshToken,
    required String fullName,
    required String email,
  }) async {
    final prefs = await _prefs;
    final userId = _extractSubFromJwt(accessToken);
    await prefs.setString(_keyAccessToken, accessToken);
    await prefs.setString(_keyRefreshToken, refreshToken);
    await prefs.setString(_keyFullName, fullName);
    await prefs.setString(_keyEmail, email);
    if (userId != null) await prefs.setString(_keyUserId, userId);
  }

  Future<String?> getAccessToken() async {
    return (await _prefs).getString(_keyAccessToken);
  }

  Future<String?> getRefreshToken() async {
    return (await _prefs).getString(_keyRefreshToken);
  }

  Future<String?> getUserId() async {
    return (await _prefs).getString(_keyUserId);
  }

  Future<String?> getFullName() async {
    return (await _prefs).getString(_keyFullName);
  }

  Future<String?> getEmail() async {
    return (await _prefs).getString(_keyEmail);
  }

  Future<bool> isAuthenticated() async {
    final token = (await _prefs).getString(_keyAccessToken);
    if (token == null || token.isEmpty) return false;
    // Also check refresh token — if access token expired we can still refresh
    final refreshToken = (await _prefs).getString(_keyRefreshToken);
    if (refreshToken != null && refreshToken.isNotEmpty) return true;
    return !_isTokenExpired(token);
  }

  bool _isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;
      final payload = base64Url.normalize(parts[1]);
      final decoded = utf8.decode(base64Url.decode(payload));
      final map = json.decode(decoded) as Map<String, dynamic>;
      final exp = map['exp'] as int?;
      if (exp == null) return false;
      return DateTime.now().millisecondsSinceEpoch ~/ 1000 >= exp;
    } catch (_) {
      return true;
    }
  }

  Future<void> clearAuth() async {
    final prefs = await _prefs;
    await prefs.remove(_keyAccessToken);
    await prefs.remove(_keyRefreshToken);
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyFullName);
    await prefs.remove(_keyEmail);
  }

  /// Decodes the JWT payload to extract the `sub` (user ID) claim.
  String? _extractSubFromJwt(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final payload = base64Url.normalize(parts[1]);
      final decoded = utf8.decode(base64Url.decode(payload));
      final map = json.decode(decoded) as Map<String, dynamic>;
      return map['sub'] as String?;
    } catch (_) {
      return null;
    }
  }
}
