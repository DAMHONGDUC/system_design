import 'sd_logger.dart';

/// What a step does when it fails.
///
/// A wipe runs after something has already gone wrong, so most of it is
/// best-effort: a device that lost its cache but kept its session is a worse
/// state than one where both went. The exception is a step the rest of the
/// wipe means nothing without.
enum SdDeviceWipeFailure {
  /// Log it and run the remaining steps anyway.
  carryOn,

  /// Stop and rethrow, so the caller does not record the wipe as done and the
  /// next launch tries again.
  halt,
}

/// One named step of a wipe.
///
/// The name is what the log line says, so it reads as the sentence a person
/// would write: `Sign out`, `Clear Firestore cache`.
class SdDeviceWipeStep {
  const SdDeviceWipeStep({
    required this.name,
    required this.run,
    this.when,
    this.onFailure = SdDeviceWipeFailure.carryOn,
  });

  /// What this step is, for the log.
  final String name;

  /// The work itself.
  final Future<void> Function() run;

  /// Whether the step applies to this launch — a build with no Firebase has
  /// nothing to sign out of. Absent means always.
  final bool Function()? when;

  /// What happens when [run] throws. See [SdDeviceWipeFailure].
  final SdDeviceWipeFailure onFailure;
}

/// Taking a device back to what a fresh install would have had — signed out,
/// no preferences, no cached documents.
///
/// **One wipe, several reasons to run it.** [SdFreshInstall] reaches it for
/// two: the app was deleted and installed again, or the build now talks to a
/// different environment. Those are found completely differently and then
/// have to *do* the same list of vendor calls in the same order, each one
/// guarded so that the step which fails does not cost the app the steps after
/// it. Written twice, it drifted twice.
///
/// **The steps are the host's and the ordering is the caller's.** This package
/// imports no storage plugin and no Firebase SDK (`WIDGET_RULES.md`, "no
/// vendor SDK, ever"), so signing out, clearing a cache and emptying a store
/// all arrive as [SdDeviceWipeStep]s.
final class SdDeviceWipe {
  const SdDeviceWipe._();

  /// Run [steps] in order, and say what happened.
  ///
  /// [reason] is why the wipe is running — it goes in the opening log line, so
  /// a device that was cleaned can be told from one that was not.
  ///
  /// **It throws only for a [SdDeviceWipeFailure.halt] step.** Everything else
  /// is logged and stepped over, because this runs before the app's first
  /// frame where an uncaught throw is not an error screen but an app that
  /// never starts.
  static Future<void> run({
    required String logTag,
    required String reason,
    required List<SdDeviceWipeStep> steps,
  }) async {
    SdLogger.action(logTag, 'Wipe device', <String, Object>{
      'reason': reason,
      'steps': steps.length,
    });

    for (final SdDeviceWipeStep step in steps) {
      await _runStep(logTag, step);
    }
  }

  static Future<void> _runStep(String logTag, SdDeviceWipeStep step) async {
    final bool Function()? when = step.when;

    if (when != null && !when()) {
      SdLogger.info(logTag, 'Wipe step skipped', <String, String>{
        'step': step.name,
      });

      return;
    }
    try {
      await step.run();

      SdLogger.info(logTag, 'Wipe step done', <String, String>{
        'step': step.name,
      });
    } catch (error, stackTrace) {
      SdLogger.error(
        logTag,
        'Wipe step failed',
        error: error,
        stackTrace: stackTrace,
        data: <String, String>{
          'step': step.name,
          'onFailure': step.onFailure.name,
        },
      );

      if (step.onFailure == SdDeviceWipeFailure.halt) rethrow;
    }
  }
}
