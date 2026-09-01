import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:system_design/index.dart';

void main() {
  testWidgets('search field docks into the app bar without losing input', (
    WidgetTester tester,
  ) async {
    final TextEditingController controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (BuildContext context, Widget? child) => MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: <Widget>[
                SdSearchHeaderV4(
                  title: 'Tools',
                  controller: controller,
                  label: 'Search tools',
                  prefixIcon: const Icon(Icons.search),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 1200)),
              ],
            ),
          ),
        ),
      ),
    );

    final Finder searchField = find.byType(TextField);
    final double expandedTop = tester.getTopLeft(searchField).dy;
    await tester.tap(searchField);
    await tester.enterText(searchField, 'interest');
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsOneWidget);
    expect(controller.text, 'interest');
    expect(tester.getTopLeft(searchField).dy, lessThan(expandedTop));
  });
}
