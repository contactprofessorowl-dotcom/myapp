import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'providers.dart';
import 'services/ai_service.dart';
import 'theme.dart';
import 'vocabulary_state.dart';

/// Suggested vocabulary topics for younger users (by expertise level).
const Map<String, List<String>> _vocabularyTopicsYounger = {
  'beginner': [
    'Basic vocabulary',
    'World capitals',
    'Animals',
    'Colors and shapes',
    'Famous places',
    'Simple science terms',
  ],
  'intermediate': [
    'Science vocabulary',
    'World history terms',
    'Literature vocabulary',
    'Geography terms',
    'Grammar and writing',
    'Story words',
  ],
  'advanced': [
    'Academic vocabulary',
    'Science terminology',
    'Literature analysis terms',
    'Geography and culture',
    'Essay writing',
    'Current events',
  ],
};

/// Suggested vocabulary topics for adults (18+) – age-appropriate.
const Map<String, List<String>> _vocabularyTopicsAdult = {
  'beginner': [
    'World capitals',
    'General knowledge terms',
    'History basics',
    'Science fundamentals',
    'Geography',
    'Famous books and authors',
  ],
  'intermediate': [
    'World history terms',
    'Literature vocabulary',
    'Economics basics',
    'Biology and health',
    'Current affairs',
    'Grammar and writing',
  ],
  'advanced': [
    'Academic vocabulary',
    'Philosophy terms',
    'Physics terminology',
    'Chemistry terms',
    'Politics and governance',
    'Critical thinking',
  ],
};

class GenerateVocabularyScreen extends StatefulWidget {
  const GenerateVocabularyScreen({super.key});

  @override
  State<GenerateVocabularyScreen> createState() => _GenerateVocabularyScreenState();
}

class _GenerateVocabularyScreenState extends State<GenerateVocabularyScreen> {
  final _topicController = TextEditingController();
  static const int _defaultCount = 10;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  Future<void> _generate(BuildContext context, {String? topic}) async {
    final t = (topic ?? _topicController.text).trim();
    if (t.isEmpty) {
      setState(() => _error = 'Pick or enter a topic');
      return;
    }
    setState(() {
      _error = null;
      _isLoading = true;
    });

    final ai = Provider.of<AiService>(context, listen: false);
    final userData = Provider.of<UserData>(context, listen: false);
    final vocabularyState = Provider.of<VocabularyState>(context, listen: false);

    final cards = await ai.generateVocabulary(
      topic: t,
      age: userData.age,
      expertiseLevel: userData.expertiseLevel ?? 'intermediate',
      count: _defaultCount,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (cards.isEmpty) {
      setState(() => _error = 'Could not generate vocabulary. Try again.');
      return;
    }

    vocabularyState.setCards(cards);
    context.go('/vocabulary-cards');
  }

  String _levelLabel(String? level) {
    switch (level?.toLowerCase()) {
      case 'beginner':
        return 'Beginner';
      case 'advanced':
        return 'Advanced';
      default:
        return 'Intermediate';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userData = Provider.of<UserData>(context);
    final ai = Provider.of<AiService>(context);
    final level = userData.expertiseLevel ?? 'intermediate';
    final age = int.tryParse(userData.age?.trim() ?? '');
    final isAdult = age != null && age >= 18;
    final topicMap = isAdult ? _vocabularyTopicsAdult : _vocabularyTopicsYounger;
    final suggestions = topicMap[level] ?? topicMap['intermediate']!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vocabulary'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: Text(
                'Select topic',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.school_rounded, size: 20, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Level: ${_levelLabel(userData.expertiseLevel)}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Pick a topic. You\'ll get flashcards with definitions on one side and the word or phrase on the other.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.15,
              children: suggestions.map((topic) {
                return _VocabularyTopicCard(
                  topic: topic,
                  onTap: _isLoading ? null : () => _generate(context, topic: topic),
                  theme: theme,
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Text(
              'Or type your own topic',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _topicController,
              decoration: const InputDecoration(
                labelText: 'Topic',
                hintText: 'e.g. Science vocabulary, Geography terms',
                prefixIcon: Icon(Icons.edit_rounded),
              ),
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: (_) => _generate(context),
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(
                _error!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
            const SizedBox(height: 28),
            FilledButton(
              onPressed: _isLoading ? null : () => _generate(context),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Generate & start flashcards'),
            ),
            if (!ai.isAvailable) ...[
              const SizedBox(height: 16),
              Text(
                'AI is not configured. Add an API key to generate vocabulary.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _VocabularyTopicCard extends StatelessWidget {
  const _VocabularyTopicCard({
    required this.topic,
    required this.onTap,
    required this.theme,
  });

  final String topic;
  final VoidCallback? onTap;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: onTap != null,
      label: 'Topic: $topic. Double tap to start flashcards.',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.menu_book_rounded,
                      size: 26,
                      color: FlashAccentColors.blue,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      topic,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}