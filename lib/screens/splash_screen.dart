import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../services/storage_service.dart';
import '../providers/analysis_provider.dart';
import 'onboarding_screen.dart';
import 'home_screen.dart';
import 'auth/login_screen.dart';
import '../localization/localization_extension.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  void _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    final analysisProvider =
        Provider.of<AnalysisProvider>(context, listen: false);
    final storage = Provider.of<AnalysisProvider>(context,
        listen: false); // Just to ensure context

    // In a real app, you'd check storage via a dedicated service or provider
    // For now, let's assume onboarding logic

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const OnboardingScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF12121A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_rounded,
                size: 80,
                color: Color(0xFF6C63FF),
              ),
            )
                .animate()
                .scale(duration: 1.seconds, curve: Curves.elasticOut)
                .fadeIn(duration: 800.ms),
            const SizedBox(height: 24),
            Text(
              context.l10n.appName,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
              ),
            )
                .animate()
                .fadeIn(delay: 500.ms, duration: 800.ms)
                .moveY(begin: 20, end: 0, curve: Curves.easeOutQuad),
            const SizedBox(height: 8),
            Text(
              context.l10n.aiPoweredSolutions,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.5),
              ),
            ).animate().fadeIn(delay: 800.ms, duration: 800.ms),
          ],
        ),
      ),
    );
  }
}
