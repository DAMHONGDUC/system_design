import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:system_design/index.dart';

void main() {
  testWidgets('v4 card and button expose their labels', (
    WidgetTester tester,
  ) async {
    bool pressed = false;

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (BuildContext context, Widget? child) => MaterialApp(
          home: Scaffold(
            body: SdCardV4(
              child: SdButtonV4(
                label: 'Tính kết quả',
                onPressed: () => pressed = true,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Tính kết quả'));

    expect(pressed, isTrue);
    expect(find.byType(SdCardV4), findsOneWidget);
  });

  testWidgets('v4 action view pins spaced actions at the bottom', (
    WidgetTester tester,
  ) async {
    const Key firstActionKey = Key('first-action');
    const Key secondActionKey = Key('second-action');
    const double tolerance = 0.001;

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (BuildContext context, Widget? child) => MaterialApp(
          home: Scaffold(
            body: SdActionViewV4(
              body: const ColoredBox(color: Colors.white),
              actions: const <Widget>[
                SizedBox(key: firstActionKey, height: 48),
                SizedBox(key: secondActionKey, height: 48),
              ],
            ),
          ),
        ),
      ),
    );

    final Finder actionView = find.byType(SdActionViewV4);
    final BuildContext context = tester.element(actionView);
    final Rect viewRect = tester.getRect(actionView);
    final Rect firstActionRect = tester.getRect(find.byKey(firstActionKey));
    final Rect secondActionRect = tester.getRect(find.byKey(secondActionKey));

    expect(
      secondActionRect.top - firstActionRect.bottom,
      closeTo(SdContentPaddingV4.listItemGap, tolerance),
    );
    expect(
      viewRect.bottom - secondActionRect.bottom,
      closeTo(SdContentPaddingV4.bottomActions(context).bottom, tolerance),
    );
  });

  testWidgets('v4 filter and empty-state primitives expose clear semantics', (
    WidgetTester tester,
  ) async {
    bool selected = false;

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (BuildContext context, Widget? child) => MaterialApp(
          home: Scaffold(
            body: Column(
              children: <Widget>[
                SdChoiceChipV4(
                  label: 'Last 7 days',
                  selected: selected,
                  onSelected: (bool value) => selected = value,
                ),
                const SdEmptyStateV4(
                  icon: Icons.search_rounded,
                  title: 'No matching results',
                  description: 'Try another filter.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Last 7 days'));

    expect(selected, isTrue);
    expect(find.text('No matching results'), findsOneWidget);
    expect(find.text('Try another filter.'), findsOneWidget);
  });
}
