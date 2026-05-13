import 'dart:io' as io;

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import '../models/analysis_result.dart';
import '../models/analysis_exception.dart';
import '../utils/app_logger.dart';
import '../ai/consensus_engine.dart';
import '../ai/providers/gemini_provider.dart';
import '../ai/providers/groq_provider.dart';
import '../ai/providers/openrouter_provider.dart';
import '../ai/models/ai_response.dart';
import '../models/problem_context.dart';
import '../config/security_config.dart';
import '../utils/security_utils.dart';

class ApiService {
  late final ConsensusEngine _consensusEngine;

  ApiService() {
    _validateConfig();
    
    _consensusEngine = ConsensusEngine([
      GeminiProvider(apiKey: SecurityConfig.geminiApiKey),
      GroqProvider(apiKey: SecurityConfig.groqApiKey),
      OpenRouterProvider(apiKey: SecurityConfig.openRouterApiKey),
    ]);
  }

  void _validateConfig() {
    AppLogger.info('Validating API Configuration...');
    if (SecurityConfig.geminiApiKey.isEmpty && !kReleaseMode) {
      AppLogger.warning('CRITICAL: Gemini API Key is missing.');
    }
  }

  Future<AnalysisResult> analyzeScreenshot({
    required ProblemContext context,
    Function(String)? onProgress,
  }) async {
    final requestId = const Uuid().v4();

    try {
      if (!SecurityUtils.checkRateLimit('global', 15, const Duration(minutes: 1))) {
        throw AnalysisException(message: 'Too many requests.', reason: AnalysisFailureReason.providerQuotaExceeded);
      }

      onProgress?.call('readingScreenshot');
      Uint8List imageBytes = await _getImageBytes(context.imageFile);
      
      onProgress?.call('optimizingScreenshot');
      imageBytes = await _optimizeImage(imageBytes);

      // 1. ADVANCED LOCAL REASONING ENGINE (Knowledge-Driven)
      final localReasoning = _runExpertLocalReasoning(context.userDescription);
      
      // 2. EXPERT SYSTEM PROMPT (Senior Mobile Troubleshooting Engineer)
      final prompt = _buildExpertSystemPrompt(context, localReasoning);
      
      onProgress?.call('analyzingWithAI');
      final AiResponse response = await _consensusEngine.analyzeWithConsensus(
        imageBytes: imageBytes,
        category: context.category,
        language: context.language,
        prompt: prompt,
      );

      return _mapToAnalysisResult(requestId, response, context.imageFile, context.category);
    } catch (e, stack) {
      AppLogger.error('Analysis Pipeline Error', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<AnalysisResult> improveAnalysis({
    required AnalysisResult originalResult,
    required String userFeedback,
    required dynamic imageFile,
    required String language,
    Function(String)? onProgress,
  }) async {
    try {
      onProgress?.call('readingScreenshot');
      Uint8List imageBytes = await _getImageBytes(imageFile);
      imageBytes = await _optimizeImage(imageBytes);

      final prompt = _buildRefinementPrompt(originalResult, userFeedback, language);

      onProgress?.call('analyzingWithAI');
      final AiResponse response = await _consensusEngine.analyzeWithConsensus(
        imageBytes: imageBytes,
        category: originalResult.category,
        language: language,
        prompt: prompt,
      );

      return _mapToAnalysisResult(const Uuid().v4(), response, imageFile, originalResult.category, parentId: originalResult.id);
    } catch (e, stack) {
      AppLogger.error('Refinement Pipeline Failure', error: e, stackTrace: stack);
      rethrow;
    }
  }

  String _buildExpertSystemPrompt(ProblemContext context, Map<String, dynamic> local) {
    return '''
      ACT AS: Senior Lead Mobile Troubleshooting Engineer.
      EXPERTISE: Banking systems, Authentication infrastructure, Payment processing (UPI/Razorpay/Stripe), and Android/iOS app internals.
      
      TASK: Perform a high-fidelity visual and technical diagnosis of the provided screenshot.
      
      STRICT ARCHITECTURAL RULE:
      - The USER'S screenshot problem is the ONLY primary context.
      - NEVER mention internal AI timeouts, provider states, or node failures.
      - If you are unsure, provide the most likely technical hypothesis based on UI patterns.

      LOCAL CONTEXT (Heuristic Analysis):
      - Detected Domain: ${local['domain']}
      - Inferred State: ${local['inferred_state']}
      - Knowledge Base Clues: ${local['clues'].join(', ')}

      DIAGNOSTIC GUIDELINES:
      - Analyze UI structure, warning tone, button semantics, and app category.
      - BANKING: Look for "server unavailable", "authorization failure", or "transaction rejected". Infer gateway outages or maintenance.
      - SOCIAL: Look for "feedback_required" or "challenge_required". Infer device bans or IP flags.
      - RECOVERY: Prioritize "Wait and Retry" for server issues. Do NOT suggest reinstallation for server-side outages.

      OUTPUT FORMAT (STRICT JSON ONLY):
      {
        "title": "Clear Problem Detected Title",
        "issue": "What’s Actually Happening (Detailed technical explanation)",
        "meaning": "Technical impact on the user's workflow.",
        "reason": "Most Likely Cause (Inference)",
        "rootCause": "Expert Technical Root Cause",
        "hypotheses": [
          {"description": "Most Likely (Inferred)", "probability": 0.86},
          {"description": "Possible Cause", "probability": 0.68},
          {"description": "Alternative Theory", "probability": 0.34}
        ],
        "mostLikelyFix": "Best Fix First (Highest Success Rate)",
        "steps": ["Step 1", "Step 2", "Step 3"],
        "alternativeFixes": ["Effective Fix B", "Advanced Fix C"],
        "whatNotToDo": "Critical Warnings (e.g., Do NOT spam attempts)",
        "actions": ["Primary Button Label"],
        "platform": "Detected OS/App Domain",
        "severity": "Low/Medium/High/Critical",
        "confidence": 0.90,
        "fixProbability": 0.88,
        "followUpQuestions": ["Clarifying question?"]
      }
    ''';
  }

  String _buildRefinementPrompt(AnalysisResult original, String feedback, String language) {
    return '''
      ACT AS: Senior Lead Troubleshooting Engineer.
      Refine diagnosis for "${original.title}" using feedback: "$feedback".
      Rule out previous hypotheses if contradicted. STRICT JSON ONLY.
    ''';
  }

  Map<String, dynamic> _runExpertLocalReasoning(String? description) {
    final List<String> clues = [];
    String domain = 'General App';
    String inferredState = 'Active Troubleshooting';
    
    if (description == null) return {'domain': domain, 'inferred_state': inferredState, 'clues': clues};
    final text = description.toLowerCase();
    
    // 1. App/Domain Detection
    if (text.contains('bank') || text.contains('pay') || text.contains('upi') || text.contains('money')) {
      domain = 'Banking & Payments';
      clues.add('Detected Fintech/Payment Gateway context');
    } else if (text.contains('insta') || text.contains('social') || text.contains('fb') || text.contains('post')) {
      domain = 'Social Media';
      clues.add('Detected Social Media session context');
    }
    
    // 2. Knowledge-Driven Mapping
    if (text.contains('server') && (text.contains('unavailable') || text.contains('down'))) {
      inferredState = 'Backend Service Interruption';
      clues.add('Mapped: "server unavailable" -> Payment Gateway Outage / Maintenance');
    }
    if (text.contains('login') || text.contains('password') || text.contains('access')) {
      inferredState = 'Authentication Challenge';
      clues.add('Mapped: Auth flow -> Possible Session Corruption or Device Ban');
    }
    
    return {
      'domain': domain,
      'inferred_state': inferredState,
      'clues': clues,
    };
  }

  AnalysisResult _mapToAnalysisResult(String id, AiResponse res, dynamic imageFile, String? category, {String? parentId}) {
    return AnalysisResult(
      id: id,
      title: res.title,
      issue: res.issue,
      meaning: res.meaning,
      reason: res.reason,
      rootCause: res.rootCause ?? 'Diagnostic Engine Inference',
      mostLikelyFix: res.mostLikelyFix ?? (res.steps.isNotEmpty ? res.steps.first : 'Retry after a brief cooldown.'),
      steps: res.steps,
      alternativeFixes: res.alternativeFixes ?? [],
      whatNotToDo: res.whatNotToDo ?? 'Proceed with caution.',
      actions: res.actions,
      imageUrl: _getImagePath(imageFile),
      timestamp: DateTime.now(),
      category: category,
      platform: res.platform,
      confidence: res.confidence,
      ocrText: res.ocrText,
      severity: res.severity,
      fixProbability: res.fixProbability,
      providers: [res.providerName],
      parentId: parentId,
      isRefined: parentId != null,
      followUpQuestions: res.followUpQuestions,
      hypotheses: res.hypotheses?.map((h) => AnalysisHypothesis(description: h.description, probability: h.probability)).toList(),
    );
  }

  Future<Uint8List> _optimizeImage(Uint8List bytes) async {
    try {
      final image = img.decodeImage(bytes);
      if (image == null) return bytes;
      img.Image optimized = image;
      if (image.width > 1200 || image.height > 1200) {
        optimized = img.copyResize(image, width: image.width > image.height ? 1200 : null, height: image.height > image.width ? 1200 : null);
      }
      return Uint8List.fromList(img.encodeJpg(optimized, quality: 85));
    } catch (e) {
      return bytes;
    }
  }

  Future<Uint8List> _getImageBytes(dynamic image) async {
    if (image is Uint8List) return image;
    if (image is XFile) return await image.readAsBytes();
    if (image is io.File) return await image.readAsBytes();
    throw 'Invalid image source';
  }

  String _getImagePath(dynamic image) {
    if (image is XFile) return image.path;
    if (image is io.File) return image.path;
    return '';
  }
}