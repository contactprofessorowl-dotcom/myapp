import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Single achievement definition. Simple wording for all ages.
class Achievement {
  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
  });

  final String id;
  final String name;
  final String description;
  final IconData icon;

  static const List<Achievement> all = [
    Achievement(
      id: 'first_quiz',
      name: 'First quiz',
      description: 'Complete your first quiz.',
      icon: Icons.quiz_rounded,
    ),
    Achievement(
      id: 'quiz_5',
      name: 'Getting started',
      description: 'Complete 5 quizzes.',
      icon: Icons.star_rounded,
    ),
    Achievement(
      id: 'quiz_10',
      name: 'On a roll',
      description: 'Complete 10 quizzes.',
      icon: Icons.emoji_events_rounded,
    ),
    Achievement(
      id: 'perfect_score',
      name: 'Perfect score',
      description: 'Get every question right in a quiz.',
      icon: Icons.celebration_rounded,
    ),
    Achievement(
      id: 'streak_3',
      name: 'Three days in a row',
      description: 'Learn 3 days in a row.',
      icon: Icons.local_fire_department_rounded,
    ),
    Achievement(
      id: 'streak_7',
      name: 'Week of learning',
      description: 'Learn 7 days in a row.',
      icon: Icons.wb_sunny_rounded,
    ),
    Achievement(
      id: 'first_flashcards',
      name: 'First flashcards',
      description: 'Complete your first set of flashcards.',
      icon: Icons.menu_book_rounded,
    ),
    Achievement(
      id: 'flashcards_5',
      name: 'Vocabulary builder',
      description: 'Complete 5 flashcard sets.',
      icon: Icons.auto_stories_rounded,
    ),
  ];

  static Achievement? byId(String id) {
    try {
      return all.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }
}

/// Points per correct answer; bonus for perfect quiz.
const int kPointsPerCorrect = 10;
const int kPerfectQuizBonus = 25;

/// Points per flashcard set completed.
const int kPointsPerFlashcardSet = 15;

/// Level: every 100 points = 1 level. Level 1 at 0-99.
int levelFromPoints(int totalPoints) {
  if (totalPoints <= 0) return 1;
  return (totalPoints / 100).floor() + 1;
}

/// Points needed to reach a level (e.g. level 2 = 100).
int pointsNeededForLevel(int level) {
  if (level <= 1) return 0;
  return (level - 1) * 100;
}

/// Progress, points, streaks, and achievements. Persisted locally.
class ProgressState with ChangeNotifier {
  int _totalPoints = 0;
  int _currentStreak = 0;
  DateTime? _lastActivityDate;
  int _completedQuizzes = 0;
  int _completedFlashcardSets = 0;
  final Set<String> _unlockedAchievementIds = {};
  DateTime? _dailyGoalDate;
  bool _dailyGoalDone = false;

  SharedPreferences? _prefs;

  static const String _keyTotalPoints = 'progress_total_points';
  static const String _keyLastActivityDate = 'progress_last_activity_date';
  static const String _keyCurrentStreak = 'progress_current_streak';
  static const String _keyCompletedQuizzes = 'progress_completed_quizzes';
  static const String _keyCompletedSets = 'progress_completed_sets';
  static const String _keyAchievements = 'progress_achievements';
  static const String _keyDailyGoalDate = 'progress_daily_goal_date';
  static const String _keyDailyGoalDone = 'progress_daily_goal_done';

  int get totalPoints => _totalPoints;
  int get currentStreak => _currentStreak;
  int get completedQuizzes => _completedQuizzes;
  int get completedFlashcardSets => _completedFlashcardSets;
  Set<String> get unlockedAchievementIds => Set.unmodifiable(_unlockedAchievementIds);
  bool get dailyGoalDone => _dailyGoalDone;

  int get level => levelFromPoints(_totalPoints);
  int get pointsInCurrentLevel => _totalPoints - pointsNeededForLevel(level);
  int get pointsNeededForNextLevel => pointsNeededForLevel(level + 1) - pointsNeededForLevel(level);

  /// Call once at app start after SharedPreferences is ready.
  Future<void> loadFromPrefs(SharedPreferences prefs) async {
    _prefs = prefs;
    _totalPoints = prefs.getInt(_keyTotalPoints) ?? 0;
    _currentStreak = prefs.getInt(_keyCurrentStreak) ?? 0;
    _completedQuizzes = prefs.getInt(_keyCompletedQuizzes) ?? 0;
    _completedFlashcardSets = prefs.getInt(_keyCompletedSets) ?? 0;
    final dateStr = prefs.getString(_keyLastActivityDate);
    _lastActivityDate = dateStr != null ? DateTime.tryParse(dateStr) : null;
    _dailyGoalDate = null;
    final goalDateStr = prefs.getString(_keyDailyGoalDate);
    if (goalDateStr != null) _dailyGoalDate = DateTime.tryParse(goalDateStr);
    _dailyGoalDone = prefs.getBool(_keyDailyGoalDone) ?? false;
    final idsStr = prefs.getString(_keyAchievements);
    _unlockedAchievementIds.clear();
    if (idsStr != null && idsStr.isNotEmpty) {
      _unlockedAchievementIds.addAll(idsStr.split(',').where((s) => s.isNotEmpty));
    }
    _maybeResetDailyGoal();
    notifyListeners();
  }

