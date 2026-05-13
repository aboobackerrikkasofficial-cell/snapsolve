import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class ThemeProvider extends ChangeNotifier {
  final StorageService _storage;
  late bool _isDarkMode;
  late String _language;

  ThemeProvider(this._storage) {
    _isDarkMode = _storage.isDarkMode();
    _language = _storage.getLanguage();
  }

  bool get isDarkMode => _isDarkMode;
  String get language => _language;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _storage.setDarkMode(_isDarkMode);
    notifyListeners();
  }

  void setLanguage(String lang) {
    _language = lang;
    _storage.setLanguage(lang);
    notifyListeners();
  }
}
