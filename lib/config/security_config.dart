import 'package:flutter/foundation.dart';

class SecurityConfig {
  /// The Gemini API Key injected via --dart-define=GEMINI_API_KEY=xxx
  static const String geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.snapsolve.ai/v1',
  );

  // Security Flags
  static const bool isProduction = kReleaseMode;
  static const bool enableSslPinning = isProduction;
  static const bool obfuscateLogs = isProduction;

  // Rate Limits
  static const int maxRequestsPerMinute = 15;
  static const int maxImageSizeMb = 4;

  /// Validates the API configuration and returns true if valid.
  static bool validate() {
    if (geminiApiKey.isEmpty) {
      return false;
    }

    if (geminiApiKey.length < 20) {
      return false;
    }

    return true;
  }
}
