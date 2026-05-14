import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

extension LocalizationExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;

  String translateKey(String key) {
    switch (key) {
      case 'startingAnalysis':
        return l10n.startingAnalysis;
      case 'uploadingScreenshot':
        return l10n.uploadingScreenshot;
      case 'readingScreenshot':
        return l10n.readingScreenshot;
      case 'optimizingScreenshot':
        return l10n.optimizingScreenshot;
      case 'detectingContent':
        return l10n.detectingContent;
      case 'analyzingWithAI':
        return l10n.analyzingWithAI;
      case 'analyzingWithBackupAI':
        return l10n.analyzingWithBackupAI;
      case 'generatingSolution':
        return l10n.generatingSolution;
      case 'aiServersBusy':
        return l10n.aiServersBusy;
      case 'tryingBackupModel':
        return l10n.tryingBackupModel;
      case 'requestTimeout':
        return l10n.requestTimeout;
      case 'networkError':
        return l10n.networkError;
      case 'invalidApiKey':
        return l10n.invalidApiKey;
      case 'genericAnalysisError':
        return l10n.genericAnalysisError;
      default:
        return key;
    }
  }
}
