import 'package:shared_preferences/shared_preferences.dart';

class TokenRepository {
  static const _refreshTokenKey = 'refresh_token';

  String? _accessToken;

  String? get accessToken => _accessToken;

  void setAccessToken(String token) {
    _accessToken = token;
  }

  void clearAccessToken() {
    _accessToken = null;
  }

  Future<void> saveRefreshToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_refreshTokenKey, token);
  }

  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  Future<void> clearRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_refreshTokenKey);
  }

  Future<void> clearAll() async {
    clearAccessToken();
    await clearRefreshToken();
  }

  bool get isLoggedIn => _accessToken != null;
}
