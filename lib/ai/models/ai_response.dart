import 'dart:convert';

class AiHypothesis {
  final String description;
  final double probability;

  AiHypothesis({required this.description, required this.probability});
}

class AiResponse {
  final String providerName;
  final String title;
  final String issue;
  final String meaning;
  final String reason;
  final String? rootCause;
  final List<String> steps;
  final String? mostLikelyFix;
  final List<String>? alternativeFixes;
  final String? whatNotToDo;
  final List<String> actions;
  final String? platform;
  final double confidence;
  final String? severity;
  final String? ocrText;
  final String? category;
  final double fixProbability;
  final DateTime timestamp;
  final List<String>? followUpQuestions;
  final List<AiHypothesis>? hypotheses; // New: Expert ranked hypotheses

  AiResponse({
    required this.providerName,
    required this.title,
    required this.issue,
    required this.meaning,
    required this.reason,
    this.rootCause,
    required this.steps,
    this.mostLikelyFix,
    this.alternativeFixes,
    this.whatNotToDo,
    required this.actions,
    this.platform,
    required this.confidence,
    this.severity,
    this.ocrText,
    this.category,
    required this.fixProbability,
    required this.timestamp,
    this.followUpQuestions,
    this.hypotheses,
  });

  AiResponse copyWith({
    String? providerName,
    String? title,
    String? issue,
    String? meaning,
    String? reason,
    String? rootCause,
    List<String>? steps,
    String? mostLikelyFix,
    List<String>? alternativeFixes,
    String? whatNotToDo,
    List<String>? actions,
    String? platform,
    double? confidence,
    String? severity,
    String? ocrText,
    String? category,
    double? fixProbability,
    DateTime? timestamp,
    List<String>? followUpQuestions,
    List<AiHypothesis>? hypotheses,
  }) {
    return AiResponse(
      providerName: providerName ?? this.providerName,
      title: title ?? this.title,
      issue: issue ?? this.issue,
      meaning: meaning ?? this.meaning,
      reason: reason ?? this.reason,
      rootCause: rootCause ?? this.rootCause,
      steps: steps ?? this.steps,
      mostLikelyFix: mostLikelyFix ?? this.mostLikelyFix,
      alternativeFixes: alternativeFixes ?? this.alternativeFixes,
      whatNotToDo: whatNotToDo ?? this.whatNotToDo,
      actions: actions ?? this.actions,
      platform: platform ?? this.platform,
      confidence: confidence ?? this.confidence,
      severity: severity ?? this.severity,
      ocrText: ocrText ?? this.ocrText,
      category: category ?? this.category,
      fixProbability: fixProbability ?? this.fixProbability,
      timestamp: timestamp ?? this.timestamp,
      followUpQuestions: followUpQuestions ?? this.followUpQuestions,
      hypotheses: hypotheses ?? this.hypotheses,
    );
  }
}
