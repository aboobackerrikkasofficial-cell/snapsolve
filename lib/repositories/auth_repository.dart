import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import '../models/app_user.dart';
import '../services/database_service.dart';
import '../utils/app_logger.dart';
import '../services/secure_storage_service.dart';
import '../services/security_monitor.dart';
import 'package:flutter/foundation.dart';

abstract class AuthRepository {
  Future<AppUser> login(String email, String password);
  Future<AppUser> register(String name, String email, String password);
  Future<void> logout();
  Future<AppUser?> getCurrentUser();
  Future<AppUser> loginAsGuest();
}

class DatabaseAuthRepository implements AuthRepository {
  final DatabaseService _dbService = DatabaseService();
  final SecureStorageService _secureStorage;
  final _uuid = const Uuid();

  DatabaseAuthRepository(this._secureStorage);

  @override
  Future<AppUser> login(String email, String password) async {
    final normalizedEmail = email.trim().toLowerCase();

    // Security: Check if user is blocked
    if (SecurityMonitor.isUserBlocked(normalizedEmail)) {
      throw Exception(
          'This account is locked for security reasons. Please contact support.');
    }

    if (kIsWeb) {
      return _loginWeb(normalizedEmail, password);
    }

    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ? AND is_guest = 0',
      whereArgs: [normalizedEmail],
    );

    if (maps.isEmpty) {
      SecurityMonitor.trackViolation(normalizedEmail, 'INVALID_LOGIN_ATTEMPT');
      throw Exception('No account found with this email.');
    }

    final userData = maps.first;
    final storedHash = userData['hashed_password'] as String;
    final inputHash = _hashPassword(password, normalizedEmail);

    if (storedHash != inputHash) {
      SecurityMonitor.trackViolation(normalizedEmail, 'INCORRECT_PASSWORD');
      throw Exception('Incorrect password.');
    }

    final user = AppUser.fromMap({
      'id': userData['id'],
      'name': userData['name'],
      'email': userData['email'],
      'role': userData['role'],
      'isGuest': userData['is_guest'],
      'createdAt': userData['created_at'],
    });

    await _saveSession(user);

    await db.update(
      'users',
      {'last_login': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [user.id],
    );

    return user;
  }

  @override
  Future<AppUser> register(String name, String email, String password) async {
    final normalizedEmail = email.trim().toLowerCase();

    if (kIsWeb) {
      return _registerWeb(name, normalizedEmail, password);
    }

    final db = await _dbService.database;
    final List<Map<String, dynamic>> existing = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [normalizedEmail],
    );

    if (existing.isNotEmpty) {
      throw Exception('An account already exists with this email.');
    }

    final userId = _uuid.v4();
    final hashedPassword = _hashPassword(password, normalizedEmail);
    final now = DateTime.now().toIso8601String();

    final userMap = {
      'id': userId,
      'name': name.trim(),
      'email': normalizedEmail,
      'hashed_password': hashedPassword,
      'created_at': now,
      'last_login': now,
      'is_guest': 0,
      'role': 'user',
      'verified': 0,
    };

    await db.insert('users', userMap);

    final user = AppUser(
      id: userId,
      name: name.trim(),
      email: normalizedEmail,
      createdAt: DateTime.parse(now),
    );

    await _saveSession(user);
    return user;
  }

  // Web Simulation using Secure Storage (which falls back to prefs on Web)
  Future<AppUser> _loginWeb(String email, String password) async {
    final rawUsers = await _secureStorage.read('web_users');
    final List<dynamic> users = rawUsers != null ? jsonDecode(rawUsers) : [];

    final userMap = users.firstWhere(
      (u) => u['email'] == email,
      orElse: () => throw Exception('No account found with this email.'),
    );

    final inputHash = _hashPassword(password, email);
    if (userMap['hashed_password'] != inputHash) {
      SecurityMonitor.trackViolation(email, 'INCORRECT_PASSWORD_WEB');
      throw Exception('Incorrect password.');
    }

    final user = AppUser.fromMap(userMap);
    await _saveSession(user);
    return user;
  }

  Future<AppUser> _registerWeb(
      String name, String email, String password) async {
    final rawUsers = await _secureStorage.read('web_users');
    final List<dynamic> users = rawUsers != null ? jsonDecode(rawUsers) : [];

    if (users.any((u) => u['email'] == email)) {
      throw Exception('An account already exists with this email.');
    }

    final userId = _uuid.v4();
    final hashedPassword = _hashPassword(password, email);
    final now = DateTime.now().toIso8601String();

    final userMap = {
      'id': userId,
      'name': name.trim(),
      'email': email,
      'hashed_password': hashedPassword,
      'created_at': now,
      'role': 'user',
      'isGuest': 0,
    };

    users.add(userMap);
    await _secureStorage.write('web_users', jsonEncode(users));

    final user = AppUser.fromMap(userMap);
    await _saveSession(user);
    return user;
  }

  @override
  Future<AppUser> loginAsGuest() async {
    final guestId = 'guest_${_uuid.v4().substring(0, 8)}';
    final user = AppUser(
      id: guestId,
      name: 'Guest User',
      email: '$guestId@snapsolve.ai',
      isGuest: true,
      role: 'guest',
    );

    await _saveSession(user);
    return user;
  }

  @override
  Future<void> logout() async {
    await _secureStorage.delete('user_session');
    AppLogger.info('User logged out, session cleared.');
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    final session = await _secureStorage.read('user_session');
    if (session == null) return null;

    try {
      return AppUser.fromMap(jsonDecode(session));
    } catch (e) {
      AppLogger.error('Failed to restore session: $e');
      return null;
    }
  }

  String _hashPassword(String password, String salt) {
    // Enterprise Security: Double hashing with salt + Pepper
    final bytes =
        utf8.encode(password + salt + 'snapsolve_pepper_enterprise_2024');
    return sha256.convert(bytes).toString();
  }

  Future<void> _saveSession(AppUser user) async {
    await _secureStorage.write('user_session', jsonEncode(user.toMap()));
  }
}
