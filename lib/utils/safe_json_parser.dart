import 'dart:convert';
import '../utils/app_logger.dart';

class SafeJsonParser {
  static Map<String, dynamic> parse(String raw) {
    try {
      // 1. Pre-processing: Strip markdown backticks if present
      String clean = raw.trim();
      if (clean.startsWith('```')) {
        final lines = clean.split('\n');
        if (lines.first.startsWith('```json')) {
          clean = lines.sublist(1, lines.length - 1).join('\n');
        } else if (lines.first.startsWith('```')) {
          clean = lines.sublist(1, lines.length - 1).join('\n');
        }
      }
      
      // 2. Final trim and standard parse
      clean = clean.trim();
      return json.decode(clean);
    } catch (e) {
      AppLogger.warning('Standard JSON parse failed, attempting regex extraction: $e');
      return _attemptRegexExtraction(raw);
    }
  }

  static Map<String, dynamic> _attemptRegexExtraction(String raw) {
    try {
      // Find the first { and last }
      final start = raw.indexOf('{');
      final end = raw.lastIndexOf('}');
      if (start != -1 && end != -1 && end > start) {
        final jsonPart = raw.substring(start, end + 1);
        return json.decode(jsonPart);
      }
    } catch (e) {
      AppLogger.error('JSON Extraction failed', error: e);
    }
    return {}; // Return empty instead of crashing
  }

  static T get<T>(Map<String, dynamic> json, String key, T defaultValue) {
    try {
      if (json.containsKey(key) && json[key] != null) {
        if (T == double && json[key] is int) {
          return (json[key] as int).toDouble() as T;
        }
        return json[key] as T;
      }
    } catch (e) {
      AppLogger.warning('Safe mapping failed for key: $key');
    }
    return defaultValue;
  }
}
