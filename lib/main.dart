import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'quiz_screen.dart';
import 'results_screen.dart';
import 'home_screen.dart';
import 'settings_screen.dart';
import 'account_screen.dart';
import 'theme.dart';
import 'providers.dart';
import 'quiz_state.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => UserData()),
        ChangeNotifierProvider(create: (context) => QuizState()),
      ],
      child: const MyApp(),
    ),
  );
}

final GoRouter _router = GoRouter(
  routes: <RouteBase>[
    ShellRoute(
      builder: (BuildContext context, GoRouterState state, Widget child) {
        return ScaffoldWithNavBar(child: child);
      },
      routes: <RouteBase>[
        GoRoute(
          path: '/',
          builder: (BuildContext context, GoRouterState state) {
            return const HomeScreen();
          },
        ),
        GoRoute(
          path: '/settings',
          builder: (BuildContext context, GoRouterState state) {
            return const SettingsScreen();
          },
        ),
        GoRoute(
          path: '/account',
          builder: (BuildContext context, GoRouterState state) {
            return const AccountScreen();
          },
        ),
      ],
    ),
    GoRoute(
      path: '/quiz',
      builder: (BuildContext context, GoRouterState state) {
        return const QuizScreen();
      },
    ),
    GoRoute(
      path: '/results',
      builder: (BuildContext context, GoRouterState state) {
        return const ResultsScreen();
      },
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp.router(
          routerConfig: _router,
          title: 'Professor Owl',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeProvider.themeMode,
        );
      },
    );
  }
}

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      body: SafeArea(
        top: true,
        bottom: false,
        child: child,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  isSelected: _calculateSelectedIndex(context) == 0,
                  onTap: () => context.go('/'),
                ),
                _NavItem(
                  icon: Icons.settings_rounded,
                  label: 'Settings',
                  isSelected: _calculateSelectedIndex(context) == 1,
                  onTap: () => context.go('/settings'),
                ),
                _NavItem(
                  icon: Icons.person_rounded,
                  label: 'Account',
                  isSelected: _calculateSelectedIndex(context) == 2,
                  onTap: () => context.go('/account'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/settings')) return 1;
    if (location.startsWith('/account')) return 2;
    return 0;
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isSelected
        ? theme.bottomNavigationBarTheme.selectedItemColor ?? theme.primaryColor
        : theme.bottomNavigationBarTheme.unselectedItemColor ?? theme.disabledColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 26, color: color),
              const SizedBox(height: 4),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: color,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
