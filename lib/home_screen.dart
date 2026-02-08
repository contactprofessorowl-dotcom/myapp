import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'progress_state.dart';
import 'providers.dart';
import 'theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userData = Provider.of<UserData>(context);
    final userName = userData.name?.trim().isNotEmpty == true
        ? userData.name!.trim()
        : null;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          title: Text(
            'Flash',
            style: theme.appBarTheme.titleTextStyle,
          ),
          iconTheme: theme.appBarTheme.iconTheme,
          actions: [
            IconButton(
              icon: Icon(
                Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_rounded,
              ),
              onPressed: () =>
                  Provider.of<ThemeProvider>(context, listen: false).toggleTheme(),
              tooltip: 'Toggle light / dark mode',
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  userName != null ? 'Welcome $userName!' : 'Welcome!',
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 20),
                _ProgressCard(),
                const SizedBox(height: 24),
                _HeroStartCard(onTap: () => context.go('/generate-quiz')),
                const SizedBox(height: 28),
                Text(
                  'Select quiz type',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                _HomeCard(
                  icon: Icons.quiz_rounded,
                  title: 'Check your knowledge',
                  subtitle: 'Pick a topic and play. Quizzes adapt to your level.',
                  onTap: () => context.go('/generate-quiz'),
                  accentColor: FlashAccentColors.purple,
                ),
                const SizedBox(height: 12),
                _HomeCard(
                  icon: Icons.menu_book_rounded,
                  title: 'Check your vocabulary',
                  subtitle: 'Flashcards with definitions and terms by topic.',
                  onTap: () => context.go('/generate-vocabulary'),
                  accentColor: FlashAccentColors.blue,
                ),
                const SizedBox(height: 12),
                _HomeCard(
                  icon: Icons.record_voice_over_rounded,
                  title: 'Check your pronunciation',
                  subtitle: 'Coming soon.',
                  onTap: null,
                  accentColor: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Compact progress card: level, points, streak, daily goal. Accessible labels.
class _ProgressCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = Provider.of<ProgressState>(context);
    final level = progress.level;
    final points = progress.totalPoints;
    final streak = progress.currentStreak;
    final goalDone = progress.dailyGoalDone;

    return Semantics(
      label: 'Your progress. Level $level. $points points. $streak day streak. '
          'Today\'s goal: ${goalDone ? "Done" : "Complete one quiz"}.',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your progress',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 20,
              runSpacing: 12,
              children: [
                _ProgressChip(
                  icon: Icons.military_tech_rounded,
                  label: 'Level $level',
                  theme: theme,
                ),
                _ProgressChip(
                  icon: Icons.star_rounded,
                  label: '$points points',
                  theme: theme,
                ),
                _ProgressChip(
                  icon: Icons.local_fire_department_rounded,
                  label: streak == 0 ? 'No streak yet' : '$streak day streak',
                  theme: theme,
                ),
                _ProgressChip(
                  icon: goalDone ? Icons.check_circle_rounded : Icons.flag_rounded,
                  label: goalDone ? "Today's goal done" : "Today's goal: 1 quiz",
                  theme: theme,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressChip extends StatelessWidget {
  const _ProgressChip({
    required this.icon,
    required this.label,
    required this.theme,
  });

  final IconData icon;
  final String label;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 22, color: theme.colorScheme.primary),
        const SizedBox(width: 6),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

/// Large "Let's Start Now!" card with illustration area and CTA (reference-style hero).
class _HeroStartCard extends StatelessWidget {
  const _HeroStartCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Let's Start Now!",
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Play, learn and explore with exciting quizzes!',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: FlashAccentColors.purple.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.school_rounded,
                      size: 40,
                      color: FlashAccentColors.purple,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeCard extends StatelessWidget {
  const _HomeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.accentColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final enabled = onTap != null;

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: enabled ? 0.12 : 0.06),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, size: 28, color: enabled ? accentColor : theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: enabled ? null : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              if (enabled)
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
