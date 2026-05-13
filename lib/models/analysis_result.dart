import 'dart:convert';

class AnalysisHypothesis {
  final String description;
  final double probability;

  AnalysisHypothesis({required this.description, required this.probability});

  Map<String, dynamic> toMap() {
    return {'description': description, 'probability': probability};
  }

  factory AnalysisHypothesis.fromMap(Map<String, dynamic> map) {
    return AnalysisHypothesis(
      description: map['description'] ?? '',
      probability: (map['probability'] ?? 0.0).toDouble(),
    );
  }
}

class AnalysisResult {
  final String id;
  final String title;
  final String issue;
  final String meaning;
  final String reason;
  final String rootCause;
  final List<String> steps;
  final String mostLikelyFix;
  final List<String> alternativeFixes;
  final String whatNotToDo;
  final List<String> actions;
  final String imageUrl;
  final DateTime timestamp;
  final String? category;
  final String? platform;
  final double? confidence;
  final String? ocrText;
  final String? severity;
  final double? fixProbability;
  final List<String>? providers;
  final String? parentId;
  final bool isRefined;
  final List<String>? followUpQuestions;
  final List<AnalysisHypothesis>? hypotheses; // New: Ranked Hypotheses

  AnalysisResult({
    required this.id,
    required this.title,
    required this.issue,
    required this.meaning,
    required this.reason,
    required this.rootCause,
    required this.steps,
    required this.mostLikelyFix,
    required this.alternativeFixes,
    required this.whatNotToDo,
    required this.actions,
    required this.imageUrl,
    required this.timestamp,
    this.category,
    this.platform,
    this.confidence,
    this.ocrText,
    this.severity,
    this.fixProbability,
    this.providers,
    this.parentId,
    this.isRefined = false,
    this.followUpQuestions,
    this.hypotheses,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'issue': issue,
      'meaning': meaning,
      'reason': reason,
      'rootCause': rootCause,
      'steps': steps,
      'mostLikelyFix': mostLikelyFix,
      'alternativeFixes': alternativeFixes,
      'whatNotToDo': whatNotToDo,
      'actions': actions,
      'imageUrl': imageUrl,
      'timestamp': timestamp.toIso8601String(),
      'category': category,
      'platform': platform,
      'confidence': confidence,
      'ocrText': ocrText,
      'severity': severity,
      'fixProbability': fixProbability,
      'providers': providers,
      'parentId': parentId,
      'isRefined': isRefined,
      'followUpQuestions': followUpQuestions,
      'hypotheses': hypotheses?.map((h) => h.toMap()).toList(),
    };
  }

  factory AnalysisResult.fromMap(Map<String, dynamic> map) {
    return AnalysisResult(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      issue: map['issue'] ?? '',
      meaning: map['meaning'] ?? '',
      reason: map['reason'] ?? '',
      rootCause: map['rootCause'] ?? 'Unknown',
      steps: List<String>.from(map['steps'] ?? []),
      mostLikelyFix: map['mostLikelyFix'] ?? '',
      alternativeFixes: List<String>.from(map['alternativeFixes'] ?? []),
      whatNotToDo: map['whatNotToDo'] ?? 'Proceed with caution.',
      actions: List<String>.from(map['actions'] ?? []),
      imageUrl: map['imageUrl'] ?? '',
      timestamp: DateTime.parse(map['timestamp']),
      category: map['category'],
      platform: map['platform'],
      confidence: map['confidence']?.toDouble(),
      ocrText: map['ocrText'],
      severity: map['severity'],
      fixProbability: map['fixProbability']?.toDouble(),
      providers: map['providers'] != null ? List<String>.from(map['providers']) : null,
      parentId: map['parentId'],
      isRefined: map['isRefined'] ?? false,
      followUpQuestions: map['followUpQuestions'] != null ? List<String>.from(map['followUpQuestions']) : null,
      hypotheses: map['hypotheses'] != null 
        ? List<AnalysisHypothesis>.from((map['hypotheses'] as List).map((h) => AnalysisHypothesis.fromMap(h))) 
        : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory AnalysisResult.fromJson(String source) => AnalysisResult.fromMap(json.decode(source));
}
