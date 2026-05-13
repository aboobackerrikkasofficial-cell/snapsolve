import 'dart:typed_data';

class ProblemContext {
  final dynamic imageFile; // XFile or Uint8List
  final String? userDescription;
  final String? category;
  final String? ocrText;
  final Map<String, dynamic>? deviceInfo;
  final String? appVersion;
  final DateTime timestamp;
  final String language;

  ProblemContext({
    required this.imageFile,
    this.userDescription,
    this.category,
    this.ocrText,
    this.deviceInfo,
    this.appVersion,
    required this.timestamp,
    required this.language,
  });

  ProblemContext copyWith({
    dynamic imageFile,
    String? userDescription,
    String? category,
    String? ocrText,
    Map<String, dynamic>? deviceInfo,
    String? appVersion,
    DateTime? timestamp,
    String? language,
  }) {
    return ProblemContext(
      imageFile: imageFile ?? this.imageFile,
      userDescription: userDescription ?? this.userDescription,
      category: category ?? this.category,
      ocrText: ocrText ?? this.ocrText,
      deviceInfo: deviceInfo ?? this.deviceInfo,
      appVersion: appVersion ?? this.appVersion,
      timestamp: timestamp ?? this.timestamp,
      language: language ?? this.language,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userDescription': userDescription,
      'category': category,
      'ocrText': ocrText,
      'deviceInfo': deviceInfo,
      'appVersion': appVersion,
      'timestamp': timestamp.toIso8601String(),
      'language': language,
    };
  }
}
