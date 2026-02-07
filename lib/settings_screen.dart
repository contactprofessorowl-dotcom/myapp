import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers.dart';
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          title: Text(
            'Settings',
            style: theme.appBarTheme.titleTextStyle,
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _SectionHeader(title: 'Appearance'),
              const SizedBox(height: 8),
              _SettingsCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Theme',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Choose light, dark, or match your device.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SegmentedButton<ThemeMode>(
                      segments: const [
                        ButtonSegment<ThemeMode>(
                          value: ThemeMode.light,
                          icon: Icon(Icons.light_mode_rounded),
                          label: Text('Light'),
                        ),
                        ButtonSegment<ThemeMode>(
                          value: ThemeMode.dark,
                          icon: Icon(Icons.dark_mode_rounded),
                          label: Text('Dark'),
                        ),
                        ButtonSegment<ThemeMode>(
                          value: ThemeMode.system,
                          icon: Icon(Icons.settings_brightness_rounded),
                          label: Text('System'),
                        ),
                      ],
                      selected: {themeProvider.themeMode},
                      onSelectionChanged: (Set<ThemeMode> selected) {
                        final mode = selected.first;
                        if (mode == ThemeMode.light) {
                          themeProvider.setThemeMode(ThemeMode.light);
                        } else if (mode == ThemeMode.dark) {
                          themeProvider.setThemeMode(ThemeMode.dark);
                        } else {
                          themeProvider.setSystemTheme();
                        }
                      },
                      style: ButtonStyle(
                        padding: WidgetStateProperty.all(
                          const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              _SectionHeader(title: 'About'),
              const SizedBox(height: 8),
              _SettingsCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.school_rounded,
                          size: 40,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Professor Owl',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'Learn and quiz with confidence.',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        title,
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: child,
    );
  }
}
