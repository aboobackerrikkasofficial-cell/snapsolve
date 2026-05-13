import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/app_logger.dart';
import '../widgets/premium_snackbar.dart';

class AppErrorHandler {
  static void init() {
    // 1. Capture Flutter framework errors
    FlutterError.onError = (details) {
      AppLogger.error('Flutter Framework Error', error: details.exception, stackTrace: details.stack);
      // In production, we override the red screen
    };

    // 2. Capture async platform errors
    PlatformDispatcher.instance.onError = (error, stack) {
      AppLogger.error('Async Platform Error', error: error, stackTrace: stack);
      return true; // Error handled
    };

    // 3. Global Error Widget (The "Red Screen" override)
    ErrorWidget.builder = (details) {
      if (kDebugMode) {
        // In debug, we might want to see the error, but let's make it look better
        // return FlutterError.defaultErrorWidgetBuilder(details);
      }
      return GlobalErrorView(details: details);
    };
  }

  static String mapErrorToMessage(dynamic error) {
    final errorString = error.toString();
    final lowerError = errorString.toLowerCase();

    if (lowerError.contains('socketexception') || lowerError.contains('network_error')) {
      return 'Network connection unavailable. Please check your internet.';
    }
    if (lowerError.contains('databasefactory') || lowerError.contains('sqflite')) {
      return 'Local storage failed to initialize. Please restart the app.';
    }
    if (lowerError.contains('api key') || lowerError.contains('invalidapikey')) {
      return 'Security configuration error. Please contact support.';
    }
    if (lowerError.contains('quota') || lowerError.contains('rate limit')) {
      return 'AI servers are temporarily busy. Please try again in a moment.';
    }
    if (lowerError.contains('missingpluginexception')) {
      return 'A required system component is missing. Please refresh.';
    }
    if (lowerError.contains('bad state')) {
      return 'Something went wrong while preparing the app.';
    }

    // Default friendly message
    return 'Something unexpected happened. We are looking into it.';
  }

  static void showPremiumError(BuildContext context, dynamic error) {
    final message = mapErrorToMessage(error);
    PremiumSnackbar.show(context, message: message, isError: true);
  }
}

class GlobalErrorView extends StatelessWidget {
  final FlutterErrorDetails details;

  const GlobalErrorView({super.key, required this.details});

  @override
  Widget build(BuildContext context) {
    final message = AppErrorHandler.mapErrorToMessage(details.exception);

    return Material(
      color: const Color(0xFF0F0F1E),
      child: Stack(
        children: [
          // Background Glow
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.05),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.1),
                    blurRadius: 100,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),
          
          Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Premium Error Icon
                  Animate(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.red.withOpacity(0.2)),
                      ),
                      child: const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.redAccent,
                        size: 48,
                      ),
                    ),
                  ).scale(duration: const Duration(milliseconds: 400), curve: Curves.easeOutBack).shake(delay: const Duration(milliseconds: 400)),
                  
                  const SizedBox(height: 40),
                  
                  const Text(
                    'App Encountered a Problem',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // Compact Recovery Button
                  SizedBox(
                    width: 200,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        // Logic to restart app or reload
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent.withOpacity(0.1),
                        foregroundColor: Colors.redAccent,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: BorderSide(color: Colors.redAccent.withOpacity(0.3)),
                        ),
                      ),
                      child: const Text('Restart App', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
