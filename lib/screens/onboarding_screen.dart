import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'auth/login_screen.dart';
import '../localization/localization_extension.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  List<OnboardingData> _getPages(BuildContext context) => [
    OnboardingData(
      title: context.l10n.onboardingTitle1,
      description: context.l10n.onboardingDesc1,
      icon: Icons.upload_file_rounded,
      color: const Color(0xFF6C63FF),
    ),
    OnboardingData(
      title: context.l10n.onboardingTitle2,
      description: context.l10n.onboardingDesc2,
      icon: Icons.psychology_rounded,
      color: const Color(0xFF00D2FF),
    ),
    OnboardingData(
      title: context.l10n.onboardingTitle3,
      description: context.l10n.onboardingDesc3,
      icon: Icons.auto_fix_high_rounded,
      color: const Color(0xFF00C853),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final pages = _getPages(context);
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: pages.length,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemBuilder: (context, index) {
              return OnboardingPage(data: pages[index]);
            },
          ),
          
          PositionedDirectional(
            top: 60,
            end: 20,
            child: TextButton(
              onPressed: () => _finishOnboarding(),
              child: Text(context.l10n.skip, style: const TextStyle(color: Colors.grey)),
            ),
          ),
          
          PositionedDirectional(
            bottom: 60,
            start: 20,
            end: 20,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    pages.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsetsDirectional.only(end: 8),
                      height: 8,
                      width: _currentPage == index ? 24 : 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index ? const Color(0xFF6C63FF) : Colors.grey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_currentPage < pages.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        _finishOnboarding();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(
                      _currentPage == pages.length - 1 ? context.l10n.getStarted : context.l10n.continueText,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _finishOnboarding() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }
}

class OnboardingData {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingData({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

class OnboardingPage extends StatelessWidget {
  final OnboardingData data;

  const OnboardingPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: data.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(data.icon, size: 100, color: data.color),
          ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
          
          const SizedBox(height: 60),
          
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ).animate().fadeIn(delay: 200.ms).moveY(begin: 20, end: 0),
          
          const SizedBox(height: 20),
          
          Text(
            data.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ).animate().fadeIn(delay: 400.ms).moveY(begin: 20, end: 0),
        ],
      ),
    );
  }
}
