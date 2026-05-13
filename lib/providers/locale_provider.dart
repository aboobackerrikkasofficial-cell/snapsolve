import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  Locale? _locale;
  static const String _localeKey = 'app_locale';

  Locale? get locale => _locale;

  LocaleProvider() {
    _loadSavedLocale();
  }

  void _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguageCode = prefs.getString(_localeKey);
    if (savedLanguageCode != null) {
      _locale = Locale(savedLanguageCode);
      notifyListeners();
    } else {
      _locale = const Locale('en'); // Default to English
      notifyListeners();
    }
  }

  void setLocale(Locale locale) async {
    if (!['en', 'ml', 'hi', 'ta'].contains(locale.languageCode)) return;
    
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
    notifyListeners();
  }
  
  void clearLocale() {
    _locale = null;
    notifyListeners();
  }
}
