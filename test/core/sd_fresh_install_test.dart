import 'package:flutter_test/flutter_test.dart';
import 'package:system_design/common.dart';

/// A store that records what it was asked to do, in order.
class _RecordingStore implements SdFreshInstallStore {
  _RecordingStore({this.stored, this.throwOnRead = false});

  final List<String> calls = <String>[];
  String? stored;
  final bool throwOnRead;

  @override
  Future<String?> readString(String key) async {
    if (throwOnRead) {
      throw StateError('preferences unavailable');
    }
    calls.add('read:$key');

    return stored;
  }

  @override
  Future<void> writeString(String key, String value) async {
    calls.add('write:$key=$value');
    stored = value;
  }

  @override
  Future<void> clear() async {
    calls.add('clear');
    stored = null;
  }
}

const String _logTag = 'Fresh Install';
const String _envKey = 'last_env';

SdFreshInstallPolicy _policy(
  _RecordingStore store, {
  List<SdFreshInstallStep> steps = const <SdFreshInstallStep>[],
}) => SdFreshInstall.policy(
  logTag: _logTag,
  envKey: _envKey,
  store: store,
  steps: steps,
);

void main() {
  setUp(() => SdLogger.enabled = false);

  group('SdFreshInstall', () {
    test('reads the recorded environment back', () async {
      final _RecordingStore store = _RecordingStore(stored: 'dev');

      expect(await _policy(store).readLastEnv(), 'dev');
      expect(store.calls, <String>['read:$_envKey']);
    });

    test('a store that cannot be read is a first launch, not a wipe', () async {
      final _RecordingStore store = _RecordingStore(throwOnRead: true);

      expect(await _policy(store).readLastEnv(), isNull);
    });

    test('records the environment under the key it was given', () async {
      final _RecordingStore store = _RecordingStore();

      await _policy(store).writeEnv('prod');

      expect(store.stored, 'prod');
      expect(store.calls, <String>['write:$_envKey=prod']);
    });

    test('runs every step in order, then clears the store last', () async {
      final _RecordingStore store = _RecordingStore(stored: 'dev');
      final List<String> ran = <String>[];

      await _policy(
        store,
        steps: <SdFreshInstallStep>[
          SdFreshInstallStep(
            name: 'first',
            run: () async => ran.add('first'),
          ),
          SdFreshInstallStep(
            name: 'second',
            run: () async => ran.add('second'),
          ),
        ],
      ).wipe('dev', 'prod');

      expect(ran, <String>['first', 'second']);
      expect(store.calls, <String>['clear']);
      expect(store.stored, isNull);
    });

    test('a step that throws does not cost the steps after it', () async {
      final _RecordingStore store = _RecordingStore();
      final List<String> ran = <String>[];

      await _policy(
        store,
        steps: <SdFreshInstallStep>[
          SdFreshInstallStep(
            name: 'throws',
            run: () async => throw StateError('no Firebase app'),
          ),
          SdFreshInstallStep(name: 'after', run: () async => ran.add('after')),
        ],
      ).wipe(null, 'prod');

      expect(ran, <String>['after']);
      expect(store.calls, <String>['clear']);
    });

    test('a step whose `when` is false is skipped', () async {
      final _RecordingStore store = _RecordingStore();
      final List<String> ran = <String>[];

      await _policy(
        store,
        steps: <SdFreshInstallStep>[
          SdFreshInstallStep(
            name: 'skipped',
            when: () => false,
            run: () async => ran.add('skipped'),
          ),
        ],
      ).wipe('dev', 'prod');

      expect(ran, isEmpty);
      expect(store.calls, <String>['clear']);
    });

    test('a store that cannot be cleared does not throw the wipe', () async {
      final _RecordingStore store = _ThrowingClearStore();

      await expectLater(_policy(store).wipe('dev', 'prod'), completes);
    });
  });
}

class _ThrowingClearStore extends _RecordingStore {
  @override
  Future<void> clear() async => throw StateError('store unavailable');
}
