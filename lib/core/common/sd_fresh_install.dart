import 'sd_device_wipe.dart';
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
/// one string, and wipe when they differ. What differs per app is the plugin
/// behind the store and which SDKs have a session to drop — those arrive as
/// [SdFreshInstallStore] and [SdDeviceWipeStep].
///
/// **The wipe itself is [SdDeviceWipe] and is not written here.**
/// [SdReinstallGuard] runs the same one for a different reason.
///
/// **The store is cleared last, after every step, and that is not
/// configurable.** It holds the environment record, so clearing it first would
/// leave a half-wiped device claiming an environment it no longer has — and
/// `SdFreshInstallGuard` writes the record only once the whole wipe returns,
/// so a wipe interrupted half way is repeated on the next launch rather than
/// skipped.
final class SdFreshInstall {
  const SdFreshInstall._();

  /// [envKey] is the store key the record is kept under, and [logTag] is the
  /// caller's flow name so the lines land in the same story as its other
  /// storage work.
  static SdFreshInstallPolicy policy({
    required String logTag,
    required String envKey,
    required SdFreshInstallStore store,
    required List<SdDeviceWipeStep> steps,
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
    List<SdDeviceWipeStep> steps,
    String? previous,
    String current,
  ) => SdDeviceWipe.run(
    logTag: logTag,
    reason: 'Environment changed from ${previous ?? '—'} to $current',
    steps: <SdDeviceWipeStep>[
      ...steps,
      SdDeviceWipeStep(name: 'Clear the store', run: store.clear),
    ],
  );
}
