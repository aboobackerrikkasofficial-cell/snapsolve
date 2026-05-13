import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_logger.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage();
  late SharedPreferences _prefs;

  Future<void> init() async {
    if (kIsWeb) {
      _prefs = await SharedPreferences.getInstance();
    }
  }

  Future<void> write(String key, String value) async {
    try {
      if (kIsWeb) {
        await _prefs.setString(key, value);
      } else {
        await _storage.write(key: key, value: value);
      }
    } catch (e) {
      AppLogger.error('Secure Storage Write Failed', error: e);
    }
  }

  Future<String?> read(String key) async {
    try {
      if (kIsWeb) {
        return _prefs.getString(key);
      } else {
        return await _storage.read(key: key);
      }
    } catch (e) {
      AppLogger.error('Secure Storage Read Failed', error: e);
      return null;
    }
  }

  Future<void> delete(String key) async {
    try {
      if (kIsWeb) {
        await _prefs.remove(key);
      } else {
        await _storage.delete(key: key);
      }
    } catch (e) {
      AppLogger.error('Secure Storage Delete Failed', error: e);
    }
  }
}
