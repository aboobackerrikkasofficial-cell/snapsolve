class SecurityConfig {
  // Use String.fromEnvironment to inject keys during build
  // Example: flutter run --dart-define=GEMINI_API_KEY=your_key
  
  static const String geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );
  
  static const String groqApiKey = String.fromEnvironment(
    'GROQ_API_KEY',
    defaultValue: '',
  );
  
  static const String openRouterApiKey = String.fromEnvironment(
    'OPENROUTER_API_KEY',
    defaultValue: '',
  );

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.snapsolve.ai/v1',
  );

  // Security Flags
  static const bool isProduction = bool.fromEnvironment('dart.vm.product');
  static const bool enableSslPinning = isProduction;
  static const bool obfuscateLogs = isProduction;

  // Rate Limits
  static const int maxRequestsPerMinute = 10;
  static const int maxImageSizeMb = 5;
}
