import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/analysis_provider.dart';
import '../models/analysis_result.dart';
import '../utils/app_logger.dart';
import '../localization/localization_extension.dart';
import '../widgets/problem_description_input.dart';
import '../models/problem_context.dart';
import '../widgets/premium_core.dart';
import '../widgets/premium_snackbar.dart';
import '../widgets/smart_error_view.dart';
import '../widgets/premium_image_viewer.dart';

class AnalysisScreen extends StatefulWidget {
  final dynamic imageFile;
  final AnalysisResult? result;
  final String? category;

  const AnalysisScreen({super.key, this.imageFile, this.result, this.category});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _isInitialized = true;
      if (widget.result == null && widget.imageFile != null) {
        _startInitialAnalysis();
      }
    }
  }

  void _startInitialAnalysis([String? description]) {
    final language = Localizations.localeOf(context).languageCode;
    final problemContext = _createContext(language, description);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnalysisProvider>().analyzeImage(problemContext);
    });
  }

  ProblemContext _createContext(String language, [String? description]) {
    return ProblemContext(
      imageFile: widget.imageFile,
      userDescription: description,
      timestamp: DateTime.now(),
      language: language,
      deviceInfo: {
        'platform':
            kIsWeb ? 'web' : (io.Platform.isAndroid ? 'android' : 'ios'),
        'version': '1.0.0',
      },
    );
  }

  void _refineResult(String feedback) {
    final provider = context.read<AnalysisProvider>();
    final result = provider.currentResult ?? widget.result;
    if (result == null) return;

    final language = Localizations.localeOf(context).languageCode;
    provider.improveAnalysis(
      original: result,
      feedback: feedback,
      primaryImage: widget.imageFile ??
          (kIsWeb ? result.imageUrl : io.File(result.imageUrl)),
      language: language,
    );
  }

  void _openImageViewer(List<String> urls, int index) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        pageBuilder: (context, _, __) =>
            PremiumImageViewer(imageUrls: urls, initialIndex: index),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
              opacity: animation,
              child: ScaleTransition(scale: animation, child: child));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(l10n.aiAnalysis,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: () => _shareResult(context),
          ),
        ],
      ),
      body: Consumer<AnalysisProvider>(
        builder: (context, provider, child) {
          if (provider.isAnalyzing) {
            return _buildLoadingState(
                provider.loadingMessage, provider.retryCount);
          }

          if (provider.error != null) {
            return SmartAnalysisErrorView(
              exception: provider.error!,
              onRetry: () => _startInitialAnalysis(),
              onBack: () => Navigator.pop(context),
            );
          }

          final result = widget.result ?? provider.currentResult;
          if (result == null) {
            return _buildInitialInputState();
          }

          return _buildResultState(result, provider);
        },
      ),
    );
  }

  Widget _buildInitialInputState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildCompactPremiumPreviewCard(),
          const SizedBox(height: 32),
          _buildContextInputSection(),
        ],
      ),
    );
  }

  Widget _buildCompactPremiumPreviewCard() {
    final imageUrl = widget.imageFile is XFile
        ? (widget.imageFile as XFile).path
        : widget.imageFile.toString();
    return Hero(
      tag: 'preview',
      child: Container(
        height: 250,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFF6C63FF).withOpacity(0.1), blurRadius: 20)
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: kIsWeb
              ? Image.network(imageUrl, fit: BoxFit.cover)
              : Image.file(io.File(imageUrl), fit: BoxFit.cover),
        ),
      ),
    );
  }

  Widget _buildContextInputSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What happened?',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Add context to help the AI recover your app faster.',
            style:
                TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.5)),
          ),
          const SizedBox(height: 24),
          ProblemDescriptionInput(
            buttonText: 'Start AI Recovery',
            hintText:
                'e.g. "Only happens on WiFi" or "Login works on another phone"',
            onSubmitted: (val) => _startInitialAnalysis(val),
          ),
        ],
      ),
    );
  }

  void _shareResult(BuildContext context) {
    PremiumSnackbar.show(context,
        message: context.l10n.sharingFeature, isError: false);
  }

  Widget _buildLoadingState(String message, int retryCount) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PremiumShimmer(
              width: double.infinity, height: 250, borderRadius: 24),
          const SizedBox(height: 32),
          const PremiumShimmer(width: 150, height: 24),
          const SizedBox(height: 16),
          const PremiumShimmer(width: double.infinity, height: 100),
          const SizedBox(height: 48),
          Center(
            child: Column(
              children: [
                const SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                        color: Color(0xFF6C63FF), strokeWidth: 3)),
                const SizedBox(height: 24),
                Text(context.translateKey(message),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600)),
                if (retryCount > 0)
                  Text('Automatic Retry #$retryCount...',
                      style: const TextStyle(
                          color: Colors.orangeAccent, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultState(AnalysisResult result, AnalysisProvider provider) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPremiumVerificationHeader(result),
          const SizedBox(height: 24),

          _buildCompactPremiumPreview(result),

          const SizedBox(height: 32),

          // Refinement Section
          _ExpandableRefinementPanel(onSubmitted: _refineResult),

          const SizedBox(height: 32),

          // 1. Diagnosis
          _ResultInfoSection(
            title: 'Diagnosis',
            content: result.issue,
            icon: Icons.auto_awesome_rounded,
            color: Colors.blueAccent,
            delay: const Duration(milliseconds: 100),
          ),

          const SizedBox(height: 24),

          // 2. Meaning
          _ResultInfoSection(
            title: 'What it means',
            content: result.meaning,
            icon: Icons.info_outline_rounded,
            color: Colors.purpleAccent,
            delay: const Duration(milliseconds: 200),
          ),

          const SizedBox(height: 24),

          // 3. Root Cause
          _ResultInfoSection(
            title: 'Technical Reason',
            content: result.reason,
            icon: Icons.psychology_outlined,
            color: Colors.greenAccent,
            delay: const Duration(milliseconds: 300),
          ),

          const SizedBox(height: 24),

          // 4. Recovery Steps
          _StepsSection(
              steps: result.steps, delay: const Duration(milliseconds: 400)),

          const SizedBox(height: 24),

          // 5. Warning
          _WarningSection(
              content: result.whatNotToDo,
              delay: const Duration(milliseconds: 500)),

          const SizedBox(height: 60),
        ],
      ),
    );
  }

  Widget _buildPremiumVerificationHeader(AnalysisResult result) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.greenAccent.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.greenAccent.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified_user_rounded,
              color: Colors.greenAccent, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Expert Recovery Mode Active (${(result.confidence ?? 0.8 * 100).toInt()}% Reliability)',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 13),
                ),
                Text(
                  'Verified by SnapSolve Senior Engineering Intelligence',
                  style: TextStyle(
                      fontSize: 10, color: Colors.white.withOpacity(0.5)),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: -0.1, end: 0);
  }

  Widget _buildCompactPremiumPreview(AnalysisResult result) {
    return Center(
      child: InkWell(
        onTap: () => _openImageViewer([result.imageUrl], 0),
        borderRadius: BorderRadius.circular(24),
        child: Hero(
          tag: result.imageUrl,
          child: Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(24)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: kIsWeb
                        ? Image.network(result.imageUrl, fit: BoxFit.cover)
                        : Image.file(io.File(result.imageUrl),
                            fit: BoxFit.cover),
                  ),
                  Positioned.fill(
                      child: Container(
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.4)
                      ])))),
                  const Center(
                      child: Icon(Icons.zoom_in_rounded,
                          color: Colors.white, size: 40)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultInfoSection extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;
  final Color color;
  final Duration delay;

  const _ResultInfoSection(
      {required this.title,
      required this.content,
      required this.icon,
      required this.color,
      required this.delay});

  @override
  Widget build(BuildContext context) {
    return Animate(
      child: PremiumCard(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 24),
                  const SizedBox(width: 14),
                  Text(title,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: color)),
                ],
              ),
              const SizedBox(height: 18),
              Text(content,
                  style: TextStyle(
                      fontSize: 15,
                      color: Colors.white.withOpacity(0.9),
                      height: 1.7)),
            ],
          ),
        ),
      ),
    ).fadeIn(delay: delay);
  }
}

