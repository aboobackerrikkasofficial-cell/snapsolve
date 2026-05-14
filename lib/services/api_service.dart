import 'dart:io' as io;
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import '../models/analysis_result.dart';
import '../models/analysis_exception.dart';
import '../utils/app_logger.dart';
import '../ai/providers/gemini_provider.dart';
import '../ai/models/ai_response.dart';
import '../models/problem_context.dart';
import '../config/security_config.dart';
import '../utils/security_utils.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class ApiService {
  late final GeminiProvider _geminiProvider;
  final _uuid = const Uuid();

  ApiService() {
    _initializeProvider();
  }

  void _initializeProvider() {
    AppLogger.info('Initializing ApiService (Gemini-Only Architecture)...');
    _geminiProvider = GeminiProvider(apiKey: SecurityConfig.geminiApiKey);

    if (!SecurityConfig.validate()) {
      AppLogger.warning(
          'ApiService initialized with invalid configuration. Analysis will likely fail.');
    }
  }

  Future<AnalysisResult> analyzeScreenshot({
    required ProblemContext context,
    Function(String)? onProgress,
  }) async {
    final requestId = _uuid.v4();

    try {
      if (!SecurityConfig.validate()) {
        throw AnalysisException(
          message:
              'Gemini API Key is missing or invalid. Please check your --dart-define configuration.',
          reason: AnalysisFailureReason.invalidApiKey,
        );
      }

      if (!SecurityUtils.checkRateLimit('global',
          SecurityConfig.maxRequestsPerMinute, const Duration(minutes: 1))) {
        throw AnalysisException(
            message: 'Rate limit exceeded.',
            reason: AnalysisFailureReason.providerQuotaExceeded);
      }

      onProgress?.call('readingScreenshot');
      Uint8List imageBytes = await _getImageBytes(context.imageFile);

      onProgress?.call('optimizingScreenshot');
      imageBytes = await _optimizeImage(imageBytes);

      final prompt = _buildExpertSystemPrompt(context);

      onProgress?.call('analyzingWithAI');

      // Implement timeout to prevent hanging on network issues
      final AiResponse response = await _geminiProvider
          .analyzeScreenshot(
            imageBytes: imageBytes,
            category: context.category,
            language: context.language,
            prompt: prompt,
          )
          .timeout(
            const Duration(seconds: 45),
            onTimeout: () => throw TimeoutException(
                'Gemini analysis timed out after 45 seconds.'),
          );

      AppLogger.info('Analysis Completed Successfully [ID: $requestId]');
      return _mapToAnalysisResult(
          requestId, response, context.imageFile, context.category);
    } on AnalysisException {
      rethrow;
    } on TimeoutException catch (e, stack) {
      AppLogger.error('Analysis Timeout', error: e, stackTrace: stack);
      throw AnalysisException(
        message: 'Request timed out after 45 seconds.',
        reason: AnalysisFailureReason.providerTimeout,
        originalError: e,
        stackTrace: stack,
        debugStage: 'ApiService.timeout',
      );
    } on GenerativeAIException catch (e, stack) {
      AppLogger.error('Gemini SDK Exception', error: e, stackTrace: stack);

      AnalysisFailureReason reason = AnalysisFailureReason.unknown;
      if (e.message.contains('API key'))
        reason = AnalysisFailureReason.invalidApiKey;
      if (e.message.contains('quota') || e.message.contains('429'))
        reason = AnalysisFailureReason.providerQuotaExceeded;
      if (e.message.contains('safety'))
        reason = AnalysisFailureReason.safetyFilterBlocked;

      throw AnalysisException(
        message: 'Gemini AI Error: ${e.message}',
        reason: reason,
        originalError: e,
        stackTrace: stack,
        debugStage: 'ApiService.GenerativeAIException',
      );
    } catch (e, stack) {
      AppLogger.error('Analysis Pipeline Error', error: e, stackTrace: stack);
      throw AnalysisException(
        message: 'Analysis failed: ${e.toString()}',
        reason: AnalysisFailureReason.unknown,
        originalError: e,
        stackTrace: stack,
        debugStage: 'ApiService.globalCatch',
      );
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

      final prompt =
          _buildRefinementPrompt(originalResult, userFeedback, language);

      onProgress?.call('analyzingWithAI');
      final AiResponse response = await _geminiProvider.analyzeScreenshot(
        imageBytes: imageBytes,
        category: originalResult.category,
        language: language,
        prompt: prompt,
      );

      return _mapToAnalysisResult(
          _uuid.v4(), response, imageFile, originalResult.category,
          parentId: originalResult.id);
    } catch (e, stack) {
      AppLogger.error('Refinement Pipeline Failure',
          error: e, stackTrace: stack);
      rethrow;
    }
  }

  String _buildRefinementPrompt(
      AnalysisResult original, String feedback, String language) {
    // Aggressively shortened refinement prompt for blazing fast response
    return '''
Update diagnosis based on user feedback: "$feedback"
Prev Title: ${original.title}
Lang: $language
Return ONLY JSON:
{"title":"short diagnosis","issue":"brief explanation","reason":"root cause","steps":["fix step 1","step 2"]}
''';
  }

  String _buildExpertSystemPrompt(ProblemContext context) {
    // Aggressively shortened prompt for minimum token overhead and maximum speed
    return '''
Analyze this screenshot and identify the technical failure.
Context: ${context.userDescription ?? 'None'}
Lang: ${context.language}
Return ONLY JSON with these exact keys:
{"title":"short diagnosis","issue":"brief technical explanation","reason":"root cause","steps":["fix step 1","step 2"]}
''';
  }

  AnalysisResult _mapToAnalysisResult(
      String id, AiResponse res, dynamic imageFile, String? category,
      {String? parentId}) {
    return AnalysisResult(
      id: id,
      title: res.title,
      issue: res.issue,
      meaning: res.meaning,
      reason: res.reason,
      rootCause: res.rootCause ?? 'Inferred from visual patterns.',
      mostLikelyFix: res.mostLikelyFix ??
          (res.steps.isNotEmpty ? res.steps.first : 'Restart the app.'),
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
    );
  }

  Future<Uint8List> _optimizeImage(Uint8List bytes) async {
    try {
      // Run heavy image processing in a separate isolate to prevent UI freezing
      return await compute(_processImageInIsolate, bytes);
    } catch (e) {
      AppLogger.warning('Image optimization failed, using original bytes.');
      return bytes;
    }
  }

  // Must be a top-level or static function to run in an isolate
  static Uint8List _processImageInIsolate(Uint8List bytes) {
    final image = img.decodeImage(bytes);
    if (image == null) return bytes;

    img.Image optimized = image;
    // Aggressively resize to 768 max dimension to speed up AI payload upload
    if (image.width > 768 || image.height > 768) {
      optimized = img.copyResize(
        image,
        width: image.width > image.height ? 768 : null,
        height: image.height > image.width ? 768 : null,
        interpolation: img.Interpolation.linear,
      );
    }

    // Compress heavily while maintaining OCR readability
    return Uint8List.fromList(img.encodeJpg(optimized, quality: 75));
  }

  Future<Uint8List> _getImageBytes(dynamic image) async {
    if (image is Uint8List) return image;
    if (image is XFile) return await image.readAsBytes();
    if (image is io.File) return await image.readAsBytes();

    if (image is String && image.isNotEmpty) {
      if (kIsWeb || image.startsWith('http')) {
        // Handle network images or web blob URLs
        final response = await _geminiProvider.fetchNetworkImage(image);
        return response;
      }
      return await io.File(image).readAsBytes();
    }

    throw 'Invalid image source: ${image.runtimeType}. Expected Uint8List, XFile, File, or valid URL string.';
  }

  String _getImagePath(dynamic image) {
    if (image is XFile) return image.path;
    if (image is io.File) return image.path;
    return 'memory_image_${DateTime.now().millisecondsSinceEpoch}';
  }
}
