import 'dart:convert';
import 'package:html/parser.dart' show parse;
import '../utils/app_logger.dart';

class SecurityUtils {
  /// Sanitizes user input to prevent injection attacks and malformed data.
  static String sanitizeInput(String input) {
    if (input.isEmpty) return input;
    
    // 1. Remove any HTML tags (XSS protection)
    final document = parse(input);
    String sanitized = document.body?.text ?? '';
    
    // 2. Escape special characters that might break JSON or Prompts
    sanitized = sanitized.replaceAll('\\', '\\\\').replaceAll('"', '\\"');
    
    // 3. Limit length to prevent buffer/memory abuse
    if (sanitized.length > 2000) {
      sanitized = sanitized.substring(0, 2000);
    }
    
    return sanitized.trim();
  }

  /// Validates if an image file is safe for processing.
  static bool isImageSafe(int sizeInBytes, String extension) {
    // 1. Size check (e.g., 10MB)
    const int maxSizeBytes = 10 * 1024 * 1024;
    if (sizeInBytes > maxSizeBytes) {
      AppLogger.warning('Image too large: $sizeInBytes bytes');
      return false;
    }
    
    // 2. Extension whitelist
    final allowedExtensions = ['.jpg', '.jpeg', '.png', '.webp'];
    if (!allowedExtensions.contains(extension.toLowerCase())) {
      AppLogger.warning('Unsupported image format: $extension');
      return false;
    }
    
    return true;
  }

  /// Simple rate limiter to prevent automation abuse.
  static final Map<String, List<DateTime>> _requestLog = {};
  
  static bool checkRateLimit(String userId, int maxRequests, Duration window) {
    final now = DateTime.now();
    final userLogs = _requestLog.putIfAbsent(userId, () => []);
    
    // Remove expired logs
    userLogs.removeWhere((timestamp) => now.difference(timestamp) > window);
    
    if (userLogs.length >= maxRequests) {
      return false;
    }
    
    userLogs.add(now);
    return true;
  }
}
