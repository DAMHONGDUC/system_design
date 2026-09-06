import 'sd_logger.dart';

/// The store the OS deletes along with the app — `shared_preferences` on iOS.
///
/// Implemented by the host app over whatever it actually uses; this package
/// stays free of the plugin (see `WIDGET_RULES.md`, "no vendor SDK, ever").
abstract interface class SdInstallScopedStore {
  /// Every key held right now, the guard's own marker included.
  Iterable<String> getKeys();

  /// The raw value in whatever type it was written as — [SdFreshInstallGuard] carries a legacy value over by matching on that type.
  Object? get(String key);

  bool? getBool(String key);

  Future<void> setBool(String key, bool value);

  Future<void> remove(String key);
}

/// The store that outlives a delete — the iOS Keychain.
abstract interface class SdDeviceScopedStore {
  Iterable<String> getKeys();

  Future<void> setBool(String key, bool value);

  Future<void> setInt(String key, int value);

  Future<void> setDouble(String key, double value);

  Future<void> setString(String key, String value);

  /// Everything, in one call.
  Future<void> deleteAll();
}

/// Makes deleting the app and installing it again behave like a first install (owner's rule).
///
/// iOS keeps the Keychain when an app is deleted, so the auth session — and everything else in the [SdDeviceScopedStore] — came back on the next install and the user was still signed in. The [SdInstallScopedStore] is the opposite: iOS deletes it with the app, which is exactly why the marker below lives there and nowhere else.
///
/// ```text
/// delete + reinstall          update over an old build
/// install-scoped: {}          install-scoped: {onboarding_completed: true, alert_threshold: 7.0}
/// device-scoped:  {locale}    device-scoped:  {}
///        ▼                            ▼
/// purge: signOut + deleteAll   adopt: copy the 2 keys across, then drop them
/// ```
final class SdFreshInstallGuard {
  const SdFreshInstallGuard._();

  /// The one install-scoped key the app should keep. True = this install has run before; absent (which reads as false) = the device-scoped store is speaking for an install that no longer exists, because a delete takes the install-scoped one with it.
  static const String isInstalledKey = 'is_installed';

  /// Runs before a new session is created, so a purge is not immediately followed by signing the old user back in. [signOut] is the host app's own (`FirebaseAuth.instance.signOut` in the migraine tracker) — passed in because the session is the one thing here a unit test cannot have. [logTag] is the caller's flow name, so the lines land in the same story as the rest of its storage work.
  ///
  /// Never throws: a cleanup that fails must not take the launch with it, and every branch logs what it decided.
  static Future<void> run({
    required String logTag,
    required SdInstallScopedStore installScoped,
    required SdDeviceScopedStore deviceScoped,
    required Future<void> Function() signOut,
  }) async {
    if (installScoped.getBool(isInstalledKey) ?? false) return;

    // Keys other than the marker mean an install that predates it — an update, not a reinstall. An update keeps its settings AND its session (owner's rule): nothing was deleted, so there is nothing to make fresh.
    final List<String> legacy = installScoped
        .getKeys()
        .where((String key) => key != isInstalledKey)
        .toList();

    // The key NAMES are logged, not their values: which keys survived is the whole diagnosis when a reinstall is misread as an update, and a key name says nothing about the user.
    SdLogger.action(logTag, 'First launch of this install', {
      'isUpgrade': legacy.isNotEmpty,
      'legacyKeys': legacy,
      'hasDeviceScopedValues': deviceScoped.getKeys().isNotEmpty,
    });
    try {
      if (legacy.isEmpty) {
        await _purge(logTag, deviceScoped, signOut);
      } else {
        await _adopt(logTag, installScoped, legacy, deviceScoped);
      }
      // Last, so a crash anywhere above is retried on the next launch rather than skipped.
      await installScoped.setBool(isInstalledKey, true);
      if (legacy.isNotEmpty) await _dropLegacy(installScoped, legacy);
    } catch (error, stackTrace) {
      SdLogger.error(
        logTag,
        'First-launch guard failed',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// A reinstall: the device-scoped store is all that survived, so it is all there is to clear. The session is the auth SDK's own item rather than ours, and signing out is the only way to reach it — the caller opens a fresh one right after.
  static Future<void> _purge(
    String logTag,
    SdDeviceScopedStore deviceScoped,
    Future<void> Function() signOut,
  ) async {
    // The session first, and in its own try: it is the half the user can see, and a device-scoped wipe that fails must not be what stops it.
    try {
      await signOut();
      SdLogger.info(logTag, 'Reinstall: signed out');
    } catch (error, stackTrace) {
      SdLogger.error(
        logTag,
        'Reinstall: sign-out failed',
        error: error,
        stackTrace: stackTrace,
      );
    }
    await deviceScoped.deleteAll();
    SdLogger.info(
      logTag,
      'Reinstall: device-scoped store cleared and the session signed out',
    );
  }

  /// An update from a build that kept its settings in the install-scoped store: the same values, moved into the store that now owns them. Idempotent, because a crash before the marker is written repeats it.
  static Future<void> _adopt(
    String logTag,
    SdInstallScopedStore installScoped,
    List<String> legacy,
    SdDeviceScopedStore deviceScoped,
  ) async {
    for (final String key in legacy) {
      final Object? value = installScoped.get(key);

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
          // Nothing an app of ours writes is a string list, so anything else is not ours to carry.
          SdLogger.warning(logTag, 'Legacy key not carried', {'key': key});
      }
    }
    SdLogger.info(logTag, 'Legacy settings adopted', {'keys': legacy.length});
  }

  /// One owner per value: the copies left behind would otherwise be read by nothing and outlive the ones that matter.
  static Future<void> _dropLegacy(
    SdInstallScopedStore installScoped,
    List<String> legacy,
  ) async {
    for (final String key in legacy) {
      await installScoped.remove(key);
    }
  }
}
