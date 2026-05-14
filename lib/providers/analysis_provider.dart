import 'dart:async';
import 'package:flutter/material.dart';
import '../models/analysis_result.dart';
import '../models/problem_context.dart';
import '../models/analysis_exception.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../utils/app_logger.dart';

class AnalysisProvider extends ChangeNotifier {
  final ApiService _apiService;
  final StorageService _storageService;

  AnalysisProvider(this._apiService, this._storageService) {
    _loadHistory();
  }

  List<AnalysisResult> _history = [];
  bool _isAnalyzing = false;
  String _loadingMessage = '';
  AnalysisResult? _currentResult;
  AnalysisException? _currentError;
  int _retryCount = 0;
  static const int _maxRetries = 2;

  List<AnalysisResult> get history => _history;
  bool get isAnalyzing => _isAnalyzing;
  String get loadingMessage => _loadingMessage;
  AnalysisResult? get currentResult => _currentResult;
  AnalysisException? get error => _currentError;
  int get retryCount => _retryCount;

  void _loadHistory() {
    try {
      _history = _storageService.getHistory();
      notifyListeners();
    } catch (e) {
      AppLogger.error('Storage History Read Fail', error: e);
    }
  }

  Future<void> analyzeImage(ProblemContext context,
      {bool isRetry = false}) async {
    // Removed block: if (_isAnalyzing && !isRetry) return; to allow overriding from new screens
    if (!isRetry) {
      _retryCount = 0;
    }

    _isAnalyzing = true;
    _loadingMessage = isRetry ? 'retryingAnalysis' : 'startingAnalysis';
    _currentError = null;
    _currentResult = null;
    notifyListeners();

    try {
      AppLogger.info('>>> PIPELINE EXECUTION START (Retry: $_retryCount) <<<');

      final result = await _apiService
          .analyzeScreenshot(
            context: context,
            onProgress: (msg) {
              if (_loadingMessage != msg) {
                _loadingMessage = msg;
                notifyListeners();
              }
            },
          )
          .timeout(const Duration(seconds: 90));

      _currentResult = result;
      _retryCount = 0;
      await _storageService.saveAnalysis(result);
      _loadHistory();
      AppLogger.info('>>> PIPELINE EXECUTION SUCCESS <<<');
    } on AnalysisException catch (e, stack) {
      AppLogger.error('PIPELINE RECOVERABLE FAILURE',
          error: e, stackTrace: stack);
      _handleFailure(e, context);
    } catch (e, stack) {
      AppLogger.error('PIPELINE UNHANDLED CRITICAL FAILURE',
          error: e, stackTrace: stack);
      _handleFailure(
        AnalysisException(
          message: 'An unexpected error occurred.',
          reason: AnalysisFailureReason.unknown,
          originalError: e,
          stackTrace: stack,
          debugStage: 'Provider Top Catch',
        ),
        context,
      );
    } finally {
      if (_currentError != null || _currentResult != null || !isRetry) {
        _isAnalyzing = false;
        notifyListeners();
      }
    }
  }

  void _handleFailure(AnalysisException e, ProblemContext context) {
    if (e.isRetryable && _retryCount < _maxRetries) {
      _retryCount++;
      AppLogger.info('Retrying analysis ($retryCount/$_maxRetries)...');

      Future.delayed(Duration(seconds: 2 * _retryCount), () {
        analyzeImage(context, isRetry: true);
      });
    } else {
      AppLogger.error('ANALYSIS ABORTED: Permanent Error or Max Retries.');
      _currentError = e;
      _isAnalyzing = false;
      notifyListeners();
    }
  }

  Future<void> improveAnalysis({
    required AnalysisResult original,
    required String feedback,
    required dynamic primaryImage,
    required String language,
  }) async {
    if (_isAnalyzing) return;

    _isAnalyzing = true;
    _loadingMessage = 'improvingAnalysis';
    _currentError = null;
    notifyListeners();

    try {
      final refinedResult = await _apiService.improveAnalysis(
        originalResult: original,
        userFeedback: feedback,
        imageFile: primaryImage,
        language: language,
        onProgress: (msg) {
          if (_loadingMessage != msg) {
            _loadingMessage = msg;
            notifyListeners();
          }
        },
      );

      _currentResult = refinedResult;
      await _storageService.saveAnalysis(refinedResult);
      _loadHistory();
    } catch (e, stack) {
      AppLogger.error('REFINEMENT FAILURE', error: e, stackTrace: stack);
      _currentError = AnalysisException(
        message: 'Could not refine analysis.',
        reason: AnalysisFailureReason.unknown,
        originalError: e,
        stackTrace: stack,
        debugStage: 'Refinement Catch',
      );
    } finally {
      _isAnalyzing = false;
      notifyListeners();
    }
  }

  Future<void> deleteAnalysis(String id) async {
    await _storageService.deleteAnalysis(id);
    _loadHistory();
  }

  Future<void> clearHistory() async {
    await _storageService.clearHistory();
    _loadHistory();
  }

  void setCurrentResult(AnalysisResult result) {
    _currentResult = result;
    _currentError = null;
    notifyListeners();
  }
}
