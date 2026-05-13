# Troubleshooting Guide

## Common Build Issues

### Flutter SDK Version Mismatch
- **Issue**: `pubspec.yaml` requires a higher version.
- **Fix**: Run `flutter upgrade` and ensure your channel is `stable`.

### Missing API Keys
- **Issue**: App starts but AI analysis fails with 401/403.
- **Fix**: Check that you are passing `--dart-define` keys or that GitHub Secrets are correctly named.

### Android Signing Errors
- **Issue**: `Execution failed for task ':app:validateSigningRelease'`.
- **Fix**: Ensure `key.properties` exists in the `android/` folder and contains valid paths/passwords.

## AI Engine Errors

### Low Confidence Flag
- **Issue**: AI result shows "Low Confidence".
- **Fix**: The image might be too blurry or the UI pattern is unrecognized. Try providing a clearer screenshot or adding a manual description.

### JSON Parsing Errors
- **Issue**: `FormatException: Unexpected character`.
- **Fix**: This happens when an AI model returns non-JSON text. The consensus engine should catch this, but if it persists, check the model providers' status.
