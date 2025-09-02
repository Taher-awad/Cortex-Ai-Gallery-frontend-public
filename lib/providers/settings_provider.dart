import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  static const String _darkModeKey = 'isDarkMode';
  static const String _autoUploadKey = 'isAutoUploadEnabled';
  static const String _watchedFolderKey = 'watchedFolderPath';
  static const String _gridSizeKey = 'gridSize';

  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  bool _isAutoUploadEnabled = false;
  bool get isAutoUploadEnabled => _isAutoUploadEnabled;

  String? _watchedFolderPath;
  String? get watchedFolderPath => _watchedFolderPath;

  int _gridSize = 3;
  int get gridSize => _gridSize;

  SettingsProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_darkModeKey) ?? false;
    _isAutoUploadEnabled = prefs.getBool(_autoUploadKey) ?? false;
    _watchedFolderPath = prefs.getString(_watchedFolderKey);
    _gridSize = prefs.getInt(_gridSizeKey) ?? 3;
    notifyListeners();
  }

  void toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, _isDarkMode);
    notifyListeners();
  }

  void setAutoUpload(bool value) async {
    _isAutoUploadEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoUploadKey, _isAutoUploadEnabled);
    notifyListeners();
  }

  void setWatchedFolder(String? path) async {
    _watchedFolderPath = path;
    final prefs = await SharedPreferences.getInstance();
    if (path == null) {
      await prefs.remove(_watchedFolderKey);
    } else {
      await prefs.setString(_watchedFolderKey, path);
    }
    notifyListeners();
  }

  void setGridSize(int size) async {
    _gridSize = size.clamp(2, 5); // Clamp between 2 and 5 columns
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_gridSizeKey, _gridSize);
    notifyListeners();
  }
}