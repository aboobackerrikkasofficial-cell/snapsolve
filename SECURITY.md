# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |
| < 1.0   | :x:                |

## Reporting a Vulnerability

We take the security of SnapSolve seriously. If you believe you have found a security vulnerability, please report it to us by following these steps:

1. **Do not open a public issue.**
2. Send an email to `security@snapsolve.ai` with the details of the vulnerability.
3. We will acknowledge your report within 48 hours and provide a timeline for a fix.

## Environment Secret Management

SnapSolve uses `String.fromEnvironment` (via `--dart-define`) to handle sensitive API keys. 
**NEVER** commit API keys directly to the repository. 
Use GitHub Secrets for CI/CD pipelines.
