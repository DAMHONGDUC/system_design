import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:system_design/index.dart';

/// The two things about this screen that break quietly: a raw failure reaching
/// a user it was not meant for, and the one screen with no other way to speak
/// overflowing instead of scrolling.
Future<void> _pump(
  WidgetTester tester, {
  String? detail,
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
            child: SdErrorViewV3(
              icon: Symbols.error_rounded,
              title: 'Reseller Studio could not start',
              message: 'Close the app completely and open it again.',
              detail: detail,
            ),
          ),
        ),
      ),
    ),
  ),
);

void main() {
  testWidgets('a null detail draws no row at all', (WidgetTester tester) async {
    await _pump(tester);

    expect(find.text('Reseller Studio could not start'), findsOneWidget);
    // Not "an empty line": the host passes null in production precisely so a
    // stack trace cannot reach someone who downloaded this from a store.
    expect(find.byType(Text), findsNWidgets(2));
  });

  testWidgets('the detail is drawn when it is passed', (
    WidgetTester tester,
  ) async {
    await _pump(tester, detail: '[core/duplicate-app]');

    expect(find.text('[core/duplicate-app]'), findsOneWidget);
  });

  testWidgets('a long failure is capped rather than run on', (
    WidgetTester tester,
  ) async {
    await _pump(tester, detail: 'stack line\n' * 40);

    final Text failure = tester.widget<Text>(find.byType(Text).last);

    expect(failure.maxLines, SdErrorViewV3.detailMaxLines);
    expect(failure.overflow, TextOverflow.ellipsis);
  });

  testWidgets('it scrolls instead of overflowing on a short, scaled screen', (
    WidgetTester tester,
  ) async {
    await _pump(
      tester,
      detail: '[core/duplicate-app]',
      size: const Size(320, 260),
      textScale: 2.0,
    );

    // An overflow here is invisible in a green run and is the whole screen on
    // a phone, because there is nothing else left to read.
    expect(tester.takeException(), isNull);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
  });
}
