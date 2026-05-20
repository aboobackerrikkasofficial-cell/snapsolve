import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.termsOfService),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(context, 'Acceptance of Terms',
                'By accessing and using SnapSolve, you accept and agree to be bound by the terms and provision of this agreement. In addition, when using these particular services, you shall be subject to any posted guidelines or rules applicable to such services.'),
            _buildSection(context, 'User Responsibilities',
                'You are responsible for safeguarding the password that you use to access the Service and for any activities or actions under your password. You agree not to disclose your password to any third party.'),
            _buildSection(context, 'AI Generated Results Disclaimer',
                'SnapSolve uses artificial intelligence to analyze images and provide explanations. The results are generated automatically and may not always be 100% accurate. You should verify critical information independently.'),
            _buildSection(context, 'Prohibited Usage',
                'You agree not to use the Service to upload, post, or otherwise transmit any content that is unlawful, harmful, threatening, abusive, harassing, defamatory, vulgar, obscene, or otherwise objectionable.'),
            _buildSection(context, 'Privacy & Data',
                'Your use of the Service is also governed by our Privacy Policy. Please review our Privacy Policy to understand our practices regarding your personal data.'),
            _buildSection(context, 'Account Usage',
                'We reserve the right to terminate or suspend your account immediately, without prior notice or liability, for any reason whatsoever, including without limitation if you breach the Terms.'),
            _buildSection(context, 'Limitation of Liability',
                'In no event shall SnapSolve, nor its directors, employees, partners, agents, suppliers, or affiliates, be liable for any indirect, incidental, special, consequential or punitive damages.'),
            _buildSection(context, 'Updates to Terms',
                'We reserve the right, at our sole discretion, to modify or replace these Terms at any time. By continuing to access or use our Service after those revisions become effective, you agree to be bound by the revised terms.'),
            _buildSection(context, 'Contact',
                'If you have any questions about these Terms, please contact us at terms@snapsolve.ai.'),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.color
                  ?.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}
