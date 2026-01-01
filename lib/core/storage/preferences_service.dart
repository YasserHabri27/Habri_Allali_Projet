import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _tokenKey = 'auth_token';
  static const String _themeKey = 'is_dark_theme';
  static const String _userIdKey = 'user_id';
  
  final SharedPreferences _prefs;
  
  PreferencesService(this._prefs);
  
  // Token
  String? get token => _prefs.getString(_tokenKey);
  Future<void> setToken(String token) => _prefs.setString(_tokenKey, token);
  Future<void> removeToken() => _prefs.remove(_tokenKey);
  
  // Theme
  bool get isDarkTheme => _prefs.getBool(_themeKey) ?? false;
  Future<void> setDarkTheme(bool isDark) => _prefs.setBool(_themeKey, isDark);
  
  // User ID
  String? get userId => _prefs.getString(_userIdKey);
  Future<void> setUserId(String userId) => _prefs.setString(_userIdKey, userId);
  Future<void> removeUserId() => _prefs.remove(_userIdKey);
  
  // Clear all
  Future<void> clearAll() => _prefs.clear();
}
