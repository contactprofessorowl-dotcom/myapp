import 'package:flutter/material.dart';

/// Terms and Conditions. Covers use of app, AI-generated content, disclaimers, liability.
class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms & Conditions'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        children: [
          _Heading(theme: theme, text: '1. Acceptance'),
          _Paragraph(
            theme: theme,
            text: 'By using the Flash app ("App"), you agree to these Terms and Conditions. If you do not agree, do not use the App.',
          ),
          _Heading(theme: theme, text: '2. Description of Service'),
          _Paragraph(
            theme: theme,
            text: 'Flash is an educational quiz application for personal learning and practice. The App may provide quizzes, flashcards, and related content for informational and educational purposes only.',
          ),
          _Heading(theme: theme, text: '3. AI-Generated Content'),
          _Paragraph(
            theme: theme,
            text: 'Some or all quiz content (including questions, answers, and hints) may be generated or assisted by artificial intelligence (AI). We do not guarantee the accuracy, completeness, or suitability of AI-generated content. Such content is provided "as is" for general educational use only. You should verify important information with authoritative sources and not rely on the App as a sole source for academic, professional, or high-stakes decisions.',
          ),
          _Heading(theme: theme, text: '4. Educational Use Only; No Certification'),
          _Paragraph(
            theme: theme,
            text: 'The App is for self-study and informal learning only. It does not provide any official certification, credit, or qualification. Results and scores within the App have no formal academic or professional validity.',
          ),
          _Heading(theme: theme, text: '5. Acceptable Use'),
          _Paragraph(
            theme: theme,
            text: 'You agree to use the App only for lawful purposes and in a way that does not infringe the rights of others or restrict their use of the App. You may not attempt to reverse-engineer, disrupt, or misuse the App or its infrastructure.',
          ),
          _Heading(theme: theme, text: '6. Disclaimer of Warranties'),
          _Paragraph(
            theme: theme,
            text: 'THE APP AND ALL CONTENT ARE PROVIDED "AS IS" AND "AS AVAILABLE" WITHOUT WARRANTIES OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR NON-INFRINGEMENT. WE DO NOT WARRANT THAT THE APP WILL BE UNINTERRUPTED, ERROR-FREE, OR FREE OF HARMFUL COMPONENTS.',
          ),
          _Heading(theme: theme, text: '7. Limitation of Liability'),
          _Paragraph(
            theme: theme,
            text: 'TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE LAW, THE APP DEVELOPERS AND OPERATORS SHALL NOT BE LIABLE FOR ANY INDIRECT, INCIDENTAL, SPECIAL, CONSEQUENTIAL, OR PUNITIVE DAMAGES, OR ANY LOSS OF PROFITS, DATA, OR GOODWILL, ARISING FROM YOUR USE OF OR INABILITY TO USE THE APP OR ANY CONTENT THEREIN. IN NO EVENT SHALL OUR TOTAL LIABILITY EXCEED THE AMOUNT YOU PAID TO USE THE APP (IF ANY) IN THE TWELVE MONTHS PRECEDING THE CLAIM, OR ONE HUNDRED DOLLARS (USD 100), WHICHEVER IS LESS.',
          ),
          _Heading(theme: theme, text: '8. Indemnification'),
          _Paragraph(
            theme: theme,
            text: 'You agree to indemnify and hold harmless the App developers, operators, and affiliates from any claims, damages, or expenses (including reasonable legal fees) arising from your use of the App or your breach of these Terms.',
          ),
          _Heading(theme: theme, text: '9. Changes to Terms'),
          _Paragraph(
            theme: theme,
            text: 'We may update these Terms from time to time. Continued use of the App after changes constitutes acceptance of the revised Terms. We encourage you to review this page periodically.',
          ),
          _Heading(theme: theme, text: '10. Contact'),
          _Paragraph(
            theme: theme,
            text: 'For questions about these Terms, please contact us through the contact details provided in the App or on the applicable app store listing.',
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
