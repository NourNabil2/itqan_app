// lib/providers/settings_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  static const String _languageKey = 'language_code';
  static const String _notificationsKey = 'notifications_enabled';
  static const String _backupKey = 'auto_backup';

  late SharedPreferences _prefs;

  ThemeMode _themeMode = ThemeMode.system;
  String _languageCode = 'ar';
  bool _notificationsEnabled = true;
  bool _autoBackupEnabled = false;

  ThemeMode get themeMode => _themeMode;
  String get languageCode => _languageCode;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get autoBackupEnabled => _autoBackupEnabled;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();

    final themeIndex = _prefs.getInt(_themeKey) ?? 0;
    _themeMode = ThemeMode.values[themeIndex];

    _languageCode = _prefs.getString(_languageKey) ?? 'ar';
    _notificationsEnabled = _prefs.getBool(_notificationsKey) ?? true;
    _autoBackupEnabled = _prefs.getBool(_backupKey) ?? false;

    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _prefs.setInt(_themeKey, mode.index);
    notifyListeners();
  }

  Future<void> setLanguage(String code) async {
    _languageCode = code;
    await _prefs.setString(_languageKey, code);
    notifyListeners();
  }

  Future<void> toggleNotifications(bool enabled) async {
    _notificationsEnabled = enabled;
    await _prefs.setBool(_notificationsKey, enabled);
    notifyListeners();
  }

  Future<void> toggleAutoBackup(bool enabled) async {
    _autoBackupEnabled = enabled;
    await _prefs.setBool(_backupKey, enabled);
    notifyListeners();
  }

  Future<void> clearSettings() async {
    await _prefs.clear();
    _themeMode = ThemeMode.system;
    _languageCode = 'ar';
    _notificationsEnabled = true;
    _autoBackupEnabled = false;
    notifyListeners();
  }
}