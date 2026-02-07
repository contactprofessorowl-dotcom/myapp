import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'providers.dart';
import 'quiz_state.dart';
import 'services/ai_service.dart';

/// Screen to generate a quiz via AI (Gemini) using topic, age, and expertise level.
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

  Future<void> _generate(BuildContext context) async {
    final topic = _topicController.text.trim();
    if (topic.isEmpty) {
      setState(() => _error = 'Enter a topic');
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
      topic: topic,
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ai = Provider.of<AiService>(context);
    final userData = Provider.of<UserData>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate quiz'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'AI will create quiz questions based on your topic and level.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _topicController,
              decoration: const InputDecoration(
                labelText: 'Topic',
                hintText: 'e.g. World capitals, Multiplication, Shakespeare',
                prefixIcon: Icon(Icons.topic_rounded),
              ),
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: (_) => _generate(context),
            ),
            const SizedBox(height: 16),
            _InfoChip(
              icon: Icons.school_rounded,
              label: 'Level',
              value: _expertiseLabel(userData.expertiseLevel ?? 'intermediate'),
            ),
            if (userData.age != null && userData.age!.isNotEmpty) ...[
              const SizedBox(height: 8),
              _InfoChip(
                icon: Icons.cake_rounded,
                label: 'Age',
                value: userData.age!,
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(
                _error!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
            const SizedBox(height: 32),
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
                'No API key set. Using sample questions for this topic.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () {
                Provider.of<QuizState>(context, listen: false).clearGeneratedQuestions();
                context.go('/quiz');
              },
              child: const Text('Use sample quiz instead'),
            ),
          ],
        ),
      ),
    );
  }

  String _expertiseLabel(String level) {
    switch (level) {
      case 'beginner':
        return 'Beginner';
      case 'advanced':
        return 'Advanced';
      default:
        return 'Intermediate';
    }
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
