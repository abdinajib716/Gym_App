import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Theme Mode Options
enum AppThemeMode { system, light, dark }

/// ThemeProvider - Manages app theme state with persistence
class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'app_theme_mode';

  AppThemeMode _themeMode = AppThemeMode.system;
  late SharedPreferences _prefs;
  bool _isInitialized = false;

  AppThemeMode get themeMode => _themeMode;
  bool get isInitialized => _isInitialized;

  /// Get current effective theme
  ThemeMode get effectiveThemeMode {
    switch (_themeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return _getSystemThemeMode();
    }
  }

  /// Check if current theme is dark
  bool get isDarkMode {
    switch (_themeMode) {
      case AppThemeMode.light:
        return false;
      case AppThemeMode.dark:
        return true;
      case AppThemeMode.system:
        return _isSystemDarkMode();
    }
  }

  /// Initialize provider and load saved preference
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadThemeMode();
    _isInitialized = true;
    notifyListeners();
  }

  void _loadThemeMode() {
    final savedMode = _prefs.getString(_themeKey);
    if (savedMode != null) {
      _themeMode = AppThemeMode.values.firstWhere(
        (mode) => mode.name == savedMode,
        orElse: () => AppThemeMode.system,
      );
    }
  }

  Future<void> _saveThemeMode() async {
    await _prefs.setString(_themeKey, _themeMode.name);
  }

  /// Set theme mode
  Future<void> setThemeMode(AppThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    await _saveThemeMode();
    notifyListeners();
  }

  /// Toggle between light and dark
  Future<void> toggleTheme() async {
    if (_themeMode == AppThemeMode.dark) {
      await setThemeMode(AppThemeMode.light);
    } else {
      await setThemeMode(AppThemeMode.dark);
    }
  }

  bool _isSystemDarkMode() {
    final brightness =
        SchedulerBinding.instance.platformDispatcher.platformBrightness;
    return brightness == Brightness.dark;
  }

  ThemeMode _getSystemThemeMode() {
    return _isSystemDarkMode() ? ThemeMode.dark : ThemeMode.light;
  }
}
