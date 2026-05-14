import 'package:flutter/material.dart';
import '../models/app_category.dart';

class CategoryRepository {
  static const List<AppCategory> categories = [
    AppCategory(
      id: 'instagram',
      titleKey: 'instagram',
      icon: Icons.camera_enhance,
      color: Colors.pink,
      promptTemplate:
          'This is an Instagram-related screenshot. Focus on social media troubleshooting, account security, login issues, and feature explanations (Reels, DMs, etc.).',
      tipsKeys: ['instaTip1', 'instaTip2'],
      commonIssuesKeys: ['instaIssue1', 'instaIssue2'],
    ),
    AppCategory(
      id: 'banking',
      titleKey: 'banking',
      icon: Icons.account_balance,
      color: Colors.blue,
      promptTemplate:
          'This is a Banking/Payment screenshot. Focus on transaction failures, security warnings, KYC issues, and OTP explanations. Prioritize security and privacy advice.',
      tipsKeys: ['bankTip1', 'bankTip2'],
      commonIssuesKeys: ['bankIssue1', 'bankIssue2'],
    ),
    AppCategory(
      id: 'settings',
      titleKey: 'settings',
      icon: Icons.settings,
      color: Colors.orange,
      promptTemplate:
          'This is a Device Settings screenshot. Explain what the specific setting does and how to configure it correctly.',
      tipsKeys: ['settingsTip1', 'settingsTip2'],
      commonIssuesKeys: ['settingsIssue1', 'settingsIssue2'],
    ),
    AppCategory(
      id: 'whatsapp',
      titleKey: 'whatsapp',
      icon: Icons.chat_rounded,
      color: Colors.teal,
      promptTemplate:
          'This is a WhatsApp screenshot. Focus on chat backups, security settings, and contact issues.',
      tipsKeys: ['waTip1', 'waTip2'],
      commonIssuesKeys: ['waIssue1', 'waIssue2'],
    ),
    AppCategory(
      id: 'coding',
      titleKey: 'coding',
      icon: Icons.code_rounded,
      color: Colors.indigo,
      promptTemplate:
          'This is a Code or IDE screenshot. Identify the programming language, explain the error message if present, and suggest a fix or optimization.',
      tipsKeys: ['codeTip1', 'codeTip2'],
      commonIssuesKeys: ['codeIssue1', 'codeIssue2'],
    ),
    AppCategory(
      id: 'browser',
      titleKey: 'browser',
      icon: Icons.language_rounded,
      color: Colors.lightBlue,
      promptTemplate:
          'This is a Web Browser screenshot. Focus on website loading errors, certificate issues, and navigation problems.',
      tipsKeys: ['browserTip1', 'browserTip2'],
      commonIssuesKeys: ['browserIssue1', 'browserIssue2'],
    ),
    AppCategory(
      id: 'study',
      titleKey: 'study',
      icon: Icons.school_rounded,
      color: Colors.purple,
      promptTemplate:
          'This is a Study/Educational screenshot. Solve the question, explain the concept, or summarize the text provided.',
      tipsKeys: ['studyTip1', 'studyTip2'],
      commonIssuesKeys: ['studyIssue1', 'studyIssue2'],
    ),
    AppCategory(
      id: 'gaming',
      titleKey: 'gaming',
      icon: Icons.sports_esports_rounded,
      color: Colors.red,
      promptTemplate:
          'This is a Gaming screenshot. Focus on performance issues, connectivity errors, and game-specific mechanics.',
      tipsKeys: ['gameTip1', 'gameTip2'],
      commonIssuesKeys: ['gameIssue1', 'gameIssue2'],
    ),
    AppCategory(
      id: 'system',
      titleKey: 'system',
      icon: Icons.warning_amber_rounded,
      color: Colors.deepOrange,
      promptTemplate:
          'This is a System Error screenshot. Explain the error code and provide steps to resolve the system-level issue.',
      tipsKeys: ['systemTip1', 'systemTip2'],
      commonIssuesKeys: ['systemIssue1', 'systemIssue2'],
    ),
    AppCategory(
      id: 'design',
      titleKey: 'design',
      icon: Icons.brush_rounded,
      color: Colors.amber,
      promptTemplate:
          'This is a Graphic Design or Invitation screenshot. Analyze the design elements and provide creative feedback or suggestions.',
      tipsKeys: ['designTip1', 'designTip2'],
      commonIssuesKeys: ['designIssue1', 'designIssue2'],
    ),
  ];

  static AppCategory getCategoryById(String id) {
    return categories.firstWhere((cat) => cat.id == id,
        orElse: () => categories[0]);
  }
}
