import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'providers.dart';
import 'quiz_state.dart';

/// Gamification tiers for results, aligned with self-determination theory (competence feedback)
/// and growth mindset (Dweck): emphasize effort and progress, avoid fixed-ability framing.
/// Bands: mastery celebration (85%+), positive reinforcement (70–84%), encouraging (50–69%),
/// motivating / effort-focused (0–49%).
class _ResultTier {
  const _ResultTier({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.tagline,
    this.heroColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String tagline;
  final Color? heroColor;

  static _ResultTier forPercentage(int percentage) {
    if (percentage >= 85) {
      return const _ResultTier(
        icon: Icons.emoji_events_rounded,
        title: 'You nailed it!',
        subtitle: 'Strong mastery on this round. You’ve got this topic in your pocket.',
        tagline: 'Every correct answer builds lasting understanding.',
        heroColor: Color(0xFF0D7377),
      );
    }
    if (percentage >= 70) {
      return const _ResultTier(
        icon: Icons.celebration_rounded,
        title: 'Well done!',
        subtitle: 'You did a great job. Keep going and you’ll keep getting stronger.',
        tagline: 'Consistency is what turns learning into mastery.',
        heroColor: Color(0xFF0D7377),
      );
    }
    if (percentage >= 50) {
      return const _ResultTier(
        icon: Icons.trending_up_rounded,
        title: 'You’re getting there',
        subtitle: 'This round was tough, and you stuck with it. That’s what matters.',
        tagline: 'Each attempt strengthens your understanding.',
        heroColor: Color(0xFFF2A541),
      );
    }
    return const _ResultTier(
      icon: Icons.school_rounded,
      title: 'Learning is a journey',
      subtitle: 'This round was challenging. Take your time, review, and try again when you’re ready.',
      tagline: 'Every question you try is a step forward.',
      heroColor: Color(0xFF6B7280),
    );
  }
}

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final quizState = Provider.of<QuizState>(context);
    final score = quizState.score;
    final total = quizState.questionCount;
    final percentage = total > 0 ? (score / total * 100).round() : 0;
    final tier = _ResultTier.forPercentage(percentage);
    final heroColor = tier.heroColor ?? theme.colorScheme.primary;

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
                    const SizedBox(height: 28),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: heroColor.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        tier.icon,
                        size: 64,
                        color: heroColor,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      tier.title,
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      tier.subtitle,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.45,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      tier.tagline,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.9),
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    _ScoreCard(
                      score: score,
                      total: total,
                      percentage: percentage,
                      accentColor: heroColor,
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          Provider.of<UserData>(context, listen: false)
                              .updateLevelFromQuizResult(score, total);
                          quizState.resetQuiz();
                          context.go('/generate-quiz');
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
                        onPressed: () {
                          Provider.of<UserData>(context, listen: false)
                              .updateLevelFromQuizResult(score, total);
                          context.go('/');
                        },
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
    this.accentColor,
  });

  final int score;
  final int total;
  final int percentage;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = accentColor ?? theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: color.withValues(alpha: 0.35),
          width: 1.5,
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
                  color: color,
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
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
