enum AnalysisFailureReason {
  networkError,
  providerQuotaExceeded,
  providerTimeout,
  invalidAiResponse,
  imageProcessingFailed,
  ocrFailed,
  unauthorized,
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
  String toString() => 'AnalysisException: $message (Reason: $reason, Stage: $debugStage)';
}
