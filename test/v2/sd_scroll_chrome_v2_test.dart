import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:system_design/index.dart';

/// Where the chrome is being asked to sit on this frame — `Offset.zero` while
/// it is showing, a whole height off its edge while it is not.
Offset _chromeOffset(WidgetTester tester) =>
    tester.widget<AnimatedSlide>(find.byType(AnimatedSlide)).offset;

/// A list with one bit of chrome pinned over it, both under the same scope —
/// the shape the app shell builds.
Future<void> _pumpList(WidgetTester tester, {bool pinned = false}) =>
    tester.pumpWidget(
      ScreenUtilInit(
        // The test surface itself, so `SdSpacingConstant` scales 1:1 and the
        // pixel counts dragged below are the ones the widget measures.
        designSize: const Size(800, 600),
        builder: (BuildContext context, Widget? child) => MaterialApp(
          theme: ThemeData.dark().copyWith(
            extensions: const <ThemeExtension<dynamic>>[SdThemeV2.fallback],
          ),
          home: SdScrollChromeV2(
            child: Scaffold(
              body: Stack(
                children: <Widget>[
                  ListView.builder(
                    itemCount: 100,
                    itemBuilder: (BuildContext context, int index) =>
                        SizedBox(height: 60, child: Text('$index')),
                  ),
                  SdScrollChromeSlideV2(
                    edge: SdScrollChromeEdgeV2.top,
                    pinned: pinned,
                    child: const SizedBox(height: 80),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

void main() {
  testWidgets('the chrome leaves while the list moves and returns when it stops', (
    WidgetTester tester,
  ) async {
    await _pumpList(tester);

    final TestGesture gesture = await tester.startGesture(
      const Offset(200, 400),
    );
    await gesture.moveBy(const Offset(0, -200));
    await tester.pump();

    expect(_chromeOffset(tester), const Offset(0, -1));

    await gesture.up();
    await tester.pumpAndSettle();

    expect(_chromeOffset(tester), Offset.zero);
  });

  testWidgets('a finger that stops without lifting brings it back', (
    WidgetTester tester,
  ) async {
    await _pumpList(tester);

    final TestGesture gesture = await tester.startGesture(
      const Offset(200, 400),
    );
    await gesture.moveBy(const Offset(0, -200));
    await tester.pump();

    expect(_chromeOffset(tester), const Offset(0, -1));

    // Still down, just still: only the idle timer can report that.
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(_chromeOffset(tester), Offset.zero);

    await gesture.up();
    await tester.pumpAndSettle();
  });

  testWidgets('the nudge a tap on a row can produce is not a scroll', (
    WidgetTester tester,
  ) async {
    await _pumpList(tester);

    final TestGesture gesture = await tester.startGesture(
      const Offset(200, 400),
    );
    // Past the touch slop by less than the hide distance.
    await gesture.moveBy(const Offset(0, -(kTouchSlop + 4)));
    await tester.pump();

    expect(_chromeOffset(tester), Offset.zero);

    await gesture.up();
    await tester.pumpAndSettle();
  });

  testWidgets('pinned chrome stays put', (WidgetTester tester) async {
    await _pumpList(tester, pinned: true);

    expect(find.byType(AnimatedSlide), findsNothing);

    await tester.drag(find.byType(ListView), const Offset(0, -200));
    await tester.pumpAndSettle();

    expect(find.byType(AnimatedSlide), findsNothing);
  });
}
