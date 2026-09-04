import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:system_design/index.dart';

/// The paint the skeleton is drawn with on this frame.
BoxDecoration _decorationOf(WidgetTester tester) =>
    tester.widget<DecoratedBox>(find.byType(DecoratedBox).first).decoration
        as BoxDecoration;

Future<void> _pumpSkeleton(
  WidgetTester tester, {
  bool disableAnimations = false,
}) => tester.pumpWidget(
  ScreenUtilInit(
    designSize: const Size(390, 844),
    builder: (BuildContext context, Widget? child) => MaterialApp(
      theme: ThemeData.dark().copyWith(
        extensions: const <ThemeExtension<dynamic>>[SdThemeV2.fallback],
      ),
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: disableAnimations),
        child: const Scaffold(body: SdSkeletonV2(height: 40, width: 200)),
      ),
    ),
  ),
);

void main() {
  testWidgets('the band moves, so the block reads as still loading', (
    WidgetTester tester,
  ) async {
    await _pumpSkeleton(tester);

    final GradientTransform? first = _decorationOf(tester).gradient?.transform;

    // Not settled: the sweep repeats forever, and pumpAndSettle would time out.
    await tester.pump(const Duration(milliseconds: 400));

    expect(first, isNotNull);
    expect(_decorationOf(tester).gradient?.transform, isNot(first));

    // Leaves the controller with nothing to tick, or the test ends "pending timers".
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Reduce Motion turns it back into a still block', (
    WidgetTester tester,
  ) async {
    await _pumpSkeleton(tester, disableAnimations: true);

    final BoxDecoration decoration = _decorationOf(tester);

    expect(decoration.gradient, isNull);
    expect(decoration.color, SdThemeV2.fallback.surfaceElevated);
  });
}
