import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'SnapSolve';
  static const String appVersion = '1.0.0';

  // API Endpoints
  static const String baseUrl = 'https://api.snapsolve.ai/v1';
  static const String analyzeEndpoint = '/analyze-screenshot';

  // Storage Keys
  static const String keyHistory = 'analysis_history';
  static const String keyDarkMode = 'is_dark_mode';
  static const String keyLanguage = 'app_language';
  static const String keyOnboardingComplete = 'onboarding_complete';
  static const String keyUserAuth = 'user_auth_token';

  // Performance & UX Tuning (Production Grade)
  static const Duration fastAnimation = Duration(milliseconds: 200);
  static const Duration normalAnimation = Duration(milliseconds: 350);
  static const Duration slowAnimation = Duration(milliseconds: 500);

  static const Curve defaultCurve = Curves.easeOutCubic;
  static const Curve snappyCurve = Curves.easeOutQuart;

  // UI Constants
  static const double borderRadius = 24.0;
  static const double padding = 20.0;
  static const Color primaryPurple = Color(0xFF6C63FF);
  static const Color darkBg = Color(0xFF0F0F1E);
}
