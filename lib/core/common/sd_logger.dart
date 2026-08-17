import 'package:logger/logger.dart';

import 'sd_crash_reporter.dart';

/// App-wide logger — the single funnel every error in the app passes through.
///
/// Two destinations, and this class is the fork:
///
/// ```text
/// SdLogger.error(...)
///        │
///   ┌────┴────┐
///   ▼         ▼
/// debug    SdCrashReporter
/// console  (non-fatal)
/// ```
///
/// **Debug builds print; release builds report.** The console sink is gated
/// on [enabled], which is true only when asserts run — so nothing is printed
/// in profile or release, and nothing a developer typed into a log message
/// can leak from a shipped binary. [error] additionally hands the failure to
/// [SdCrashReporter], which is a no-op until the app attaches a real one.
///
/// **Never log a password, a token, an OAuth secret or a buyer's address.**
/// Production errors go to a third-party service, and a log line is the
/// easiest way for a credential to end up there. Log the *shape* of a
/// failure ('marketplace token refresh failed'), never its contents.
///
/// Categories, picked by intent so the console reads as a story of what the
/// app is doing:
/// - [action]  — a user-driven action ('item created', 'order shipped')
/// - [info]    — notable state or flow ('workspace switched')
/// - [warning] — recoverable oddities ('sync retried')
/// - [error]   — a caught failure, with its error object and stack trace
/// - [debug]   — fine detail while chasing something down
///
/// **Every call names its flow first, and the tag is required.** A console
/// reads as interleaved lines from everything the app is doing at once; the
/// tag is what turns that back into one story:
///
/// ```text
/// Login - sign-in started — {provider: apple}
/// Login - sign-in succeeded — {uid: 3f9…}
/// Create Order - order created — {id: ord-4, items: 3}
/// ```
///
/// Filtering the console on `Login - ` then shows that flow and nothing else.
/// Pass a constant, never a literal typed at the call site — 'Login' and
/// 'login' are two flows to a text filter and one flow to a reader.
final class SdLogger {
  /// True only in debug builds (asserts run) — the on/off switch for console
  /// output. Mutable so tests can silence it.
  static bool enabled = _assertsEnabled();

  static final Logger _logger = Logger(
    filter: ProductionFilter(),
    printer: PrettyPrinter(methodCount: 0, colors: false, printEmojis: false),
  );

  static void action(String tag, String message, [Object? data]) {
    if (!enabled) return;
    _logger.i(_compose('🎯 $tag', message, data));
  }

  static void info(String tag, String message, [Object? data]) {
    if (!enabled) return;
    _logger.i(_compose(tag, message, data));
  }

  static void debug(String tag, String message, [Object? data]) {
    if (!enabled) return;
    _logger.d(_compose(tag, message, data));
  }

  static void warning(String tag, String message, [Object? data]) {
    if (!enabled) return;
    _logger.w(_compose(tag, message, data));
  }

  /// A caught failure. Prints in debug, and reports a non-fatal through
  /// [SdCrashReporter] in every build.
  ///
  /// [tag] is the flow this failure happened in, and it is carried into the
  /// crash report too — a report titled 'Login - token exchange failed' is
  /// findable in a dashboard; 'token exchange failed' is not.
  ///
  /// [message] says *what was being attempted*, not what went wrong — the
  /// error object already carries that, and 'failed to load inventory' is
  /// what makes a report findable six weeks later.
  ///
  /// [data] is what the call was doing — the arguments, the collection, the
  /// record id. Without it a report says a save failed but not which save,
  /// and the only way to find out is to reproduce the run. **Never a
  /// credential or a buyer address** (hard rule 9): the id, the key name, the
  /// count.
  static void error(
    String tag,
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Object? data,
  }) {
    final String composed = _compose(tag, message, data);

    if (enabled) {
      _logger.e(composed, error: error, stackTrace: stackTrace);
    }

    SdCrashReporter.instance.recordError(
      composed,
      error: error,
      stackTrace: stackTrace,
    );
  }

  static String _compose(String tag, String message, Object? data) =>
      data == null ? '$tag - $message' : '$tag - $message — $data';

  /// Pure-Dart debug-mode check: the assignment only runs when asserts are on,
  /// so this is true in debug and false in release/profile — no `dart:ui` or
  /// Flutter import needed, which keeps this callable from `domain/`.
  static bool _assertsEnabled() {
    bool enabled = false;
    assert(enabled = true);

    return enabled;
  }
}
