import 'package:flutter/material.dart';

class AppCategory {
  final String id;
  final String titleKey;
  final IconData icon;
  final Color color;
  final String promptTemplate;
  final List<String> tipsKeys;
  final List<String> commonIssuesKeys;

  const AppCategory({
    required this.id,
    required this.titleKey,
    required this.icon,
    required this.color,
    required this.promptTemplate,
    required this.tipsKeys,
    required this.commonIssuesKeys,
  });
}
