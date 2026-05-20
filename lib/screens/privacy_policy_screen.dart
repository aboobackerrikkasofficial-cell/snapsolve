import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.privacyPolicy),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(context, 'Introduction',
                'Welcome to SnapSolve. We respect your privacy and are committed to protecting your personal data. This privacy policy will inform you as to how we look after your personal data when you visit our application and tell you about your privacy rights and how the law protects you.'),
            _buildSection(context, 'Information Collection',
                'We may collect, use, store and transfer different kinds of personal data about you. This includes identity data, contact data, technical data, and usage data.'),
            _buildSection(context, 'Camera & Image Access',
                'Our core functionality requires access to your device camera and photo gallery. Images processed by our AI are used strictly for analysis purposes and are not used to train our models without your explicit consent.'),
            _buildSection(context, 'AI Analysis Usage',
                'We utilize advanced AI models to provide screenshot explanations. The text and data extracted from your images are processed securely and temporarily.'),
            _buildSection(context, 'Data Storage',
                'Your analysis history is stored locally on your device by default. Cloud syncing is optional and requires explicit opt-in.'),
            _buildSection(context, 'User Rights',
                'You have the right to request access, correction, erasure, or restriction of your personal data. You can delete all history and clear cache directly from the settings menu.'),
            _buildSection(context, 'Security',
                'We have put in place appropriate security measures to prevent your personal data from being accidentally lost, used or accessed in an unauthorized way, altered or disclosed.'),
            _buildSection(context, 'Contact Information',
                'If you have any questions about this privacy policy or our privacy practices, please contact us at support@snapsolve.ai.'),
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
