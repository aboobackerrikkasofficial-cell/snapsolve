import '../models/ai_response.dart';

abstract class BaseAiProvider {
  String get name;
  bool get isEnabled;

  Future<AiResponse> analyzeScreenshot({
    required dynamic imageBytes,
    String? category,
    String language = 'en',
    required String prompt,
  });

  Future<AiResponse> analyzeMultiImages({
    required List<dynamic> images,
    String? category,
    String language = 'en',
    required String prompt,
  });
}
