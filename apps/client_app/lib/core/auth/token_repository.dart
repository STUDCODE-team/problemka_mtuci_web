import 'package:shared_preferences/shared_preferences.dart';

class TokenRepository {
  static const _hasSessionKey = 'has_session';

  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;

  void setLoggedIn() {
    _isLoggedIn = true;
  }

  Future<void> persistSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasSessionKey, true);
  }

  Future<bool> hasPersistedSession() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasSessionKey) ?? false;
  }

  Future<void> clearAll() async {
    _isLoggedIn = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_hasSessionKey);
  }
}
