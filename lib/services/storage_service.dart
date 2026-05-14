import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/analysis_result.dart';
import '../constants/app_constants.dart';

class StorageService {
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // History Methods
  Future<void> saveAnalysis(AnalysisResult result) async {
    final List<AnalysisResult> history = getHistory();
    history.insert(0, result);
    final String encoded = json.encode(history.map((e) => e.toMap()).toList());
    await _prefs.setString(AppConstants.keyHistory, encoded);
  }

  List<AnalysisResult> getHistory() {
    final String? encoded = _prefs.getString(AppConstants.keyHistory);
    if (encoded == null) return [];
    final List decoded = json.decode(encoded);
    return decoded.map((e) => AnalysisResult.fromMap(e)).toList();
  }

  Future<void> deleteAnalysis(String id) async {
    final List<AnalysisResult> history = getHistory();
    history.removeWhere((element) => element.id == id);
    final String encoded = json.encode(history.map((e) => e.toMap()).toList());
    await _prefs.setString(AppConstants.keyHistory, encoded);
  }

  Future<void> clearHistory() async {
    await _prefs.remove(AppConstants.keyHistory);
  }

  // Settings Methods
  Future<void> setDarkMode(bool isDark) async {
    await _prefs.setBool(AppConstants.keyDarkMode, isDark);
  }

  bool isDarkMode() {
    return _prefs.getBool(AppConstants.keyDarkMode) ?? true;
  }

  Future<void> setLanguage(String lang) async {
    await _prefs.setString(AppConstants.keyLanguage, lang);
  }

  String getLanguage() {
    return _prefs.getString(AppConstants.keyLanguage) ?? 'en';
  }

  Future<void> setOnboardingComplete() async {
    await _prefs.setBool(AppConstants.keyOnboardingComplete, true);
  }

  bool isOnboardingComplete() {
    return _prefs.getBool(AppConstants.keyOnboardingComplete) ?? false;
  }

  // Session Methods
  Future<void> saveSession(String sessionData) async {
    await _prefs.setString(AppConstants.keyUserAuth, sessionData);
  }

  String? getSession() {
    return _prefs.getString(AppConstants.keyUserAuth);
  }

  Future<void> clearSession() async {
    await _prefs.remove(AppConstants.keyUserAuth);
  }

  // Generic Raw Methods
  Future<void> saveRaw(String key, String value) async {
    await _prefs.setString(key, value);
  }

  String? getRaw(String key) {
    return _prefs.getString(key);
  }
}
