import 'dart:ui' as ui;

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'account_screen.dart';
import 'firebase_options.dart';
import 'generate_quiz_screen.dart';
import 'generate_vocabulary_screen.dart';
import 'home_screen.dart';
import 'legal/privacy_policy_screen.dart';
import 'legal/terms_screen.dart';
import 'onboarding_screen.dart';
import 'providers.dart';
import 'quiz_screen.dart';
import 'quiz_state.dart';
import 'results_screen.dart';
import 'services/ai_service.dart';
import 'services/firebase_service.dart';
import 'settings_screen.dart';
import 'splash_screen.dart';
import 'theme.dart';
import 'vocabulary_cards_screen.dart';
import 'vocabulary_complete_screen.dart';
import 'vocabulary_state.dart';
import 'welcome_screen.dart';

/// Set your Gemini API key here for local development (do not commit this file with a real key).
/// Get a key at https://aistudio.google.com/apikey
/// Alternative: run with --dart-define=GEMINI_API_KEY=your_key
const String _kGeminiApiKey = 'AIzaSyDVICd_uScmQGnTCYOychebZ4UwglybnVM'; // Add your key here; get one at https://aistudio.google.com/apikey

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (replace firebase_options.dart via: dart run flutterfire_cli:flutterfire configure)
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Pass Flutter framework errors to Crashlytics
  FlutterError.onError = (details) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(details);
  };

  // Pass uncaught async errors to Crashlytics
  ui.PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // Edge-to-edge: background extends into status bar area (transparent status bar).
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AppPrefs()),
        ChangeNotifierProvider(create: (_) => UserData()),
        ChangeNotifierProvider(create: (_) => QuizState()),
        ChangeNotifierProvider(create: (_) => VocabularyState()),
        Provider<FirebaseService>(create: (_) => FirebaseService()),
        Provider<AiService>(
          create: (_) => AiService(
            apiKey: String.fromEnvironment('GEMINI_API_KEY', defaultValue: _kGeminiApiKey),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Flash',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeProvider.themeMode,
          home: const _AppLoader(),
        );
      },
    );
  }
}

/// Loads SharedPreferences and UserData, then shows router or splash.
class _AppLoader extends StatefulWidget {
  const _AppLoader();

  @override
  State<_AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<_AppLoader> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    // Defer until after first frame so platform channel is ready (fixes Android channel-error).
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    SharedPreferences? prefs;
    for (var i = 0; i < 3; i++) {
      try {
        prefs = await SharedPreferences.getInstance();
        break;
      } catch (e) {
        if (i == 2) rethrow;
        await Future<void>.delayed(const Duration(milliseconds: 150));
      }
    }
    if (prefs == null || !mounted) return;
    Provider.of<AppPrefs>(context, listen: false).setPrefs(prefs);
    await Provider.of<UserData>(context, listen: false).loadFromPrefs(prefs);
    if (!mounted) return;
    // Yield so the transition to the main app happens next frame (reduces "Skipped N frames").
    await Future<void>.delayed(Duration.zero);
    if (!mounted) return;
    setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const SplashScreen();
    }
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp.router(
          routerConfig: _router,
          title: 'Flash',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeProvider.themeMode,
        );
      },
    );
  }
}

String? _redirect(BuildContext context, GoRouterState state) {
  final prefs = Provider.of<AppPrefs>(context, listen: false).prefs;
  if (prefs == null) return null;

  final onboardingDone = prefs.getBool(OnboardingState.key) ?? false;
  final userName = prefs.getString('user_name') ?? '';

  final path = state.uri.path;

  if (!onboardingDone && path != '/onboarding') {
    return '/onboarding';
  }
  if (onboardingDone && userName.trim().isEmpty && path != '/welcome' && path != '/onboarding' && !path.startsWith('/legal')) {
    return '/welcome';
  }
  return null;
}

/// Logs route changes to Firebase Analytics as screen views.
class _AnalyticsRouteObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    final name = route.settings.name ?? 'unknown';
    FirebaseAnalytics.instance.logScreenView(screenName: name, screenClass: name);
  }
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  redirect: _redirect,
  observers: [_AnalyticsRouteObserver()],
  routes: <RouteBase>[
    GoRoute(
      path: '/onboarding',
      builder: (_, __) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/welcome',
      builder: (_, __) => const WelcomeScreen(),
    ),
    ShellRoute(
      builder: (BuildContext context, GoRouterState state, Widget child) {
        return ScaffoldWithNavBar(child: child);
      },
      routes: <RouteBase>[
        GoRoute(
          path: '/',
          builder: (_, __) => const HomeScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (_, __) => const SettingsScreen(),
        ),
        GoRoute(
          path: '/account',
          builder: (_, __) => const AccountScreen(),
        ),
        GoRoute(
          path: '/legal/terms',
          builder: (_, __) => const TermsScreen(),
        ),
        GoRoute(
          path: '/legal/privacy',
          builder: (_, __) => const PrivacyPolicyScreen(),
        ),
        GoRoute(
          path: '/generate-quiz',
          builder: (_, __) => const GenerateQuizScreen(),
        ),
        GoRoute(
          path: '/generate-vocabulary',
          builder: (_, __) => const GenerateVocabularyScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/quiz',
      builder: (_, __) => const QuizScreen(),
    ),
    GoRoute(
      path: '/results',
      builder: (_, __) => const ResultsScreen(),
    ),
    GoRoute(
      path: '/vocabulary-cards',
      builder: (_, __) => const VocabularyCardsScreen(),
    ),
    GoRoute(
      path: '/vocabulary-complete',
      builder: (_, __) => const VocabularyCompleteScreen(),
    ),
  ],
);

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
