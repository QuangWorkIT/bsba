import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  String _language = 'English';

  ThemeMode get themeMode => _themeMode;
  String get language => _language;

  SettingsProvider() {
    _loadSettings();
  }

  void _loadSettings() async {
    debugPrint('[SETTINGS_PROVIDER] _loadSettings() called');
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDark = prefs.getBool('is_dark') ?? false;
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      _language = prefs.getString('language') ?? 'English';
      debugPrint('[SETTINGS_PROVIDER] Settings loaded: isDark=$isDark, language=$_language');
      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint('[SETTINGS_PROVIDER] Exception in _loadSettings: $e\n$stackTrace');
    }
  }

  void setTheme(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark', mode == ThemeMode.dark);
  }

  void setLanguage(String lang) async {
    _language = lang;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', lang);
  }
}
