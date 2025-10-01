//============= 1. Settings Provider =============
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  static const String _languageKey = 'language_code';
  static const String _notificationsKey = 'notifications_enabled';
  static const String _backupKey = 'auto_backup';

  late SharedPreferences _prefs;

// Settings values
  ThemeMode _themeMode = ThemeMode.system;
  String _languageCode = 'ar';
  bool _notificationsEnabled = true;
  bool _autoBackupEnabled = false;
  bool _isLoggedIn = false;
  bool _isPremium = false;

// Getters
  ThemeMode get themeMode => _themeMode;
  String get languageCode => _languageCode;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get autoBackupEnabled => _autoBackupEnabled;
  bool get isLoggedIn => _isLoggedIn;
  bool get isPremium => _isPremium;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();

// Load theme
    final themeIndex = _prefs.getInt(_themeKey) ?? 0;
    _themeMode = ThemeMode.values[themeIndex];

// Load language
    _languageCode = _prefs.getString(_languageKey) ?? 'ar';

// Load other settings
    _notificationsEnabled = _prefs.getBool(_notificationsKey) ?? true;
    _autoBackupEnabled = _prefs.getBool(_backupKey) ?? false;

    notifyListeners();
  }

// Theme methods
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _prefs.setInt(_themeKey, mode.index);
    notifyListeners();
  }

// Language methods
  Future<void> setLanguage(String code) async {
    _languageCode = code;
    await _prefs.setString(_languageKey, code);
    notifyListeners();
  }

// Notifications
  Future<void> toggleNotifications(bool enabled) async {
    _notificationsEnabled = enabled;
    await _prefs.setBool(_notificationsKey, enabled);
    notifyListeners();
  }

// Auto backup
  Future<void> toggleAutoBackup(bool enabled) async {
    _autoBackupEnabled = enabled;
    await _prefs.setBool(_backupKey, enabled);
    notifyListeners();
  }

// Auth methods
  void setLoggedIn(bool value) {
    _isLoggedIn = value;
    notifyListeners();
  }

  void setPremium(bool value) {
    _isPremium = value;
    notifyListeners();
  }

// Clear all settings
  Future<void> clearSettings() async {
    await _prefs.clear();
    _themeMode = ThemeMode.system;
    _languageCode = 'ar';
    _notificationsEnabled = true;
    _autoBackupEnabled = false;
    notifyListeners();
  }
}
