import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'quiz_state.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final quizState = Provider.of<QuizState>(context);
    final score = quizState.score;
    final total = quizState.questionCount;
    final percentage = total > 0 ? (score / total * 100).round() : 0;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    Icon(
                      percentage >= 70 ? Icons.celebration_rounded : Icons.school_rounded,
                      size: 72,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      percentage >= 70 ? 'Well done!' : 'Keep learning!',
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      percentage >= 70
                          ? 'You did a great job on this quiz.'
                          : 'Review the questions and try again when you\'re ready.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    _ScoreCard(
                      score: score,
                      total: total,
                      percentage: percentage,
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          quizState.resetQuiz();
                          context.go('/');
                        },
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                        ),
                        child: const Text('Take another quiz'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => context.go('/'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                        ),
                        child: const Text('Back to home'),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({
    required this.score,
    required this.total,
    required this.percentage,
  });

  final int score;
  final int total;
  final int percentage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isHighScore = percentage >= 70;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            'Your score',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$score',
                style: theme.textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              Text(
                ' / $total',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$percentage%',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: isHighScore
                  ? const Color(0xFF0D7377)
                  : theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
