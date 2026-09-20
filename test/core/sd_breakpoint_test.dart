import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:system_design/core/sd_breakpoint.dart';

void main() {
  // The canvas the host app's layouts were drawn on. Written here rather than
  // imported so this test fails if the app changes it silently.
  const Size phoneCanvas = Size(390, 844);

  group('SdBreakpointConstant.of', () {
    test('every phone is compact', () {
      expect(SdBreakpointConstant.of(320), SdBreakpoint.compact);
      expect(SdBreakpointConstant.of(390), SdBreakpoint.compact);
      expect(SdBreakpointConstant.of(440), SdBreakpoint.compact);
    });

    test('a tablet held upright is medium', () {
      expect(SdBreakpointConstant.of(744), SdBreakpoint.medium);
      expect(SdBreakpointConstant.of(834), SdBreakpoint.medium);
    });

    test('a tablet on its side is expanded', () {
      expect(SdBreakpointConstant.of(1024), SdBreakpoint.expanded);
      expect(SdBreakpointConstant.of(1366), SdBreakpoint.expanded);
    });

    test('isWide is false only for a phone', () {
      expect(SdBreakpoint.compact.isWide, isFalse);
      expect(SdBreakpoint.medium.isWide, isTrue);
      expect(SdBreakpoint.expanded.isWide, isTrue);
    });
  });

  group('SdBreakpointConstant.designSizeFor', () {
    // The half this exists to protect: a phone must resolve exactly what it
    // resolved before the clamp was written, or every screen in the app moves.
    test('a phone gets the canvas back untouched', () {
      for (final Size phone in <Size>[
        const Size(375, 812),
        phoneCanvas,
        const Size(440, 956),
      ]) {
        expect(
          SdBreakpointConstant.designSizeFor(
            window: phone,
            base: phoneCanvas,
          ),
          phoneCanvas,
          reason: '$phone must not change the canvas',
        );
      }
    });

    test('a tablet is clamped to maxTokenScale, not scaled by its width', () {
      const Size tablet = Size(1024, 1366);

      final Size design = SdBreakpointConstant.designSizeFor(
        window: tablet,
        base: phoneCanvas,
      );

      expect(
        tablet.width / design.width,
        closeTo(SdBreakpointConstant.maxTokenScale, 0.001),
      );
      expect(
        tablet.height / design.height,
        closeTo(SdBreakpointConstant.maxTokenScale, 0.001),
      );
    });

    test('the scale never runs away as the window grows', () {
      for (final double width in <double>[600, 834, 1024, 1366, 2048]) {
        final Size window = Size(width, width * 1.4);
        final Size design = SdBreakpointConstant.designSizeFor(
          window: window,
          base: phoneCanvas,
        );

        expect(
          window.width / design.width,
          lessThanOrEqualTo(SdBreakpointConstant.maxTokenScale + 0.001),
          reason: 'a $width wide window must not scale past the clamp',
        );
      }
    });
  });
}
