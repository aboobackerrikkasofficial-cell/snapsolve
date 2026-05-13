import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io' as io;
import '../models/app_category.dart';
import '../localization/localization_extension.dart';
import 'analysis_screen.dart';
import '../widgets/premium_snackbar.dart';


class CategoryDetailScreen extends StatelessWidget {
  final AppCategory category;

  const CategoryDetailScreen({super.key, required this.category});

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source);
      if (image != null) {
        if (!context.mounted) return;
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AnalysisScreen(
              imageFile: kIsWeb ? image : io.File(image.path),
              category: category.id,
            ),
          ),
        );
      }
    } catch (e) {
      PremiumSnackbar.show(context, message: '${context.l10n.errorPickingImage}: $e');
    }

  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final title = context.translateKey(category.titleKey);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      category.color,
                      category.color.withOpacity(0.6),
                    ],
                  ),
                ),
                child: Center(
                  child: Hero(
                    tag: 'category_icon_${category.id}',
                    child: Icon(
                      category.icon,
                      size: 80,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.categoryAnalysis(title),
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ).animate().fadeIn().moveY(begin: 20, end: 0),
                  
                  const SizedBox(height: 32),
                  
                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 64,
                    child: ElevatedButton.icon(
                      onPressed: () => _pickImage(context, ImageSource.gallery),
                      icon: const Icon(Icons.upload_file_rounded),
                      label: Text(l10n.startCategoryAnalysis(title)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: category.color,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 8,
                        shadowColor: category.color.withOpacity(0.4),
                      ),
                    ),
                  ).animate().fadeIn(delay: 200.ms).scale(),
                  
                  const SizedBox(height: 40),
                  
                  // Tips Section
                  _buildSectionHeader(l10n.categoryTips, Icons.lightbulb_outline_rounded),
                  const SizedBox(height: 16),
                  ...category.tipsKeys.map((key) => _buildTipCard(context.translateKey(key))),
                  
                  const SizedBox(height: 32),
                  
                  // Common Issues
                  _buildSectionHeader(l10n.commonIssues, Icons.report_problem_outlined),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: category.commonIssuesKeys.map((key) => _buildIssueChip(context.translateKey(key))).toList(),
                  ),
                  
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildTipCard(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: Colors.green, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 15))),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).moveX(begin: -20, end: 0);
  }

  Widget _buildIssueChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: category.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: category.color.withOpacity(0.2)),
      ),
      child: Text(
        text,
        style: TextStyle(color: category.color, fontWeight: FontWeight.bold, fontSize: 14),
      ),
    ).animate().fadeIn(delay: 500.ms).scale();
  }
}
