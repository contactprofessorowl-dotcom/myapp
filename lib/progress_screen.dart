import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'progress_state.dart';

/// Tab screen: Your progress (level, points, streak) and badges.
class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          title: Text(
            'Progress',
            style: theme.appBarTheme.titleTextStyle,
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Consumer<ProgressState>(
                builder: (context, progress, _) => _ProgressCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your progress',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _ProgressRow(
                        icon: Icons.military_tech_rounded,
                        label: 'Level',
                        value: '${progress.level}',
                        theme: theme,
                      ),
                      const SizedBox(height: 12),
                      _ProgressRow(
                        icon: Icons.star_rounded,
                        label: 'Total points',
                        value: '${progress.totalPoints}',
                        theme: theme,
                      ),
                      const SizedBox(height: 12),
                      _ProgressRow(
                        icon: Icons.local_fire_department_rounded,
                        label: 'Day streak',
                        value: progress.currentStreak == 0
                            ? 'None yet'
                            : '${progress.currentStreak} days',
                        theme: theme,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Consumer<ProgressState>(
                builder: (context, progress, _) => _ProgressCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Badges',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Earn badges by completing quizzes and flashcards.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...Achievement.all.map((a) {
                        final unlocked = progress.unlockedAchievementIds.contains(a.id);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                unlocked ? a.icon : Icons.lock_outline_rounded,
                                size: 28,
                                color: unlocked
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      a.name,
                                      style: theme.textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: unlocked
                                            ? theme.colorScheme.onSurface
                                            : theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      a.description,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ]),
          ),
        ),
      ],
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: child,
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.theme,
  });

  final IconData icon;
  final String label;
  final String value;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 22, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
