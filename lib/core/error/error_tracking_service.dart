import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../logging/app_logger.dart';

/// Centralized error tracking service wrapping Sentry.
/// Set the DSN via [ErrorTrackingService.init] at app startup.
class ErrorTrackingService {
  static const _defaultDsn = String.fromEnvironment(
    'SENTRY_DSN',
    defaultValue: '',
  );

  /// Initialize Sentry (no-op if DSN empty or in debug mode)
  static Future<void> init({
    required FutureOr<void> Function() appRunner,
    String? dsn,
  }) async {
    final effectiveDsn = dsn ?? _defaultDsn;

    if (effectiveDsn.isEmpty || kDebugMode) {
      AppLogger.info('Error tracking disabled (no DSN or debug mode)');
      await appRunner();
      return;
    }

    await SentryFlutter.init(
      (options) {
        options.dsn = effectiveDsn;
        options.tracesSampleRate = 0.2;
        options.attachScreenshot = true;
        options.environment = kReleaseMode ? 'production' : 'staging';
      },
      appRunner: appRunner,
    );
  }

  /// Capture an exception with optional stack trace and context
  static Future<void> captureException(
    dynamic exception, {
    StackTrace? stackTrace,
    String? context,
  }) async {
    AppLogger.error(context ?? 'Unhandled exception', exception, stackTrace);

    if (_defaultDsn.isEmpty && !Sentry.isEnabled) return;

    await Sentry.captureException(
      exception,
      stackTrace: stackTrace,
      withScope: context != null
          ? (scope) => scope.setTag('context', context)
          : null,
    );
  }

  /// Capture a message (non-exception event)
  static Future<void> captureMessage(
    String message, {
    SentryLevel level = SentryLevel.info,
  }) async {
    if (!Sentry.isEnabled) return;
    await Sentry.captureMessage(message, level: level);
  }

  /// Set user context for error reports
  static void setUser({String? id, String? name, String? storeId}) {
    if (!Sentry.isEnabled) return;
    Sentry.configureScope((scope) {
      scope.setUser(SentryUser(
        id: id,
        username: name,
      ));
      if (storeId != null) {
        scope.setTag('store_id', storeId);
      }
    });
  }

  /// Clear user context (on logout)
  static void clearUser() {
    if (!Sentry.isEnabled) return;
    Sentry.configureScope((scope) => scope.setUser(null));
  }

  /// Add breadcrumb for debugging context
  static void addBreadcrumb({
    required String message,
    String? category,
    Map<String, dynamic>? data,
  }) {
    if (!Sentry.isEnabled) return;
    Sentry.addBreadcrumb(Breadcrumb(
      message: message,
      category: category,
      data: data,
      timestamp: DateTime.now(),
    ));
  }
}
