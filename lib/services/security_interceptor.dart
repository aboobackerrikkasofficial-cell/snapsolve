import 'package:dio/dio.dart';
import '../config/security_config.dart';
import '../utils/app_logger.dart';

class SecurityInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // 1. Force HTTPS
    if (options.uri.scheme != 'https' && SecurityConfig.isProduction) {
      AppLogger.warning('SECURITY ALERT: Blocked insecure HTTP request to ${options.uri}');
      return handler.reject(
        DioException(
          requestOptions: options,
          error: 'Insecure connection blocked (HTTPS required)',
        ),
      );
    }

    // 2. Add Security Headers
    options.headers['X-Content-Type-Options'] = 'nosniff';
    options.headers['X-Frame-Options'] = 'DENY';
    options.headers['X-XSS-Protection'] = '1; mode=block';
    
    // 3. User Agent hardening
    options.headers['User-Agent'] = 'SnapSolve-Enterprise/1.0.0';

    AppLogger.info('Security Check Passed: ${options.method} ${options.path}');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // 4. Validate Response Integrity (Basic check)
    if (response.statusCode != 200 && response.statusCode != 201) {
      AppLogger.warning('Suspicious Response: ${response.statusCode} from ${response.requestOptions.path}');
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // 5. Sanitize Error Logs (Remove sensitive URLs/tokens from logs)
    final sanitizedMessage = err.message?.replaceAll(RegExp(r'AIza[0-9A-Za-z-_]{35}'), '[REDACTED_KEY]');
    AppLogger.error('Network Error: $sanitizedMessage');
    super.onError(err, handler);
  }
}
