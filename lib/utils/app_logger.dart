import 'package:flutter/foundation.dart';

class AppLogger {
  static void info(String message) {
    if (kDebugMode) {
      print('ℹ️ [SnapSolve INFO]: $message');
    }
  }

  static void warning(String message) {
    if (kDebugMode) {
      print('⚠️ [SnapSolve WARNING]: $message');
    }
  }

  static void error(String message, {dynamic error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      print('❌ [SnapSolve ERROR]: $message');
      if (error != null) print('   Detail: $error');
      if (stackTrace != null) print('   StackTrace: \n$stackTrace');
    }
  }

  static void debug(String message, {dynamic data}) {
    if (kDebugMode) {
      print('🔍 [SnapSolve DEBUG]: $message');
      if (data != null) print('   Data: $data');
    }
  }
}
