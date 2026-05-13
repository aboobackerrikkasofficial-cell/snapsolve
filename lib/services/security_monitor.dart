import '../utils/app_logger.dart';

class SecurityMonitor {
  static final Map<String, int> _violationCounts = {};
  static const int _banThreshold = 5;

  static void trackViolation(String userId, String violationType) {
    _violationCounts[userId] = (_violationCounts[userId] ?? 0) + 1;
    
    AppLogger.warning('SECURITY VIOLATION: Type: $violationType, User: $userId, Count: ${_violationCounts[userId]}');

    if (_violationCounts[userId]! >= _banThreshold) {
      _triggerAccountLockdown(userId);
    }
  }

  static bool isUserBlocked(String userId) {
    return (_violationCounts[userId] ?? 0) >= _banThreshold;
  }

  static void _triggerAccountLockdown(String userId) {
    AppLogger.error('CRITICAL: Account Lockdown triggered for user $userId due to repeated security violations.');
    // In production, this would call a backend API to disable the account
  }
}