class _StepsSection extends StatelessWidget {
  final List<String> steps;
  final Duration delay;
  const _StepsSection({required this.steps, required this.delay});

  @override
  Widget build(BuildContext context) {
    return Animate(
      child: PremiumCard(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.auto_fix_high_rounded,
                      color: Colors.greenAccent, size: 24),
                  const SizedBox(width: 14),
                  Text('Step-by-Step Recovery',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.greenAccent)),
                ],
              ),
              const SizedBox(height: 28),
              ...steps.asMap().entries.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: Colors.greenAccent.withOpacity(0.1),
                              shape: BoxShape.circle),
                          child: Text('${e.key + 1}',
                              style: const TextStyle(
                                  color: Colors.greenAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                            child: Text(e.value,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    height: 1.6))),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    ).fadeIn(delay: delay);
  }
}

class _WarningSection extends StatelessWidget {
  final String? content;
  final Duration delay;
  const _WarningSection({required this.content, required this.delay});

  @override
  Widget build(BuildContext context) {
    if (content == null || content!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Animate(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.orangeAccent.withOpacity(0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.orangeAccent.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.warning_amber_rounded,
                    color: Colors.orangeAccent, size: 20),
                SizedBox(width: 12),
                const Text('CRITICAL PRECAUTIONS',
                    style: TextStyle(
                        color: Colors.orangeAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        letterSpacing: 0.5)),
              ],
            ),
            const SizedBox(height: 12),
            Text(content!,
                style: const TextStyle(
                    color: Colors.white70, fontSize: 14, height: 1.6)),
          ],
        ),
      ),
    ).fadeIn(delay: delay);
  }
}

class _ExpandableRefinementPanel extends StatefulWidget {
  final Function(String) onSubmitted;

  const _ExpandableRefinementPanel({required this.onSubmitted});

  @override
  State<_ExpandableRefinementPanel> createState() =>
      _ExpandableRefinementPanelState();
}

class _ExpandableRefinementPanelState
    extends State<_ExpandableRefinementPanel> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(28),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Need a more accurate fix?',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Add extra details to improve AI troubleshooting accuracy.',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        if (!_isExpanded) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.touch_app_rounded,
                                  color: Colors.blueAccent, size: 14),
                              const SizedBox(width: 6),
                              Expanded(
                                child: const Text(
                                  'Tap to explain what happened after trying the fixes',
                                  style: TextStyle(
                                      color: Colors.blueAccent,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          )
                              .animate(
                                  onPlay: (controller) =>
                                      controller.repeat(reverse: true))
                              .fade(
                                  begin: 0.6,
                                  end: 1.0,
                                  duration: const Duration(milliseconds: 1000)),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.keyboard_arrow_down_rounded,
                          color: Colors.white, size: 24),
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: _isExpanded
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: ProblemDescriptionInput(
                      buttonText: 'Refine Recovery Plan',
                      hintText:
                          'Describe exactly what happened after you tried the fixes...',
                      onSubmitted: widget.onSubmitted,
                    ),
                  )
                : const SizedBox(width: double.infinity, height: 0),
          ),
        ],
      ),
    );
  }
}
