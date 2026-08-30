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
}
