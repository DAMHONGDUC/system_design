import 'sd_device_wipe.dart';
import 'sd_logger.dart';

/// The store the OS deletes along with the app — `shared_preferences` on iOS.
///
/// Implemented by the host over whatever it actually uses; this package stays
/// free of the plugin (see `WIDGET_RULES.md`, "no vendor SDK, ever").
///
/// Every method is async because one host reads a loaded instance and another
/// awaits the plugin on each call. A synchronous store satisfies this by
/// returning an already-completed future; the reverse is not possible.
abstract interface class SdInstallScopedStore {
  /// Every key held right now, the stamp included.
  Future<Iterable<String>> getKeys();

  /// The raw value in whatever type it was written as — a legacy value is
  /// carried across by matching on that type.
  Future<Object?> get(String key);

  Future<String?> getString(String key);

  Future<void> setString(String key, String value);

  Future<void> remove(String key);

  /// Everything, the stamp included.
  Future<void> clear();
}

/// The store that outlives a delete — the iOS Keychain.
abstract interface class SdDeviceScopedStore {
  Future<Iterable<String>> getKeys();

  Future<void> setBool(String key, bool value);

  Future<void> setInt(String key, int value);

  Future<void> setDouble(String key, double value);

  Future<void> setString(String key, String value);

  /// Everything, in one call.
  Future<void> deleteAll();
}

/// The vendor calls a wipe is made of, supplied by the host.
///
/// **This is the contract half, and it is the whole point of it being here.**
/// Every app of ours wipes the same way — drop the session, drop the cached
/// documents, empty the stores — but the SDKs that do it are the host's, and
/// this package imports none of them (`WIDGET_RULES.md`, "no vendor SDK,
/// ever"). So the *shape and the order* live here, where a second app inherits
/// them, and only the two calls are written per app. Same split as
/// [SdCrashReporter]: the contract ships, the vendor does not.
abstract interface class SdFreshInstallHost {
  /// Whether the backend SDKs are up at all.
  ///
  /// False skips [signOut] and [clearCache] rather than guarding them at the
  /// call site — a build with no backend configured never initialised one, and
  /// reaching for it throws.
  bool get isBackendReady;

  /// End the session, everywhere it is held. A host with two sign-ins to make
  /// makes both here.
  Future<void> signOut();

  /// Drop whatever the backend cached on this device.
  Future<void> clearCache();
}

/// What [SdFreshInstall.run] found, and therefore what it did.
enum SdFreshInstallOutcome {
  /// The stamp matches this build. Nothing to do, and the common case.
  normalLaunch,

  /// Nothing on the device at all. There is nothing to be wrong, so nothing
  /// is wiped — a first launch is already a fresh install.
  firstInstall,

  /// An update from a build that predates the stamp. Its settings and its
  /// session are kept: nothing was deleted, so there is nothing to make fresh.
  update,

  /// The app was deleted and installed again, and state outlived it. Wiped.
  reinstall,

  /// This build talks to a different environment than the last one. Wiped.
  environmentChanged,
}

/// Taking a device back to what a fresh install would have had, and the two
/// things that mean it needs to be.
///
/// **One class, one stamp, one comparison.** This was three — a reinstall
/// guard, an environment guard and a widget holding the first frame — and they
/// turned out to be the same question asked twice: *does the state on this
/// device belong to the app that is now running?* The stamp is the build's
/// environment name, written into the store the OS deletes with the app, and
/// everything below is what its absence or its value means.
///
/// ```text
/// stamp == buildStamp ......................... normal launch, nothing to do
/// stamp is a different value .................. environment changed  → wipe
/// stamp absent, other keys present ............ update from an older build
/// stamp absent, device-scoped store not empty . reinstall            → wipe
/// stamp absent, nothing anywhere .............. first install
/// ```
///
/// **The stamp replaces a separate "has this install run before" marker**, and
/// that is what lets one comparison answer both. An install that predates the
/// stamp lands in the update row — by its own keys, whatever they are called —
/// so upgrading to this class never reads as a reinstall and never wipes a
/// real user's session.
///
/// **Two stores, and which one a value is in is the whole diagnosis.** iOS
/// keeps the Keychain when an app is deleted, so the auth session came back on
/// the next install and the user was still signed in; the install-scoped store
/// is the opposite, which is exactly why the stamp lives there and nowhere
/// else. A host with nothing that survives a delete passes no
/// [SdDeviceScopedStore] and the reinstall row simply cannot fire.
///
/// **It runs before `runApp`, and the host awaits it.** There is no widget:
/// the wipe signs the seller out and clears a database cache, and Firestore's
/// `clearPersistence` throws `failed-precondition` once its client is running,
/// so the work has to finish before the first screen can start reading.
///
/// **It never throws.** Before the first frame an uncaught throw is not an
/// error screen but an app that does not start, so every branch is guarded and
/// logged — see [SdDeviceWipe].
final class SdFreshInstall {
  const SdFreshInstall._();

