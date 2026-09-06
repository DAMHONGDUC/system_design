import 'package:flutter_test/flutter_test.dart';
import 'package:system_design/common.dart';

/// **One stamp answers both questions, and the update row is what makes that
/// safe.**
///
/// A reinstall and an environment change were two classes asking the same
/// thing — *does the state on this device belong to the app now running?* —
/// and the merge only works if an install that predates the stamp reads as an
/// update rather than a reinstall. Get that wrong and the first launch after
/// shipping this wipes a real user's session.
class _InstallScoped implements SdInstallScopedStore {
  _InstallScoped([Map<String, Object>? values])
    : values = values ?? <String, Object>{};

  final Map<String, Object> values;
  bool cleared = false;

  @override
  Future<Iterable<String>> getKeys() async => values.keys.toList();

  @override
  Future<Object?> get(String key) async => values[key];

  @override
  Future<String?> getString(String key) async => values[key] as String?;

  @override
  Future<void> setString(String key, String value) async =>
      values[key] = value;

  @override
  Future<void> remove(String key) async => values.remove(key);

  @override
  Future<void> clear() async {
    cleared = true;
    values.clear();
  }
}

class _DeviceScoped implements SdDeviceScopedStore {
  _DeviceScoped([Map<String, Object>? values])
    : values = values ?? <String, Object>{};

  final Map<String, Object> values;
  bool cleared = false;

  @override
  Future<Iterable<String>> getKeys() async => values.keys.toList();

  @override
  Future<void> setBool(String key, bool value) async => values[key] = value;

  @override
  Future<void> setInt(String key, int value) async => values[key] = value;

  @override
  Future<void> setDouble(String key, double value) async => values[key] = value;

  @override
  Future<void> setString(String key, String value) async => values[key] = value;

  @override
  Future<void> deleteAll() async {
    cleared = true;
    values.clear();
  }
}

/// A host that records the vendor calls instead of making them.
class _Host implements SdFreshInstallHost {
  _Host({this.isBackendReady = true});

  final List<String> calls = <String>[];

  @override
  final bool isBackendReady;

  @override
  Future<void> signOut() async => calls.add('signOut');

  @override
  Future<void> clearCache() async => calls.add('clearCache');
}

const String _logTag = 'Fresh Install';
const String _stamp = SdFreshInstall.defaultStampKey;

