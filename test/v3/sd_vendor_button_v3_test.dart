import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:system_design/index.dart';

/// The three things that make a sign-in button pass review rather than look
/// like one: it clears Apple's touch floor, the mark is drawn against the
/// label rather than against the button, and the label keeps a gutter.
Future<void> _pump(
  WidgetTester tester, {
  String label = 'Continue with Apple',
  Size size = const Size(390, 844),
  double textScale = 1.0,
}) => tester.pumpWidget(
  ScreenUtilInit(
    designSize: const Size(390, 844),
    builder: (BuildContext context, Widget? child) => MaterialApp(
      theme: ThemeData.light().copyWith(
        extensions: const <ThemeExtension<dynamic>>[SdThemeV3.fallback],
      ),
      home: MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
        child: Center(
          child: SizedBox.fromSize(
            size: size,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SdVendorButtonV3(
                  label: label,
                  icon: Symbols.storefront_rounded,
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  ),
);

void main() {
  testWidgets('it clears Apple\'s touch floor', (WidgetTester tester) async {
    await _pump(tester);

    expect(
      tester.getSize(find.byType(SdVendorButtonV3)).height,
      greaterThanOrEqualTo(SdVendorButtonV3.minHeight),
    );
  });

  testWidgets('it clears the floor at the largest text scale too', (
    WidgetTester tester,
  ) async {
    await _pump(tester, textScale: 1.6);

    expect(
      tester.getSize(find.byType(SdVendorButtonV3)).height,
      greaterThanOrEqualTo(SdVendorButtonV3.minHeight),
    );
  });

  testWidgets('the label keeps a gutter', (WidgetTester tester) async {
    // A long label is the case the padding exists for: centred short text
    // hides a missing gutter completely, which is how it went missing once.
    await _pump(
      tester,
      label: 'Continue with a vendor whose name is long enough to wrap',
    );

    final Rect button = tester.getRect(find.byType(SdVendorButtonV3));
    final Rect label = tester.getRect(find.byType(Text));

    expect(label.left, greaterThan(button.left));
    expect(label.right, lessThan(button.right));
  });

  testWidgets('the mark is boxed larger than the text it sits beside', (
    WidgetTester tester,
  ) async {
    await _pump(tester);

    final double fontSize =
        tester.widget<Text>(find.byType(Text)).style!.fontSize!;

    expect(SdVendorButtonV3.markSizeFor(fontSize), greaterThan(fontSize));
  });
}
