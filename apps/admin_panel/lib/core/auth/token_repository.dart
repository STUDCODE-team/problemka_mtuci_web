import 'package:shared_preferences/shared_preferences.dart';

class TokenRepository {
  static const _accessTokenKey = 'admin_access_token';
  static const _refreshTokenKey = 'admin_refresh_token';

  String? _accessToken;

  String? get accessToken => _accessToken;

  Future<void> setAccessToken(String token) async {
    _accessToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, token);
  }

  void setAccessTokenSync(String token) {
    _accessToken = token;
  }

  Future<void> clearAccessToken() async {
    _accessToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
  }

  Future<String?> getAccessToken() async {
    if (_accessToken != null) {
      return _accessToken;
    }
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
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
    await clearAccessToken();
    await clearRefreshToken();
  }

  bool get isLoggedIn => _accessToken != null;
}
