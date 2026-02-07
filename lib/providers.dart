import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds the single SharedPreferences instance so we avoid channel calls in redirect.
class AppPrefs extends ChangeNotifier {
  SharedPreferences? _prefs;
  SharedPreferences? get prefs => _prefs;
  void setPrefs(SharedPreferences p) {
    _prefs = p;
    notifyListeners();
  }
}

const String _kUserNameKey = 'user_name';
const String _kUserAgeKey = 'user_age';
const String _kUserExpertiseKey = 'user_expertise';
const String _kOnboardingDoneKey = 'onboarding_done';

/// Expertise level for AI-generated content (e.g. quiz difficulty).
const List<String> kExpertiseLevels = ['beginner', 'intermediate', 'advanced'];

class UserData with ChangeNotifier {
  String? name;
  String? age;
  String? expertiseLevel;

  SharedPreferences? _prefs;

  bool get hasUserInfo =>
      (name != null && name!.trim().isNotEmpty) ||
      (age != null && age!.trim().isNotEmpty);

  /// Call once at app start after SharedPreferences is ready.
  Future<void> loadFromPrefs(SharedPreferences prefs) async {
    _prefs = prefs;
    name = prefs.getString(_kUserNameKey);
    age = prefs.getString(_kUserAgeKey);
    expertiseLevel = prefs.getString(_kUserExpertiseKey);
    notifyListeners();
  }

  void setUserData(String name, String age, [String? expertise]) {
    this.name = name.trim().isEmpty ? null : name.trim();
    this.age = age.trim().isEmpty ? null : age.trim();
    if (expertise != null) expertiseLevel = expertise.trim().isEmpty ? null : expertise;
    _prefs?.setString(_kUserNameKey, this.name ?? '');
    _prefs?.setString(_kUserAgeKey, this.age ?? '');
    if (expertiseLevel != null) _prefs?.setString(_kUserExpertiseKey, expertiseLevel!);
    notifyListeners();
  }

  void setExpertiseLevel(String level) {
    expertiseLevel = level;
    _prefs?.setString(_kUserExpertiseKey, level);
    notifyListeners();
  }

  /// Updates level based on quiz result. Call when user finishes a quiz.
  /// Rules: 80%+ correct may level up (beginner→intermediate→advanced);
  /// under 50% may level down one step.
  void updateLevelFromQuizResult(int correct, int total) {
    if (total <= 0) return;
    final level = expertiseLevel ?? 'intermediate';
    final pct = correct / total;
    if (pct >= 0.8) {
      if (level == 'beginner') {
        setExpertiseLevel('intermediate');
      } else if (level == 'intermediate') {
        setExpertiseLevel('advanced');
      }
    } else if (pct < 0.5) {
      if (level == 'advanced') {
        setExpertiseLevel('intermediate');
      } else if (level == 'intermediate') {
        setExpertiseLevel('beginner');
      }
    }
  }

  void clearUserData() {
    name = null;
    age = null;
    expertiseLevel = null;
    _prefs?.remove(_kUserNameKey);
    _prefs?.remove(_kUserAgeKey);
    _prefs?.remove(_kUserExpertiseKey);
    notifyListeners();
  }
}

/// Persists onboarding completion. Used by router redirect.
class OnboardingState {
  static const String key = _kOnboardingDoneKey;

  static Future<bool> isComplete(SharedPreferences prefs) async {
    return prefs.getBool(key) ?? false;
  }

  static Future<void> setComplete(SharedPreferences prefs) async {
    await prefs.setBool(key, true);
  }
}

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    notifyListeners();
  }

  void setSystemTheme() {
    _themeMode = ThemeMode.system;
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }
}
