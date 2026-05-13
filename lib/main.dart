import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'theme/app_theme.dart';
import 'providers/theme_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/analysis_provider.dart';
import 'providers/locale_provider.dart';
import 'services/api_service.dart';
import 'services/storage_service.dart';
import 'screens/splash_screen.dart';

import 'repositories/auth_repository.dart';

import 'services/database_initializer.dart';
import 'utils/app_error_handler.dart';
import 'services/secure_storage_service.dart';


void main() async {
  // 1. Initialize Global Error Handling
  AppErrorHandler.init();
  
  // 2. Ensure Flutter is ready
  WidgetsFlutterBinding.ensureInitialized();

  // 3. Initialize Cross-Platform Database
  await DatabaseInitializer.initialize();
  
  // 4. Initialize Storage Services
  final storageService = StorageService();
  await storageService.init();

  final secureStorage = SecureStorageService();
  await secureStorage.init();
  
  // 5. Initialize API and Repositories
  final apiService = ApiService();
  final authRepository = DatabaseAuthRepository(secureStorage);

  runApp(


    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(authRepository)),
        ChangeNotifierProvider(create: (_) => ThemeProvider(storageService)),
        ChangeNotifierProvider(create: (_) => AnalysisProvider(apiService, storageService)),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],

      child: const SnapSolveApp(),
    ),
  );
}

class SnapSolveApp extends StatelessWidget {
  const SnapSolveApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    
    return MaterialApp(
      title: 'SnapSolve',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      locale: localeProvider.locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('ml'),
        Locale('hi'),
        Locale('ta'),
      ],
      home: const SplashScreen(),
    );
  }
}
