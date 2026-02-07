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
  static const int _defaultCount = 5;
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
            Text(
              'Suggested for your level',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _levelLabel(userData.expertiseLevel),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Pick a topic below or type your own. Quizzes adapt to your level and get harder as you do well.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Suggested topics',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: suggestions.map((topic) {
                return ActionChip(
                  label: Text(topic),
                  onPressed: _isLoading
                      ? null
                      : () {
                          _topicController.text = topic;
                          setState(() => _error = null);
                          _generate(context, topic: topic);
                        },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _topicController,
              decoration: const InputDecoration(
                labelText: 'Or type your own topic',
                hintText: 'e.g. World capitals, Multiplication, Shakespeare',
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
                  : const Text('Generate & start quiz'),
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
