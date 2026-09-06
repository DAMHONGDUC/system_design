import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:system_design/index.dart';

/// A policy that records what the guard asked it to do, in order.
class _RecordingPolicy {
  _RecordingPolicy({this.stored, this.throwOnRead = false});

  final List<String> calls = <String>[];
  String? stored;
  final bool throwOnRead;

  SdFreshInstallPolicy get policy => SdFreshInstallPolicy(
    readLastEnv: () async {
      if (throwOnRead) {
        throw StateError('preferences unavailable');
      }
      calls.add('read');

      return stored;
    },
    writeEnv: (String envName) async {
      calls.add('write:$envName');
      stored = envName;
    },
    wipe: (String? previous, String current) async {
      calls.add('wipe:${previous ?? '—'}->$current');
      stored = null;
    },
  );
}

Future<void> _pumpGuard(
  WidgetTester tester, {
  required String envName,
  required _RecordingPolicy recorder,
}) => tester.pumpWidget(
  Directionality(
    textDirection: TextDirection.ltr,
    child: SdFreshInstallGuard(
      envName: envName,
      policy: recorder.policy,
      child: const Text('app'),
    ),
  ),
);

void main() {
  setUp(() => SdLogger.enabled = false);

  testWidgets('the app is not built until the check has finished', (
    WidgetTester tester,
  ) async {
    final _RecordingPolicy recorder = _RecordingPolicy(stored: 'dev');

    await _pumpGuard(tester, envName: 'dev', recorder: recorder);

    expect(find.text('app'), findsNothing);

    await tester.pumpAndSettle();

    expect(find.text('app'), findsOneWidget);
  });

  testWidgets('the same environment wipes nothing', (
    WidgetTester tester,
  ) async {
    final _RecordingPolicy recorder = _RecordingPolicy(stored: 'dev');

    await _pumpGuard(tester, envName: 'dev', recorder: recorder);
    await tester.pumpAndSettle();

    expect(recorder.calls, <String>['read', 'write:dev']);
  });

  testWidgets('a first launch has nothing to be wrong', (
    WidgetTester tester,
  ) async {
    final _RecordingPolicy recorder = _RecordingPolicy();

    await _pumpGuard(tester, envName: 'prod', recorder: recorder);
    await tester.pumpAndSettle();

    expect(recorder.calls, <String>['read', 'write:prod']);
  });

  testWidgets('dev installed over prod is wiped, and recorded after', (
    WidgetTester tester,
  ) async {
    final _RecordingPolicy recorder = _RecordingPolicy(stored: 'prod');

    await _pumpGuard(tester, envName: 'dev', recorder: recorder);
    await tester.pumpAndSettle();

    // The record is written last: a wipe clears the store it lives in, so
    // writing first would leave the device naming an environment whose data
    // has just gone.
    expect(recorder.calls, <String>['read', 'wipe:prod->dev', 'write:dev']);
    expect(recorder.stored, 'dev');
  });

  testWidgets('prod installed over dev is wiped too', (
    WidgetTester tester,
  ) async {
    final _RecordingPolicy recorder = _RecordingPolicy(stored: 'dev');

    await _pumpGuard(tester, envName: 'prod', recorder: recorder);
    await tester.pumpAndSettle();

    expect(recorder.calls, <String>['read', 'wipe:dev->prod', 'write:prod']);
  });

  testWidgets('a check that throws still starts the app', (
    WidgetTester tester,
  ) async {
    final _RecordingPolicy recorder = _RecordingPolicy(throwOnRead: true);

    await _pumpGuard(tester, envName: 'dev', recorder: recorder);
    await tester.pumpAndSettle();

    expect(find.text('app'), findsOneWidget);
  });

  testWidgets('the guard runs in a build that draws no tag', (
    WidgetTester tester,
  ) async {
    final _RecordingPolicy recorder = _RecordingPolicy(stored: 'dev');

    await tester.pumpWidget(
      SdDevWrapper(
        envName: 'prod',
        // What a prod build passes. The tag is about the screenshot; the
        // wipe is about the data underneath it, and prod started over a dev
        // install is exactly the launch that needs one.
        visible: false,
        freshInstall: recorder.policy,
        child: const Directionality(
          textDirection: TextDirection.ltr,
          child: Text('app'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(recorder.calls, <String>['read', 'wipe:dev->prod', 'write:prod']);
    expect(find.text('app'), findsOneWidget);
  });
}
