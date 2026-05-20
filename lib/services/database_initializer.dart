import 'dart:io';
import 'package:flutter/foundation.dart';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../utils/app_logger.dart';

class DatabaseInitializer {
  static Future<void> initialize() async {
    try {
      AppLogger.info(
          'Initializing database for platform: ${kIsWeb ? 'Web' : Platform.operatingSystem}');

      if (kIsWeb) {
        // sqflite is not supported on Web.
        // We handle this in the repositories by using alternative storage.
        AppLogger.info(
            'Web platform detected. Skipping sqflite initialization.');
        return;
      }

      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        AppLogger.info('Desktop platform detected. Setting up FFI factory.');
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      } else {
        AppLogger.info(
            'Mobile platform detected. sqflite will use default factory.');
      }

      // Verification attempt (optional)
      // await getDatabasesPath();

      AppLogger.info('Database initialization successful.');
    } catch (e, stack) {
      AppLogger.error('Database initialization failed',
          error: e, stackTrace: stack);
      // We don't rethrow here to allow the app to start even if DB fails,
      // but we log it heavily. The app handles DB errors gracefully.
    }
  }
}
