import 'dart:convert';
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
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
    );
  }

  @override
  String get name => 'Gemini 1.5 Flash';

  @override
  bool get isEnabled => apiKey.isNotEmpty;

  @override
  Future<AiResponse> analyzeScreenshot({
    required dynamic imageBytes,
    String? category,
    String language = 'en',
    required String prompt,
  }) async {
    try {
      final List<Part> parts = [
        TextPart(prompt),
        DataPart('image/jpeg', imageBytes),
      ];

      final content = [Content.multi(parts)];
      final response = await _model.generateContent(content);
      return _parseResponse(response.text, category);
    } catch (e, stack) {
      AppLogger.error('Gemini Analysis Failed', error: e, stackTrace: stack);
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
    return analyzeScreenshot(imageBytes: images.first, category: category, language: language, prompt: prompt);
  }

  AiResponse _parseResponse(String? text, String? category) {
    if (text == null || text.isEmpty) throw 'Empty response from Gemini';
    
    final jsonMap = SafeJsonParser.parse(text);
    
    final List<AiHypothesis> hypotheses = [];
    if (jsonMap['hypotheses'] != null && jsonMap['hypotheses'] is List) {
      for (var h in jsonMap['hypotheses']) {
        hypotheses.add(AiHypothesis(
          description: SafeJsonParser.get(h, 'description', 'Possible Cause'),
          probability: (SafeJsonParser.get(h, 'probability', 0.5)).toDouble(),
        ));
      }
    }

    return AiResponse(
      providerName: name,
      title: SafeJsonParser.get(jsonMap, 'title', 'Expert Diagnosis'),
      issue: SafeJsonParser.get(jsonMap, 'issue', 'Analyzing...'),
      meaning: SafeJsonParser.get(jsonMap, 'meaning', 'Interpreting technical state.'),
      reason: SafeJsonParser.get(jsonMap, 'reason', 'Diagnosing root cause.'),
      rootCause: SafeJsonParser.get(jsonMap, 'rootCause', 'Inferred from UI patterns.'),
      mostLikelyFix: SafeJsonParser.get(jsonMap, 'mostLikelyFix', null),
      alternativeFixes: List<String>.from(jsonMap['alternativeFixes'] ?? []),
      whatNotToDo: SafeJsonParser.get(jsonMap, 'whatNotToDo', null),
      steps: List<String>.from(jsonMap['steps'] ?? []),
      actions: List<String>.from(jsonMap['actions'] ?? []),
      platform: SafeJsonParser.get(jsonMap, 'platform', 'Universal'),
      confidence: SafeJsonParser.get(jsonMap, 'confidence', 0.8),
      severity: SafeJsonParser.get(jsonMap, 'severity', 'medium'),
      ocrText: SafeJsonParser.get(jsonMap, 'ocrText', null),
      category: category,
      fixProbability: SafeJsonParser.get(jsonMap, 'fixProbability', 0.5),
      timestamp: DateTime.now(),
      followUpQuestions: List<String>.from(jsonMap['followUpQuestions'] ?? []),
      hypotheses: hypotheses,
    );
  }
}
