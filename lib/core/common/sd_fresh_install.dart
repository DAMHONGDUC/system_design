import 'sd_logger.dart';

/// The key-value store the environment record lives in — `shared_preferences`
/// in a host app.
///
/// Implemented by the host over whatever it actually uses; this package stays
/// free of the plugin (see `WIDGET_RULES.md`, "no vendor SDK, ever").
abstract interface class SdFreshInstallStore {
  /// The value written by [writeString], or null when nothing has been.
  Future<String?> readString(String key);

  Future<void> writeString(String key, String value);

  /// Everything, including the environment record itself — a fresh install has
  /// no preferences, and that is what this is pretending to be.
  Future<void> clear();
}

/// One named step of a wipe.
///
/// The name is what the log line says, so it reads as the sentence a person
/// would write: `Sign out`, `Clear Firestore cache`.
class SdFreshInstallStep {
  const SdFreshInstallStep({required this.name, required this.run, this.when});

  /// What this step is, for the log.
  final String name;

  /// The work itself. A throw is caught and logged, never rethrown.
  final Future<void> Function() run;

  /// Whether the step applies to this launch — a build with no Firebase has
  /// nothing to sign out of. Absent means always.
  final bool Function()? when;
}

/// Everything [SdFreshInstall] cannot do for itself.
///
/// The guard owns the decision — *has the environment moved?* — and nothing
/// else. Where the answer is stored and what "wipe" means are the host's, and
/// they arrive here as three callbacks so that this package never imports a
/// storage plugin, a Firebase SDK or an app provider.
class SdFreshInstallPolicy {
  const SdFreshInstallPolicy({
    required this.readLastEnv,
    required this.writeEnv,
    required this.wipe,
  });

  /// The env name the last launch recorded, or null on a real fresh install.
  ///
  /// Null means "nothing to compare against" and never triggers a wipe: a
  /// first launch has nothing on the device to be wrong.
  final Future<String?> Function() readLastEnv;

  /// Record the env name this launch is running as.
  final Future<void> Function(String envName) writeEnv;

  /// Take the device back to what a fresh install would have had — signed out,
  /// no preferences, no cached documents.
  ///
  /// Both names are passed for the log line; a host that wipes different
  /// things depending on the direction is free to read them.
  final Future<void> Function(String? previous, String current) wipe;
}

/// Builds the [SdFreshInstallPolicy] every app of ours wants, so each one
/// supplies only the vendor calls its own wipe needs.
///
/// The shape was written twice before it moved here: read one string, write
/// one string, and run an ordered list of cleanups where a failure in any of
/// them must not take the launch with it. What differs per app is the plugin
/// behind the store and which SDKs have a session to drop — those arrive as
/// [SdFreshInstallStore] and [SdFreshInstallStep], the same way
/// [SdReinstallGuard] takes its two stores.
///
/// **The store is cleared last, after every step, and that is not
/// configurable.** It holds the environment record, so clearing it first would
/// leave a half-wiped device claiming an environment it no longer has — and
/// `SdFreshInstallGuard` writes the record only once the whole wipe returns,
/// so a wipe interrupted half way is repeated on the next launch rather than
/// skipped.
///
/// **Nothing here throws.** The wipe runs before the app's first frame, where
/// an uncaught throw is not an error screen but an app that never starts — and
/// a device that lost its cache but kept its session is a worse state than one
/// where both went.
final class SdFreshInstall {
  const SdFreshInstall._();

  /// [envKey] is the store key the record is kept under, and [logTag] is the
  /// caller's flow name so the lines land in the same story as its other
  /// storage work.
  static SdFreshInstallPolicy policy({
    required String logTag,
    required String envKey,
    required SdFreshInstallStore store,
    required List<SdFreshInstallStep> steps,
  }) => SdFreshInstallPolicy(
    readLastEnv: () => _readLastEnv(logTag, envKey, store),
    writeEnv: (String envName) => _writeEnv(logTag, envKey, store, envName),
    wipe: (String? previous, String current) =>
        _wipe(logTag, store, steps, previous, current),
  );

  static Future<String?> _readLastEnv(
    String logTag,
    String envKey,
    SdFreshInstallStore store,
  ) async {
    try {
      return await store.readString(envKey);
    } catch (error, stackTrace) {
      // Null reads as a first launch, which wipes nothing — the safe way to
      // be wrong here, since the alternative deletes a session over a storage
      // plugin that did not answer.
      SdLogger.error(
        logTag,
        'Could not read the recorded environment',
        error: error,
        stackTrace: stackTrace,
        data: <String, String>{'key': envKey},
      );

      return null;
    }
  }

  static Future<void> _writeEnv(
    String logTag,
    String envKey,
    SdFreshInstallStore store,
    String envName,
  ) async {
    try {
      await store.writeString(envKey, envName);

      SdLogger.info(logTag, 'Environment recorded', <String, String>{
        'env': envName,
      });
    } catch (error, stackTrace) {
      SdLogger.error(
        logTag,
        'Could not record the environment',
        error: error,
        stackTrace: stackTrace,
        data: <String, String>{'env': envName},
      );
    }
  }

  static Future<void> _wipe(
    String logTag,
    SdFreshInstallStore store,
    List<SdFreshInstallStep> steps,
    String? previous,
    String current,
  ) async {
    SdLogger.action(
      logTag,
      'Wipe device for environment change',
      <String, String>{'previous': previous ?? '—', 'current': current},
    );

    for (final SdFreshInstallStep step in steps) {
      await _runStep(logTag, step);
    }

    await _clearStore(logTag, store);
  }

  /// Each step guards itself, so the one that fails does not cost the app the
  /// ones after it.
  static Future<void> _runStep(String logTag, SdFreshInstallStep step) async {
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
        data: <String, String>{'step': step.name},
      );
    }
  }

  static Future<void> _clearStore(
    String logTag,
    SdFreshInstallStore store,
  ) async {
    try {
      await store.clear();

      SdLogger.info(logTag, 'Store cleared');
    } catch (error, stackTrace) {
      SdLogger.error(
        logTag,
        'Could not clear the store',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}
