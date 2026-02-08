import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

/// Central service for Firebase Analytics and Crashlytics.
/// Use via Provider or direct access after Firebase is initialized.
class FirebaseService {
  FirebaseService({
    FirebaseAnalytics? analytics,
    FirebaseCrashlytics? crashlytics,
  })  : _analytics = analytics ?? FirebaseAnalytics.instance,
        _crashlytics = crashlytics ?? FirebaseCrashlytics.instance;

  final FirebaseAnalytics _analytics;
  final FirebaseCrashlytics _crashlytics;

  FirebaseAnalytics get analytics => _analytics;
  FirebaseCrashlytics get crashlytics => _crashlytics;

  /// Log a screen view for Analytics.
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) {
    return _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenClass ?? screenName,
    );
  }

  /// Log a custom event for Analytics.
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) {
    return _analytics.logEvent(name: name, parameters: parameters);
  }

  /// Set the user ID for Analytics and Crashlytics.
  Future<void> setUserId(String? id) async {
    await _analytics.setUserId(id: id);
    if (id != null) {
      _crashlytics.setUserIdentifier(id);
    }
  }

  /// Record a non-fatal error to Crashlytics.
  Future<void> recordError(
    dynamic error,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
  }) {
    return _crashlytics.recordError(
      error,
      stackTrace,
      reason: reason,
      fatal: fatal,
    );
  }

  /// Add a log message that will be attached to the next crash report (breadcrumb).
  void log(String message) {
    _crashlytics.log(message);
  }

  /// Set a custom key that will be attached to the next crash report.
  Future<void> setCustomKey(String key, Object value) {
    return _crashlytics.setCustomKey(key, value);
  }
}
