import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

extension LocalizationExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;

  String translateKey(String key) {
    switch (key) {
      // Analysis Statuses & Errors
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

      // Categories
      case 'instagram':
        return l10n.instagram;
      case 'banking':
        return l10n.banking;
      case 'settings':
        return l10n.settings;
      case 'whatsapp':
        return l10n.whatsapp;
      case 'coding':
        return l10n.coding;
      case 'browser':
        return l10n.browser;
      case 'study':
        return l10n.study;
      case 'gaming':
        return l10n.gaming;
      case 'system':
        return l10n.system;
      case 'design':
        return l10n.design;

      // Tips
      case 'instaTip1':
        return l10n.instaTip1;
      case 'instaTip2':
        return l10n.instaTip2;
      case 'bankTip1':
        return l10n.bankTip1;
      case 'bankTip2':
        return l10n.bankTip2;
      case 'settingsTip1':
        return l10n.settingsTip1;
      case 'settingsTip2':
        return l10n.settingsTip2;
      case 'waTip1':
        return l10n.waTip1;
      case 'waTip2':
        return l10n.waTip2;
      case 'codeTip1':
        return l10n.codeTip1;
      case 'codeTip2':
        return l10n.codeTip2;
      case 'browserTip1':
        return l10n.browserTip1;
      case 'browserTip2':
        return l10n.browserTip2;
      case 'studyTip1':
        return l10n.studyTip1;
      case 'studyTip2':
        return l10n.studyTip2;
      case 'gameTip1':
        return l10n.gameTip1;
      case 'gameTip2':
        return l10n.gameTip2;
      case 'systemTip1':
        return l10n.systemTip1;
      case 'systemTip2':
        return l10n.systemTip2;
      case 'designTip1':
        return l10n.designTip1;
      case 'designTip2':
        return l10n.designTip2;

      // Common Issues
      case 'instaIssue1':
        return l10n.instaIssue1;
      case 'instaIssue2':
        return l10n.instaIssue2;
      case 'bankIssue1':
        return l10n.bankIssue1;
      case 'bankIssue2':
        return l10n.bankIssue2;
      case 'settingsIssue1':
        return l10n.settingsIssue1;
      case 'settingsIssue2':
        return l10n.settingsIssue2;
      case 'waIssue1':
        return l10n.waIssue1;
      case 'waIssue2':
        return l10n.waIssue2;
      case 'codeIssue1':
        return l10n.codeIssue1;
      case 'codeIssue2':
        return l10n.codeIssue2;
      case 'browserIssue1':
        return l10n.browserIssue1;
      case 'browserIssue2':
        return l10n.browserIssue2;
      case 'studyIssue1':
        return l10n.studyIssue1;
      case 'studyIssue2':
        return l10n.studyIssue2;
      case 'gameIssue1':
        return l10n.gameIssue1;
      case 'gameIssue2':
        return l10n.gameIssue2;
      case 'systemIssue1':
        return l10n.systemIssue1;
      case 'systemIssue2':
        return l10n.systemIssue2;
      case 'designIssue1':
        return l10n.designIssue1;
      case 'designIssue2':
        return l10n.designIssue2;

      default:
        return key;
    }
  }
}
