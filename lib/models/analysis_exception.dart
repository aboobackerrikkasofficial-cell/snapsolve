enum AnalysisFailureReason {
  networkError,
  providerQuotaExceeded,
  providerTimeout,
  invalidAiResponse,
  imageProcessingFailed,
  ocrFailed,
  unauthorized,
  invalidApiKey,
  safetyFilterBlocked,
  unknown,
}

class AnalysisException implements Exception {
  final String message;
  final AnalysisFailureReason reason;
  final dynamic originalError;
  final StackTrace? stackTrace;
  final bool isRetryable;
  final String? debugStage;

  AnalysisException({
    required this.message,
    required this.reason,
    this.originalError,
    this.stackTrace,
    this.isRetryable = true,
    this.debugStage,
  });

  @override
  String toString() =>
      'AnalysisException: $message (Reason: $reason, Stage: $debugStage)';

  String get diagnosticSummary {
    final buffer = StringBuffer();
    buffer.writeln('Exception: $message');
    buffer.writeln('Reason: $reason');
    if (debugStage != null) buffer.writeln('Stage: $debugStage');
    if (originalError != null) buffer.writeln('Original: $originalError');
    return buffer.toString();
  }
}
