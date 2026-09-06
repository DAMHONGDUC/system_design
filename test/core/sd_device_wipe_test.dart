import 'package:flutter_test/flutter_test.dart';
import 'package:system_design/common.dart';

/// **One wipe, and the two guards that run it agree on what it does.**
///
/// A reinstall and an environment change are detected completely differently
/// and then have to do the same thing: sign out, drop the caches, empty the
/// stores, each step guarded so the one that fails does not cost the app the
/// steps after it. Written twice, it drifted twice.
const String _logTag = 'Fresh Install';

SdDeviceWipeStep _step(String name, List<String> ran) =>
    SdDeviceWipeStep(name: name, run: () async => ran.add(name));

void main() {
  setUp(() => SdLogger.enabled = false);

  group('SdDeviceWipe', () {
    test('runs every step in the order it was given', () async {
      final List<String> ran = <String>[];

      await SdDeviceWipe.run(
        logTag: _logTag,
        reason: 'Reinstall',
        steps: <SdDeviceWipeStep>[
          _step('first', ran),
          _step('second', ran),
          _step('third', ran),
        ],
      );

      expect(ran, <String>['first', 'second', 'third']);
    });

    test('a step that throws does not cost the steps after it', () async {
      final List<String> ran = <String>[];

      await SdDeviceWipe.run(
        logTag: _logTag,
        reason: 'Environment changed',
        steps: <SdDeviceWipeStep>[
          SdDeviceWipeStep(
            name: 'throws',
            run: () async => throw StateError('no Firebase app'),
          ),
          _step('after', ran),
        ],
      );

      expect(ran, <String>['after']);
    });

    test('a step whose `when` is false is skipped', () async {
      final List<String> ran = <String>[];

      await SdDeviceWipe.run(
        logTag: _logTag,
        reason: 'Environment changed',
        steps: <SdDeviceWipeStep>[
          SdDeviceWipeStep(
            name: 'skipped',
            when: () => false,
            run: () async => ran.add('skipped'),
          ),
          _step('after', ran),
        ],
      );

      expect(ran, <String>['after']);
    });

    test('a halting step stops the wipe and rethrows', () async {
      // What `SdReinstallGuard` relies on: a device-scoped store that could
      // not be emptied must leave the marker unwritten, so the next launch
      // tries again rather than trusting a store that is still full.
      final List<String> ran = <String>[];

      await expectLater(
        SdDeviceWipe.run(
          logTag: _logTag,
          reason: 'Reinstall',
          steps: <SdDeviceWipeStep>[
            SdDeviceWipeStep(
              name: 'halts',
              onFailure: SdDeviceWipeFailure.halt,
              run: () async => throw StateError('keychain unavailable'),
            ),
            _step('never', ran),
          ],
        ),
        throwsStateError,
      );

      expect(ran, isEmpty);
    });
  });
}
