import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../common/sd_logger.dart';

/// One named step of a startup.
///
/// The name is what the log line says, so it reads as the sentence a person
/// would write: `Firebase`, `Google Sign-In`, `Billing`.
class SdBootstrapStep {
  const SdBootstrapStep({
    required this.name,
    required this.run,
  });

  /// What this step brings up, for the log.
  final String name;

  /// The work itself.
  final Future<void> Function() run;
}

/// Everything that happens before `runApp`, so an app's entry point stays a
/// list of *what* happens rather than *how*.
///
/// **This is the contract half.** Bringing up a crash reporter, an auth SDK
/// and a billing SDK is the same shape in every app of ours — an ordered list
/// of independent steps, each of which must be allowed to fail without taking
/// the launch with it — while the SDKs themselves are the host's and this
/// package imports none of them (`WIDGET_RULES.md`, "no vendor SDK, ever").
/// So the ordering, the guarding, the logging and the three error hooks live
/// here; the steps arrive as [SdBootstrapStep]s.
///
/// **Each step is guarded on its own; there is no `try` around all of them.**
/// The concerns are independent, and one `try` around the lot lets the first
/// failure skip everything after it — including the crash reporting that would
/// have named it. Put the reporter first for that reason.
///
/// **No step can refuse to start the app, and there is no flag to make one.**
/// An app that will not open is worse than almost anything it could be missing
/// — and it could not be built anyway: the guarded zone catches whatever a
/// step rethrows, so a `halt` would look like it worked while `runApp` was
/// silently skipped. A step whose absence makes the app useless says so on
/// screen, from inside the app.
///
/// **Three error channels, and missing one hides a whole class of crash:**
///
/// - `FlutterError.onError` — errors raised inside the widget tree;
/// - `PlatformDispatcher.instance.onError` — errors from outside it, which is
///   where an un-awaited `Future` that failed ends up;
/// - the guarded zone's own handler — anything the other two miss.
///
/// **Nothing slow belongs in [SdBootstrapStep].** Everything here runs before
/// the first frame, where the only thing on screen is the platform launch
/// image — so work a user could be shown a splash for belongs in a widget
/// above the app, not in this list.
final class SdBootstrap {
  const SdBootstrap._();

  /// Bring [steps] up in order inside a guarded zone, then `runApp` [builder].
  static Future<void> run({
    required String logTag,
    required List<SdBootstrapStep> steps,
    required Widget Function() builder,
  }) async {
    await runZonedGuarded<Future<void>>(
      () async {
        WidgetsFlutterBinding.ensureInitialized();

        for (final SdBootstrapStep step in steps) {
          await _runStep(logTag, step);
        }

        _installErrorHooks(logTag);

        runApp(builder());
      },
      (Object error, StackTrace stackTrace) {
        SdLogger.error(
          logTag,
          'Uncaught zone error',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );
  }

  static Future<void> _runStep(String logTag, SdBootstrapStep step) async {
    try {
      await step.run();

      SdLogger.info(logTag, 'Started', <String, String>{'step': step.name});
    } catch (error, stackTrace) {
      // The console line may be the whole report: the step that failed can be
      // the crash reporter itself, in which case there is nowhere to send it.
      SdLogger.error(
        logTag,
        'Failed to start',
        error: error,
        stackTrace: stackTrace,
        data: <String, String>{'step': step.name},
      );
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  static void _installErrorHooks(String logTag) {
    FlutterError.onError = (FlutterErrorDetails details) {
      SdLogger.error(
        logTag,
        'Flutter framework error',
        error: details.exception,
        stackTrace: details.stack,
      );
    };

    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      SdLogger.error(
        logTag,
        'Uncaught platform error',
        error: error,
        stackTrace: stack,
      );

      // True means "handled" — the process stays alive. It is already
      // reported, and killing the app would lose the user's unsaved work over
      // an error they may never have noticed.
      return true;
    };
  }
}
