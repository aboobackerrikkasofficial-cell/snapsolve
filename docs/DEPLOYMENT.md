# Deployment Guide

## GitHub Actions Automation
SnapSolve is configured for full CI/CD.

### CI Pipeline (`flutter-ci.yml`)
- Triggers on push to `main` and `develop`.
- Runs: `flutter analyze`, `flutter test`.
- Builds: Web, Debug APK, Release APK.
- Deploys: Automatically to GitHub Pages for the web version.

### CD Pipeline (`release.yml`)
- Triggers on tags starting with `v` (e.g., `v1.0.1`).
- Generates a GitHub Release.
- Uploads the production-ready APK as a release asset.

## Manual Build Instructions

### Android Release
1. Ensure `android/key.properties` is configured (see `android/key.properties.example`).
2. Run:
   ```bash
   flutter build apk --release --obfuscate --split-debug-info=build/app/outputs/symbols
   ```

### Web Release
1. Run:
   ```bash
   flutter build web --release
   ```

## Environment Secrets
You must configure the following **GitHub Secrets** in your repository settings:
- `GEMINI_API_KEY`
- `GROQ_API_KEY`
- `OPENROUTER_API_KEY`
- `SNYK_TOKEN` (for security scans)
