import 'dart:convert';
import 'package:dio/dio.dart';
import 'base_provider.dart';
import '../models/ai_response.dart';
import '../../utils/app_logger.dart';
import '../../utils/safe_json_parser.dart';

class GroqProvider extends BaseAiProvider {
  final String apiKey;
  final Dio _dio = Dio();

  GroqProvider({required this.apiKey});

  @override
  String get name => 'Groq (Llama 3 Vision)';

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
      final base64Image = base64Encode(imageBytes);

      final response = await _dio.post(
        'https://api.groq.com/openai/v1/chat/completions',
        options: Options(headers: {'Authorization': 'Bearer $apiKey'}),
        data: {
          'model': 'llama-3.2-11b-vision-preview',
          'messages': [
            {
              'role': 'user',
              'content': [
                {'type': 'text', 'text': prompt},
                {
                  'type': 'image_url',
                  'image_url': {'url': 'data:image/jpeg;base64,$base64Image'}
                }
              ]
            }
          ],
          'response_format': {'type': 'json_object'}
        },
      );

      final content = response.data['choices'][0]['message']['content'];
      return _parseResponse(content, category);
    } catch (e, stack) {
      AppLogger.error('Groq Analysis Failed', error: e, stackTrace: stack);
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
    // Current Llama 3 Vision implementation via Groq API focuses on single image.
    // Fallback to first image for now.
    return analyzeScreenshot(imageBytes: images.first, category: category, language: language, prompt: prompt);
  }

  AiResponse _parseResponse(String? text, String? category) {
    if (text == null || text.isEmpty) throw 'Empty response from Groq';
    final jsonMap = SafeJsonParser.parse(text);

    return AiResponse(
      providerName: name,
      title: SafeJsonParser.get(jsonMap, 'title', 'Issue Detected'),
      issue: SafeJsonParser.get(jsonMap, 'issue', 'Analyzing screenshot...'),
      meaning: SafeJsonParser.get(jsonMap, 'meaning', 'Unknown state detected.'),
      reason: SafeJsonParser.get(jsonMap, 'reason', 'Insufficient data to determine root cause.'),
      steps: List<String>.from(jsonMap['steps'] ?? []),
      actions: List<String>.from(jsonMap['actions'] ?? []),
      platform: SafeJsonParser.get(jsonMap, 'platform', 'Unknown'),
      confidence: SafeJsonParser.get(jsonMap, 'confidence', 0.8),
      severity: SafeJsonParser.get(jsonMap, 'severity', 'medium'),
      ocrText: SafeJsonParser.get(jsonMap, 'ocrText', null),
      category: category,
      fixProbability: SafeJsonParser.get(jsonMap, 'fixProbability', 0.5),
      timestamp: DateTime.now(),
    );
  }
}
