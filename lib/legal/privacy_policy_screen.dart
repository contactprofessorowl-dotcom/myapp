import 'package:flutter/material.dart';

/// Privacy Policy. Covers data collection, storage, AI processing, user rights.
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        children: [
          _Heading(theme: theme, text: '1. Introduction'),
          _Paragraph(
            theme: theme,
            text: 'Flash ("we", "our", or "the App") is committed to protecting your privacy. This Privacy Policy explains what information we collect, how we use it, and your choices regarding that information.',
          ),
          _Heading(theme: theme, text: '2. Information We Collect'),
          _Paragraph(
            theme: theme,
            text: 'We may collect: (a) Information you provide, such as your name and age when you set up your profile; (b) Quiz progress and scores stored locally on your device; (c) Technical data such as device type and app version for compatibility and support. Profile data (name, age) is stored on your device using local storage (e.g. SharedPreferences) and is not transmitted to our servers unless you use features that require it (e.g. syncing or AI-generated content).',
          ),
          _Heading(theme: theme, text: '3. How We Use Your Information'),
          _Paragraph(
            theme: theme,
            text: 'We use your information to: personalize your experience within the App; provide and improve the quiz and learning features; and comply with legal obligations. We do not sell your personal information to third parties.',
          ),
          _Heading(theme: theme, text: '4. AI and Third-Party Services'),
          _Paragraph(
            theme: theme,
            text: 'The App may use artificial intelligence (AI) or third-party services to generate or process quiz content. When we do so, we may send necessary data (e.g. topic or difficulty) to such services in accordance with their respective privacy and data processing terms. We select providers that commit to appropriate data handling practices. No personal identification (such as your name or age) is required for quiz generation unless you choose to include it. You can avoid AI-processed content by using only locally stored or pre-defined quizzes, where available.',
          ),
          _Heading(theme: theme, text: '5. Data Storage and Security'),
          _Paragraph(
            theme: theme,
            text: 'Profile and progress data are stored on your device. We implement reasonable measures to protect data in our control; however, no method of transmission or storage is 100% secure. You are responsible for keeping your device secure.',
          ),
          _Heading(theme: theme, text: '6. Data Retention'),
          _Paragraph(
            theme: theme,
            text: 'Data stored on your device remains until you uninstall the App or clear app data. If we store data on our servers in the future, we will retain it only as long as necessary for the purposes described in this policy or as required by law.',
          ),
          _Heading(theme: theme, text: '7. Children'),
          _Paragraph(
            theme: theme,
            text: 'The App may be used by users of various ages. If you are under the age of majority in your jurisdiction, please use the App with the involvement of a parent or guardian. We do not knowingly collect personal information from children without appropriate consent where required.',
          ),
          _Heading(theme: theme, text: '8. Your Rights'),
          _Paragraph(
            theme: theme,
            text: 'Depending on your location, you may have rights to access, correct, or delete your personal data. You can update or clear your profile (name, age) at any time from the Account section of the App. For other requests, contact us using the details below.',
          ),
          _Heading(theme: theme, text: '9. Changes to This Policy'),
          _Paragraph(
            theme: theme,
            text: 'We may update this Privacy Policy from time to time. We will notify you of material changes through the App or by other reasonable means. Continued use after changes constitutes acceptance of the updated policy.',
          ),
          _Heading(theme: theme, text: '10. Contact'),
          _Paragraph(
            theme: theme,
            text: 'For privacy-related questions or requests, please contact us through the contact details provided in the App or on the applicable app store listing.',
          ),
          const SizedBox(height: 24),
          Text(
            'Last updated: 2025',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading({required this.theme, required this.text});

  final ThemeData theme;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Semantics(
        header: true,
        child: Text(
          text,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }
}

class _Paragraph extends StatelessWidget {
  const _Paragraph({required this.theme, required this.text});

  final ThemeData theme;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface,
          height: 1.5,
        ),
      ),
    );
  }
}