  /// The key the stamp is written under, unless the host names another.
  static const String defaultStampKey = 'sd_fresh_install_stamp';

  /// Decide what this device is, act on it, and say which it was.
  ///
  /// [buildStamp] is what this binary is — `dev`, `staging`, `prod` — compared
  /// verbatim against what the last launch recorded. [host] makes the vendor
  /// calls; the order they run in is decided here, not there.
  ///
  /// **The stamp is written last.** A wipe clears the store the stamp lives
  /// in, so writing first would leave the device claiming an environment whose
  /// data has just been deleted — and a wipe that halted is repeated on the
  /// next launch rather than skipped.
  static Future<SdFreshInstallOutcome> run({
    required String logTag,
    required String buildStamp,
    required SdInstallScopedStore installScoped,
    required SdFreshInstallHost host,
    SdDeviceScopedStore? deviceScoped,
    String stampKey = defaultStampKey,
  }) async {
    try {
      final SdFreshInstallOutcome outcome = await _decide(
        logTag,
        buildStamp,
        installScoped,
        deviceScoped,
        stampKey,
      );

      SdLogger.action(logTag, 'Device checked', <String, String>{
        'outcome': outcome.name,
        'build': buildStamp,
      });

      await _act(
        logTag,
        outcome,
        buildStamp,
        installScoped,
        deviceScoped,
        host,
        stampKey,
      );

      return outcome;
    } catch (error, stackTrace) {
      // The app still starts: a device that could not be checked is the one
      // the user is holding, and a white screen tells them nothing. The stamp
      // is not written, so the next launch tries the whole thing again.
      SdLogger.error(
        logTag,
        'Fresh install check failed — starting on whatever is on the device',
        error: error,
        stackTrace: stackTrace,
        data: <String, String>{'build': buildStamp},
      );

      return SdFreshInstallOutcome.normalLaunch;
    }
  }

  /// Read the stamp and the two stores, and name what this launch is.
  static Future<SdFreshInstallOutcome> _decide(
    String logTag,
    String buildStamp,
    SdInstallScopedStore installScoped,
    SdDeviceScopedStore? deviceScoped,
    String stampKey,
  ) async {
    final String? stamp = await installScoped.getString(stampKey);

    if (stamp == buildStamp) return SdFreshInstallOutcome.normalLaunch;

    if (stamp != null) {
      SdLogger.warning(logTag, 'Environment changed', <String, String>{
        'previous': stamp,
        'current': buildStamp,
      });

      return SdFreshInstallOutcome.environmentChanged;
    }
    // Keys other than the stamp mean an install that predates it — an update,
    // not a reinstall. Checked before the Keychain, because an update leaves
    // both stores full and only this one tells them apart.
    if (await _hasOtherKeys(installScoped, stampKey)) {
      return SdFreshInstallOutcome.update;
    }
    if (deviceScoped != null && (await deviceScoped.getKeys()).isNotEmpty) {
      return SdFreshInstallOutcome.reinstall;
    }

    return SdFreshInstallOutcome.firstInstall;
  }

