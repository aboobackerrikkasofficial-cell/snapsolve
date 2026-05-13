class AppTranslations {
  static Map<String, Map<String, String>> translations = {
    'en': {
      'welcome': 'Welcome to SnapSolve',
      'upload': 'Upload Screenshot',
      'analyze': 'AI Analysis',
      'history': 'Recent Analyses',
      'settings': 'Settings',
    },
    'ml': {
      'welcome': 'SnapSolve-ലേക്ക് സ്വാഗതം',
      'upload': 'സ്ക്രീൻഷോട്ട് അപ്‌ലോഡ് ചെയ്യുക',
      'analyze': 'AI വിശകലനം',
      'history': 'സമീപകാല വിശകലനങ്ങൾ',
      'settings': 'ക്രമീകരണങ്ങൾ',
    },
  };

  static String get(String key, String lang) {
    return translations[lang]?[key] ?? key;
  }
}
