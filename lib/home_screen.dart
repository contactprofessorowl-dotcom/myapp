import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'providers.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          title: Text(
            'Professor Owl',
            style: theme.appBarTheme.titleTextStyle,
          ),
          actions: [
            IconButton(
              icon: Icon(
                Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_rounded,
              ),
              onPressed: () =>
                  Provider.of<ThemeProvider>(context, listen: false).toggleTheme(),
              tooltip: 'Toggle theme',
            ),
            IconButton(
              icon: const Icon(Icons.settings_brightness_rounded),
              onPressed: () =>
                  Provider.of<ThemeProvider>(context, listen: false).setSystemTheme(),
              tooltip: 'Use system theme',
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Welcome!',
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Test your knowledge and learn something new. Pick a card below to get started.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _HomeCard(
                icon: Icons.quiz_rounded,
                title: 'Start quiz',
                subtitle: 'Answer questions and see how you do.',
                onTap: () => context.go('/quiz'),
                accentColor: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              _HomeCard(
                icon: Icons.person_rounded,
                title: 'My profile',
                subtitle: 'View and edit your account.',
                onTap: () => context.go('/account'),
                accentColor: theme.colorScheme.secondary,
              ),
            ]),
          ),
        ),
      ],
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
  final VoidCallback onTap;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: theme.brightness == Brightness.dark ? 0.2 : 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, size: 32, color: accentColor),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
