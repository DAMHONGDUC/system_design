import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:system_design/index.dart';

/// **One step failing must not cost the app the steps after it.**
///
/// Startup concerns are independent, and one `try` around all of them lets the
/// first failure skip everything below — including the crash reporter that
/// would have named it. That is why the reporter goes first and why every step
/// is guarded on its own.
const String _logTag = 'Bootstrap';

SdBootstrapStep _step(String name, List<String> started) =>
    SdBootstrapStep(name: name, run: () async => started.add(name));

Widget _app() => const Text('app', textDirection: TextDirection.ltr);

void main() {
  setUp(() => SdLogger.enabled = false);

  testWidgets('brings every step up in order, then runs the app', (
    WidgetTester tester,
  ) async {
    final List<String> started = <String>[];

    await SdBootstrap.run(
      logTag: _logTag,
      steps: <SdBootstrapStep>[
        _step('Firebase', started),
        _step('Billing', started),
      ],
      builder: _app,
    );
    await tester.pump();

    expect(started, <String>['Firebase', 'Billing']);
    expect(find.text('app'), findsOneWidget);
  });

  testWidgets('a step that throws does not stop the ones after it', (
    WidgetTester tester,
  ) async {
    final List<String> started = <String>[];

    await SdBootstrap.run(
      logTag: _logTag,
      steps: <SdBootstrapStep>[
        SdBootstrapStep(
          name: 'Firebase',
          run: () async => throw StateError('no project configured'),
        ),
        _step('Billing', started),
      ],
      builder: _app,
    );
    await tester.pump();

    // The app still starts, degraded — a white screen tells nobody anything.
    expect(started, <String>['Billing']);
    expect(find.text('app'), findsOneWidget);
  });
}
