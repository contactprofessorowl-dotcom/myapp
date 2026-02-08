import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'providers.dart';
import 'quiz_state.dart';
import 'services/ai_service.dart';

/// Suggested topics for younger users (by expertise level).
const Map<String, List<String>> suggestedTopicsYounger = {
  'beginner': [
    'World capitals',
    'Simple addition',
    'Colors and shapes',
    'Animals',
    'Famous stories',
    'Basic vocabulary',
  ],
  'intermediate': [
    'Multiplication tables',
    'World history',
    'Shakespeare',
    'Basic science',
    'Geography',
    'Grammar and writing',
  ],
  'advanced': [
    'Algebra',
    'Literature analysis',
    'Physics',
    'Chemistry',
    'Essay writing',
    'Current events',
  ],
};

/// Suggested topics for adults (18+) – age-appropriate, no preschool content.
const Map<String, List<String>> suggestedTopicsAdult = {
  'beginner': [
    'World capitals',
    'General knowledge',
    'History basics',
    'Science fundamentals',
    'Geography',
    'Famous books and authors',
  ],
  'intermediate': [
    'World history',
    'Literature',
    'Economics basics',
    'Biology and health',
    'Current affairs',
    'Grammar and writing',
  ],
  'advanced': [
    'Philosophy',
    'Literature analysis',
    'Physics',
    'Chemistry',
    'Politics and governance',
    'Critical thinking',
  ],
};

/// Screen to generate a quiz via AI. Suggests topics by level; level updates from quiz results.
class GenerateQuizScreen extends StatefulWidget {
  const GenerateQuizScreen({super.key});

  @override
  State<GenerateQuizScreen> createState() => _GenerateQuizScreenState();
}

class _GenerateQuizScreenState extends State<GenerateQuizScreen> {
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
    final quizState = Provider.of<QuizState>(context, listen: false);

    final questions = await ai.generateQuestions(
      topic: t,
      age: userData.age,
      expertiseLevel: userData.expertiseLevel ?? 'intermediate',
      count: _defaultCount,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (questions.isEmpty) {
      setState(() => _error = 'Could not generate questions. Try again.');
      return;
    }

    quizState.setGeneratedQuestions(questions);
    context.go('/quiz');
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
    final suggestionMap = isAdult ? suggestedTopicsAdult : suggestedTopicsYounger;
    final suggestions = suggestionMap[level] ?? suggestionMap['intermediate']!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('New quiz'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: Text(
                'Select quiz type',
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
              'Pick a topic or type your own below.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                const spacing = 12.0;
                final cardWidth = (constraints.maxWidth - spacing) / 2;
                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: suggestions.map((topic) {
                    return SizedBox(
                      width: cardWidth,
                      child: _TopicCard(
                        topic: topic,
                        onTap: _isLoading
                            ? null
                            : () {
                                _topicController.text = topic;
                                setState(() => _error = null);
                                _generate(context, topic: topic);
                              },
                        theme: theme,
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 20),
            Text(
              'Or type your own topic',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Semantics(
              label: 'Type your own topic',
              child: TextField(
                controller: _topicController,
                decoration: const InputDecoration(
                  labelText: 'Topic',
                  hintText: 'e.g. World capitals, Multiplication, Shakespeare',
                  prefixIcon: Icon(Icons.edit_rounded),
                ),
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _generate(context),
              ),
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
            Semantics(
              label: _isLoading ? 'Generating quiz' : 'Generate and start quiz',
              button: true,
              child: FilledButton(
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
                  : const Text('Generate & start quiz'),
              ),
            ),
            if (!ai.isAvailable) ...[
              const SizedBox(height: 16),
              Text(
                'AI is not configured. Add an API key to generate quizzes.',
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

class _TopicCard extends StatelessWidget {
  const _TopicCard({
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
      label: 'Topic: $topic. Double tap to start quiz.',
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
                    Icons.quiz_rounded,
                    size: 26,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    topic,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 3,
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
