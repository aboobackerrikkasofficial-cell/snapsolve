import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:google_generative_ai/google_generative_ai.dart';
import 'base_provider.dart';
import '../models/ai_response.dart';
import '../../utils/app_logger.dart';
import '../../utils/safe_json_parser.dart';

class GeminiProvider extends BaseAiProvider {
  final String apiKey;
  late final GenerativeModel _model;

  GeminiProvider({required this.apiKey}) {
    _model = GenerativeModel(
      // Using gemini-2.5-flash for blazing fast multimodal inference
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
      // Aggressively optimize GenerationConfig for speed & deterministic output
      generationConfig: GenerationConfig(
        temperature: 0.0,
        topK: 1,
        responseMimeType: 'application/json',
      ),
      // Safety settings to prevent over-filtering of technical content
      safetySettings: [
        SafetySetting(HarmCategory.harassment, HarmBlockThreshold.none),
        SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.none),
        SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.none),
        SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.none),
      ],
    );
  }

  @override
  String get name => 'Gemini AI';

  @override
  bool get isEnabled => apiKey.isNotEmpty;

  @override
  Future<AiResponse> analyzeScreenshot({
    required dynamic imageBytes,
    String? category,
    String language = 'en',
    required String prompt,
  }) async {
    if (apiKey.isEmpty) {
      throw Exception('Gemini API Key is not configured.');
    }

    try {
      AppLogger.info('Starting Gemini Analysis (Model: gemini-2.5-flash)...');
      AppLogger.debug('Payload Prepared', data: {
        'promptLength': prompt.length,
        'imageSize': (imageBytes as Uint8List).length,
      });

      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', imageBytes),
        ])
      ];

      final response = await _model.generateContent(content);

      if (response.text == null || response.text!.isEmpty) {
        AppLogger.error(
            'Gemini returned an empty response. This might be due to safety filters.');
        AppLogger.debug('Full Response Metadata',
            data: response.promptFeedback?.toString());
        throw Exception('Empty response from AI engine.');
      }

      AppLogger.info(
          'Gemini Response Received (${response.text!.length} chars)');
      AppLogger.debug('Raw Response Snippet',
          data: response.text!.substring(
              0, response.text!.length > 100 ? 100 : response.text!.length));
      return _parseResponse(response.text, category);
    } on GenerativeAIException catch (e) {
      AppLogger.error('Gemini SDK Error: ${e.message}');
      if (e.message.contains('not found') ||
          e.message.contains('unsupported')) {
        AppLogger.error(
            'CRITICAL: Model compatibility error detected. Ensure you are using a stable model and latest SDK.');
      }
      rethrow;
    } catch (e, stack) {
      AppLogger.error('Gemini Pipeline Failure', error: e, stackTrace: stack);
      rethrow;
    }
  }

  @override
  Future<AiResponse> analyzeMultiImages({
    required List<dynamic> images,
    String? category,
    String language = 'en',
    required String prompt,
  }) async {
    return analyzeScreenshot(
        imageBytes: images.first,
        category: category,
        language: language,
        prompt: prompt);
  }

  AiResponse _parseResponse(String? text, String? category) {
    final jsonMap = SafeJsonParser.parse(text ?? '{}');

    return AiResponse(
      providerName: name,
      title: SafeJsonParser.get(jsonMap, 'title', 'Expert Diagnosis'),
      issue: SafeJsonParser.get(jsonMap, 'issue',
          'A technical issue was detected in the screenshot.'),
      meaning: SafeJsonParser.get(
          jsonMap, 'meaning', 'The application is in an error state.'),
      reason: SafeJsonParser.get(
          jsonMap, 'reason', 'Root cause identified via visual patterns.'),
      rootCause:
          SafeJsonParser.get(jsonMap, 'rootCause', 'Inferred from UI state.'),
      mostLikelyFix: SafeJsonParser.get(
          jsonMap, 'mostLikelyFix', 'Try restarting the application.'),
      alternativeFixes: List<String>.from(jsonMap['alternativeFixes'] ?? []),
      whatNotToDo: SafeJsonParser.get(jsonMap, 'whatNotToDo',
          'Avoid repeated attempts without addressing the error.'),
      steps: List<String>.from(
          jsonMap['steps'] ?? ['Restart the app', 'Check internet connection']),
      actions: List<String>.from(jsonMap['actions'] ?? ['Retry']),
      platform: SafeJsonParser.get(jsonMap, 'platform', 'Universal'),
      confidence: SafeJsonParser.get(jsonMap, 'confidence', 0.8),
      severity: SafeJsonParser.get(jsonMap, 'severity', 'medium'),
      ocrText: SafeJsonParser.get(jsonMap, 'ocrText', null),
      category: category,
      fixProbability: SafeJsonParser.get(jsonMap, 'fixProbability', 0.5),
      timestamp: DateTime.now(),
      followUpQuestions: List<String>.from(jsonMap['followUpQuestions'] ?? []),
    );
  }

  Future<Uint8List> fetchNetworkImage(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
      throw 'Failed to load image: Status ${response.statusCode}';
    } catch (e) {
      throw 'Failed to fetch image: $e';
    }
  }
}
