import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/analysis_provider.dart';
import '../providers/auth_provider.dart';
import '../repositories/category_repository.dart';
import 'analysis_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';
import '../widgets/category_card.dart';
import '../widgets/recent_analysis_card.dart';
import '../localization/localization_extension.dart';
import '../widgets/premium_core.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        if (!mounted) return;
        
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => AnalysisScreen(
              imageFile: kIsWeb ? image : io.File(image.path),
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${context.l10n.errorPickingImage}: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final analysisProvider = Provider.of<AnalysisProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    
    int crossAxisCount = screenWidth > 1200 ? 4 : (screenWidth > 800 ? 3 : 2);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1E),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 140,
            floating: true,
            pinned: true,
            backgroundColor: const Color(0xFF0F0F1E),
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                context.l10n.appName, 
                style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.5, color: Colors.white),
              ),
              centerTitle: false,
              titlePadding: const EdgeInsetsDirectional.only(start: 24, bottom: 20),
            ),
            actions: [
              _NavActionIcon(
                icon: Icons.history_rounded, 
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HistoryScreen())),
              ),
              _NavActionIcon(
                icon: Icons.settings_rounded, 
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen())),
              ),
              const SizedBox(width: 12),
            ],
          ),
          
          SliverToBoxAdapter(
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1000),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Animate(
                      child: Text(
                        '${context.l10n.hello}, ${authProvider.user?.name ?? context.l10n.guest} 👋',
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white),
                      ),
                    ).fadeIn().slideX(begin: -0.05, end: 0),
                    
                    const SizedBox(height: 12),
                    
                    Animate(
                      child: Text(
                        context.l10n.whatIssueSolving,
                        style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.5), fontWeight: FontWeight.w500),
                      ),
                    ).fadeIn(delay: const Duration(milliseconds: 100)),
                    
                    const SizedBox(height: 40),
                    
                    // Action Buttons (Ultra-Premium)
                    Row(
                      children: [
                        Expanded(
                          child: _HeroActionCard(
                            title: context.l10n.camera,
                            subtitle: context.l10n.captureNow,
                            icon: Icons.camera_alt_rounded,
                            color: const Color(0xFF6C63FF),
                            onTap: () => _pickImage(ImageSource.camera),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: _HeroActionCard(
                            title: context.l10n.gallery,
                            subtitle: context.l10n.uploadPhoto,
                            icon: Icons.photo_library_rounded,
                            color: const Color(0xFF00D2FF),
                            onTap: () => _pickImage(ImageSource.gallery),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 56),
                    
                    _SectionHeader(title: context.l10n.quickCategories, delay: const Duration(milliseconds: 200)),
                    const SizedBox(height: 24),
                    
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: CategoryRepository.categories.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: 20,
                        crossAxisSpacing: 20,
                        childAspectRatio: 1.0,
                      ),
                      itemBuilder: (context, index) {
                        return RepaintBoundary(
                          child: CategoryCard(category: CategoryRepository.categories[index]),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 56),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _SectionHeader(title: context.l10n.recentAnalyses, delay: const Duration(milliseconds: 300)),
                        TextButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HistoryScreen())),
                          child: Text(context.l10n.viewAll, style: const TextStyle(color: Color(0xFF6C63FF), fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    if (analysisProvider.history.isEmpty)
                      _buildEmptyState()
                    else
                      Animate(
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: analysisProvider.history.take(5).length,
                          separatorBuilder: (context, index) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            return RecentAnalysisCard(result: analysisProvider.history[index]);
                          },
                        ),
                      ).fadeIn(delay: const Duration(milliseconds: 400)),
                    
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Animate(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 80),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.02),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.auto_awesome_mosaic_rounded, size: 64, color: Colors.white.withOpacity(0.1)),
              ),
              const SizedBox(height: 24),
              Text(
                context.l10n.noRecentAnalyses, 
                style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    ).fadeIn();
  }
}

class _HeroActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _HeroActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Animate(
      child: PremiumCard(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: 24),
              Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
              const SizedBox(height: 6),
              Text(
                subtitle, 
                style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.5), fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    ).fadeIn().scale(delay: const Duration(milliseconds: 150), begin: const Offset(0.95, 0.95));
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Duration delay;

  const _SectionHeader({required this.title, required this.delay});

  @override
  Widget build(BuildContext context) {
    return Animate(
      child: Text(
        title,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.5),
      ),
    ).fadeIn(delay: delay);
  }
}

class _NavActionIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _NavActionIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: IconButton(
        icon: Icon(icon, color: Colors.white.withOpacity(0.8), size: 24),
        onPressed: onTap,
      ),
    );
  }
}
