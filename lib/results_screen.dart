import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'progress_state.dart';
import 'providers.dart';
import 'quiz_state.dart';
import 'theme.dart';

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
        heroColor: Color(0xFF7C3AED),
      );
    }
    if (percentage >= 70) {
      return const _ResultTier(
        icon: Icons.celebration_rounded,
        title: 'Well done!',
        subtitle: 'You did a great job. Keep going and you’ll keep getting stronger.',
        tagline: 'Consistency is what turns learning into mastery.',
        heroColor: Color(0xFF7C3AED),
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

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  int? _pointsEarned;
  List<String> _newBadgeIds = [];
  bool _recorded = false;

  void _recordProgress(BuildContext context) {
    if (_recorded) return;
    _recorded = true;
    final quizState = Provider.of<QuizState>(context, listen: false);
    final progress = Provider.of<ProgressState>(context, listen: false);
    final score = quizState.score;
    final total = quizState.questionCount;
    if (total <= 0) return;
    final earned = score * kPointsPerCorrect + (score == total ? kPerfectQuizBonus : 0);
    final newBadges = progress.recordQuizCompleted(score, total);
    if (mounted) {
      setState(() {
        _pointsEarned = earned;
        _newBadgeIds = newBadges;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final quizState = Provider.of<QuizState>(context);
    final score = quizState.score;
    final total = quizState.questionCount;
    final percentage = total > 0 ? (score / total * 100).round() : 0;
    final tier = _ResultTier.forPercentage(percentage);
    final heroColor = tier.heroColor ?? theme.colorScheme.primary;

    WidgetsBinding.instance.addPostFrameCallback((_) => _recordProgress(context));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz results'),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Semantics(
                  header: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Your result',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Here\'s how you did.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Semantics(
                            label: 'Questions answered: $score out of $total',
                            child: _SummaryCard(
                              icon: Icons.quiz_rounded,
                              value: '$score / $total',
                              label: 'Questions answered',
                              accentColor: FlashAccentColors.purple,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Semantics(
                            label: 'Score: $percentage percent',
                            child: _SummaryCard(
                              icon: Icons.percent_rounded,
                              value: '$percentage%',
                              label: 'Score',
                              accentColor: FlashAccentColors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _ResultHeroCard(
                      tier: tier,
                      heroColor: heroColor,
                      theme: theme,
                    ),
                    const SizedBox(height: 16),
                    Semantics(
                      label: 'Score bar: $percentage percent',
                      value: '$percentage%',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: percentage / 100,
                          minHeight: 8,
                          backgroundColor: theme.colorScheme.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation<Color>(heroColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      tier.tagline,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.9),
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (_pointsEarned != null) ...[
                      const SizedBox(height: 16),
                      Semantics(
                        label: 'You earned $_pointsEarned points',
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.star_rounded, size: 22, color: theme.colorScheme.primary),
                              const SizedBox(width: 8),
                              Text(
                                'You earned +$_pointsEarned points',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    if (_newBadgeIds.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      ..._newBadgeIds.map((id) {
                        final a = Achievement.byId(id);
                        if (a == null) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Semantics(
                            label: 'New badge: ${a.name}. ${a.description}',
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(a.icon, size: 24, color: theme.colorScheme.primary),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    'New badge: ${a.name}',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: theme.colorScheme.primary,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                    const Spacer(),
                    Semantics(
                      button: true,
                      label: 'Take another quiz',
                      child: SizedBox(
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
                    ),
                    const SizedBox(height: 12),
                    Semantics(
                      button: true,
                      label: 'Back to home',
                      child: SizedBox(
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

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.accentColor,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 28, color: accentColor),
          const SizedBox(height: 12),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultHeroCard extends StatelessWidget {
  const _ResultHeroCard({
    required this.tier,
    required this.heroColor,
    required this.theme,
  });

  final _ResultTier tier;
  final Color heroColor;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: heroColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: heroColor.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: heroColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(tier.icon, size: 40, color: heroColor),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tier.title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  tier.subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

