import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../utils/app_logger.dart';
import 'package:flutter/foundation.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;
  static bool _isInitializing = false;

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<Database> get database async {
    // Web doesn't use sqflite. This should be caught by repository logic.
    if (kIsWeb) {
      throw UnsupportedError('sqflite is not supported on Web. Use alternative storage.');
    }

    if (_database != null) return _database!;
    
    if (_isInitializing) {
      // Wait for existing initialization to finish
      while (_isInitializing) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      return _database!;
    }

    _isInitializing = true;
    try {
      _database = await _initDatabase();
    } finally {
      _isInitializing = false;
    }
    
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'snapsolve_auth.db');

    AppLogger.info('Opening database at $path');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    AppLogger.info('Creating database tables...');
    
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        hashed_password TEXT NOT NULL,
        role TEXT NOT NULL DEFAULT 'user',
        is_guest INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        last_login TEXT,
        verified INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('CREATE INDEX idx_users_email ON users(email)');
    
    AppLogger.info('Database setup complete.');
  }
}