  /// Wipe, adopt or do nothing, then stamp the device.
  static Future<void> _act(
    String logTag,
    SdFreshInstallOutcome outcome,
    String buildStamp,
    SdInstallScopedStore installScoped,
    SdDeviceScopedStore? deviceScoped,
    SdFreshInstallHost host,
    String stampKey,
  ) async {
    switch (outcome) {
      case SdFreshInstallOutcome.normalLaunch:
        return;
      case SdFreshInstallOutcome.reinstall:
      case SdFreshInstallOutcome.environmentChanged:
        await SdDeviceWipe.run(
          logTag: logTag,
          reason: outcome.name,
          steps: _steps(host, installScoped, deviceScoped),
        );
      case SdFreshInstallOutcome.update:
        await _adopt(logTag, installScoped, deviceScoped, stampKey);
      case SdFreshInstallOutcome.firstInstall:
        break;
    }

    await installScoped.setString(stampKey, buildStamp);
  }

  /// The whole wipe, in the order it has to run.
  ///
  /// **Session first, then the caches, then the stores.** Signing out while a
  /// database client is still writing is how a wipe races itself, and a step
  /// that reads a preference has to run before the preferences go.
  ///
  /// The device-scoped clear halts the wipe if it fails: on a reinstall it is
  /// the only thing there is to remove, so leaving the stamp unwritten and
  /// trying again next launch beats recording a wipe that did not happen.
  static List<SdDeviceWipeStep> _steps(
    SdFreshInstallHost host,
    SdInstallScopedStore installScoped,
    SdDeviceScopedStore? deviceScoped,
  ) => <SdDeviceWipeStep>[
    SdDeviceWipeStep(
      name: 'Sign out',
      when: () => host.isBackendReady,
      run: host.signOut,
    ),
    SdDeviceWipeStep(
      name: 'Clear the backend cache',
      when: () => host.isBackendReady,
      run: host.clearCache,
    ),
    if (deviceScoped != null)
      SdDeviceWipeStep(
        name: 'Clear the device-scoped store',
        run: deviceScoped.deleteAll,
        onFailure: SdDeviceWipeFailure.halt,
      ),
    SdDeviceWipeStep(
      name: 'Clear the install-scoped store',
      run: installScoped.clear,
    ),
  ];

  /// An update from a build that kept its settings in the install-scoped
  /// store: the same values, moved into the store that now owns them.
  ///
  /// **Only when there is somewhere to move them to.** A host with no
  /// device-scoped store leaves its keys exactly where they are — they are the
  /// user's settings, and this is an update, so nothing about them is stale.
  ///
  /// Idempotent, because a crash before the stamp is written repeats it.
  static Future<void> _adopt(
    String logTag,
    SdInstallScopedStore installScoped,
    SdDeviceScopedStore? deviceScoped,
    String stampKey,
  ) async {
    if (deviceScoped == null) return;

    final List<String> legacy = await _otherKeys(installScoped, stampKey);

    // The key NAMES are logged, not their values: which keys survived is the
    // whole diagnosis when an update is misread, and a name says nothing
    // about the user.
    SdLogger.info(logTag, 'Adopting legacy settings', <String, Object>{
      'keys': legacy,
    });

    for (final String key in legacy) {
      await _carry(logTag, installScoped, deviceScoped, key);
    }
    // One owner per value: the copies left behind would be read by nothing and
    // outlive the ones that matter.
    for (final String key in legacy) {
      await installScoped.remove(key);
    }
  }

  static Future<void> _carry(
    String logTag,
    SdInstallScopedStore installScoped,
    SdDeviceScopedStore deviceScoped,
    String key,
  ) async {
    final Object? value = await installScoped.get(key);

    switch (value) {
      case final bool value:
        await deviceScoped.setBool(key, value);
      case final int value:
        await deviceScoped.setInt(key, value);
      case final double value:
        await deviceScoped.setDouble(key, value);
      case final String value:
        await deviceScoped.setString(key, value);
      default:
        // Nothing an app of ours writes is a string list, so anything else is
        // not ours to carry.
        SdLogger.warning(logTag, 'Legacy key not carried', <String, String>{
          'key': key,
        });
    }
  }

  static Future<bool> _hasOtherKeys(
    SdInstallScopedStore installScoped,
    String stampKey,
  ) async => (await _otherKeys(installScoped, stampKey)).isNotEmpty;

  static Future<List<String>> _otherKeys(
    SdInstallScopedStore installScoped,
    String stampKey,
  ) async => (await installScoped.getKeys())
      .where((String key) => key != stampKey)
      .toList(growable: false);
}