  void _maybeResetDailyGoal() {
    final today = _today();
    if (_dailyGoalDate == null) return;
    if (_dailyGoalDate!.year != today.year ||
        _dailyGoalDate!.month != today.month ||
        _dailyGoalDate!.day != today.day) {
      _dailyGoalDate = null;
      _dailyGoalDone = false;
      _prefs?.remove(_keyDailyGoalDate);
      _prefs?.remove(_keyDailyGoalDone);
    }
  }

  DateTime _today() {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  void _save() {
    _prefs?.setInt(_keyTotalPoints, _totalPoints);
    _prefs?.setInt(_keyCurrentStreak, _currentStreak);
    _prefs?.setInt(_keyCompletedQuizzes, _completedQuizzes);
    _prefs?.setInt(_keyCompletedSets, _completedFlashcardSets);
    _prefs?.setString(_keyAchievements, _unlockedAchievementIds.join(','));
    if (_lastActivityDate != null) {
      _prefs?.setString(_keyLastActivityDate, _lastActivityDate!.toIso8601String());
    }
    if (_dailyGoalDate != null) {
      _prefs?.setString(_keyDailyGoalDate, _dailyGoalDate!.toIso8601String());
    }
    _prefs?.setBool(_keyDailyGoalDone, _dailyGoalDone);
  }

  void _updateStreak() {
    final today = _today();
    if (_lastActivityDate == null) {
      _currentStreak = 1;
      _lastActivityDate = today;
      return;
    }
    final last = DateTime(_lastActivityDate!.year, _lastActivityDate!.month, _lastActivityDate!.day);
    final diff = today.difference(last).inDays;
    if (diff == 0) {
      return;
    }
    if (diff == 1) {
      _currentStreak += 1;
      _lastActivityDate = today;
      return;
    }
    _currentStreak = 1;
    _lastActivityDate = today;
  }

  /// Returns list of newly unlocked achievement IDs this session.
  List<String> recordQuizCompleted(int correct, int total) {
    if (total <= 0) return [];
    final addedPoints = correct * kPointsPerCorrect;
    if (correct == total) {
      _totalPoints += addedPoints + kPerfectQuizBonus;
    } else {
      _totalPoints += addedPoints;
    }
    _completedQuizzes += 1;
    _updateStreak();
    _maybeResetDailyGoal();
    if (!_dailyGoalDone) {
      _dailyGoalDone = true;
      _dailyGoalDate = _today();
    }
    _save();
    final newlyUnlocked = _checkAchievementsAfterQuiz(correct, total);
    if (newlyUnlocked.isNotEmpty) notifyListeners();
    return newlyUnlocked;
  }

  List<String> _checkAchievementsAfterQuiz(int correct, int total) {
    final newly = <String>[];
    void tryUnlock(String id) {
      if (_unlockedAchievementIds.contains(id)) return;
      _unlockedAchievementIds.add(id);
      newly.add(id);
    }

    if (_completedQuizzes >= 1) tryUnlock('first_quiz');
    if (_completedQuizzes >= 5) tryUnlock('quiz_5');
    if (_completedQuizzes >= 10) tryUnlock('quiz_10');
    if (total > 0 && correct == total) tryUnlock('perfect_score');
    if (_currentStreak >= 3) tryUnlock('streak_3');
    if (_currentStreak >= 7) tryUnlock('streak_7');
    if (newly.isNotEmpty) _save();
    return newly;
  }

  /// Returns list of newly unlocked achievement IDs.
  List<String> recordFlashcardSetCompleted() {
    _totalPoints += kPointsPerFlashcardSet;
    _completedFlashcardSets += 1;
    _updateStreak();
    _maybeResetDailyGoal();
    _save();
    final newly = _checkAchievementsAfterFlashcards();
    if (newly.isNotEmpty) notifyListeners();
    return newly;
  }

  List<String> _checkAchievementsAfterFlashcards() {
    final newly = <String>[];
    void tryUnlock(String id) {
      if (_unlockedAchievementIds.contains(id)) return;
      _unlockedAchievementIds.add(id);
      newly.add(id);
    }
    if (_completedFlashcardSets >= 1) tryUnlock('first_flashcards');
    if (_completedFlashcardSets >= 5) tryUnlock('flashcards_5');
    if (_currentStreak >= 3) tryUnlock('streak_3');
    if (_currentStreak >= 7) tryUnlock('streak_7');
    if (newly.isNotEmpty) _save();
    return newly;
  }

  /// Clears all progress and achievements. Call when user logs out / starts fresh.
  void resetProgress() {
    _totalPoints = 0;
    _currentStreak = 0;
    _lastActivityDate = null;
    _completedQuizzes = 0;
    _completedFlashcardSets = 0;
    _unlockedAchievementIds.clear();
    _dailyGoalDate = null;
    _dailyGoalDone = false;
    if (_prefs != null) {
      _prefs!.remove(_keyTotalPoints);
      _prefs!.remove(_keyCurrentStreak);
      _prefs!.remove(_keyLastActivityDate);
      _prefs!.remove(_keyCompletedQuizzes);
      _prefs!.remove(_keyCompletedSets);
      _prefs!.remove(_keyAchievements);
      _prefs!.remove(_keyDailyGoalDate);
      _prefs!.remove(_keyDailyGoalDone);
    }
    notifyListeners();
  }

}