void main() {
  late _Host host;

  setUp(() {
    SdLogger.enabled = false;
    host = _Host();
  });

  Future<SdFreshInstallOutcome> run({
    required String buildStamp,
    required _InstallScoped installScoped,
    _DeviceScoped? deviceScoped,
    _Host? withHost,
  }) => SdFreshInstall.run(
    logTag: _logTag,
    buildStamp: buildStamp,
    installScoped: installScoped,
    deviceScoped: deviceScoped,
    host: withHost ?? host,
  );

  group('what a launch is', () {
    test('a matching stamp is a normal launch and touches nothing', () async {
      final _InstallScoped store = _InstallScoped(<String, Object>{
        _stamp: 'dev',
        'theme': 'dark',
      });

      expect(
        await run(buildStamp: 'dev', installScoped: store),
        SdFreshInstallOutcome.normalLaunch,
      );
      expect(host.calls, isEmpty);
      expect(store.values['theme'], 'dark');
    });

    test('a different stamp is an environment change, and wipes', () async {
      final _InstallScoped store = _InstallScoped(<String, Object>{
        _stamp: 'dev',
        'theme': 'dark',
      });

      expect(
        await run(buildStamp: 'prod', installScoped: store),
        SdFreshInstallOutcome.environmentChanged,
      );
      expect(host.calls, <String>['signOut', 'clearCache']);
      expect(store.cleared, isTrue);
      // The stamp is written after the wipe, never before.
      expect(store.values, <String, Object>{_stamp: 'prod'});
    });

    test('nothing anywhere is a first install, and wipes nothing', () async {
      final _InstallScoped store = _InstallScoped();

      expect(
        await run(
          buildStamp: 'dev',
          installScoped: store,
          deviceScoped: _DeviceScoped(),
        ),
        SdFreshInstallOutcome.firstInstall,
      );
      expect(host.calls, isEmpty);
      expect(store.values[_stamp], 'dev');
    });

    test('state that outlived a delete is a reinstall, and wipes', () async {
      final _DeviceScoped keychain = _DeviceScoped(<String, Object>{
        'session': 'abc',
      });

      expect(
        await run(
          buildStamp: 'dev',
          installScoped: _InstallScoped(),
          deviceScoped: keychain,
        ),
        SdFreshInstallOutcome.reinstall,
      );
      expect(host.calls, <String>['signOut', 'clearCache']);
      expect(keychain.cleared, isTrue);
    });

    test('no device-scoped store means a reinstall cannot fire', () async {
      // A host with nothing that survives a delete: an empty install-scoped
      // store is a first install and never a reinstall.
      expect(
        await run(buildStamp: 'dev', installScoped: _InstallScoped()),
        SdFreshInstallOutcome.firstInstall,
      );
      expect(host.calls, isEmpty);
    });
  });

  group('an install that predates the stamp', () {
    test('reads as an update, so shipping this wipes nobody', () async {
      // The trap the merge has to avoid: these keys are a real user's
      // settings and their session, not a reinstall.
      final _InstallScoped store = _InstallScoped(<String, Object>{
        'is_installed': true,
        'last_env': 'dev',
        'onboarding_seen': true,
      });

      expect(
        await run(
          buildStamp: 'dev',
          installScoped: store,
          deviceScoped: _DeviceScoped(<String, Object>{'session': 'abc'}),
        ),
        SdFreshInstallOutcome.update,
      );
      expect(host.calls, isEmpty);
      expect(store.cleared, isFalse);
      expect(store.values[_stamp], 'dev');
    });

    test('its settings move into the store that now owns them', () async {
      final _InstallScoped store = _InstallScoped(<String, Object>{
        'threshold': 7.0,
        'onboarding_seen': true,
      });
      final _DeviceScoped keychain = _DeviceScoped();

      await run(
        buildStamp: 'dev',
        installScoped: store,
        deviceScoped: keychain,
      );

      expect(keychain.values['threshold'], 7.0);
      expect(keychain.values['onboarding_seen'], true);
      // One owner per value — the copies left behind would outlive them.
      expect(store.values.keys, <String>[_stamp]);
    });

    test('a host with nowhere to move them keeps its keys', () async {
      final _InstallScoped store = _InstallScoped(<String, Object>{
        'onboarding_seen': true,
      });

      expect(
        await run(buildStamp: 'dev', installScoped: store),
        SdFreshInstallOutcome.update,
      );
      expect(store.values['onboarding_seen'], true);
      expect(store.values[_stamp], 'dev');
    });
  });

  test('a host with no backend skips the vendor calls, not the wipe', () async {
    // A build with no backend configured never initialised one, so reaching
    // for it would throw — but the stores still have to go.
    final _Host offline = _Host(isBackendReady: false);
    final _InstallScoped store = _InstallScoped(<String, Object>{
      _stamp: 'dev',
    });

    await run(buildStamp: 'prod', installScoped: store, withHost: offline);

    expect(offline.calls, isEmpty);
    expect(store.cleared, isTrue);
  });

  test('a store that throws still starts the app, unstamped', () async {
    expect(
      await SdFreshInstall.run(
        logTag: _logTag,
        buildStamp: 'dev',
        installScoped: _ThrowingStore(),
        host: _Host(),
      ),
      SdFreshInstallOutcome.normalLaunch,
    );
  });
}

class _ThrowingStore extends _InstallScoped {
  @override
  Future<String?> getString(String key) async =>
      throw StateError('preferences unavailable');
}
