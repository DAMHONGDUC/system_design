import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:system_design/core/sd_screen_scale.dart';

void main() {
  // The canvas the host app's layouts were drawn on. Written here rather than
  // imported so this test fails if the app changes it silently.
  const Size phoneCanvas = Size(390, 844);

  /// The four ratios screenutil resolves a token through, given the design
  /// this class hands it for [window].
  ///
  /// `.w` and `.sp` take the width, `.h` takes the height, and `.r` — every
  /// icon, radius and square tap target — takes the smaller of the two.
  ({double w, double h, double r}) ratios(Size window) {
    final Size design = SdScreenScale.designSize(window, phoneCanvas);
    final double w = window.width / design.width;
    final double h = window.height / design.height;

    return (w: w, h: h, r: math.min(w, h));
  }

  group('SdScreenScale.designSize', () {
    // The half this exists to protect: a phone must resolve exactly what it
    // resolved before the clamp was written, or every screen in the app moves.
    test('a phone gets the canvas back untouched', () {
      for (final Size phone in <Size>[
        const Size(375, 812),
        phoneCanvas,
        const Size(440, 956),
      ]) {
        expect(
          SdScreenScale.designSize(phone, phoneCanvas),
          phoneCanvas,
          reason: '$phone must not change the canvas',
        );
      }
    });

    test('a tablet renders one scale on all four ladders, either way up', () {
      for (final Size tablet in <Size>[
        const Size(744, 1133),
        const Size(820, 1180),
        const Size(1180, 820),
        const Size(1024, 1366),
        const Size(1366, 1024),
      ]) {
        final ({double w, double h, double r}) scale = ratios(tablet);

        expect(scale.w, closeTo(SdScreenScale.maxScale, 0.001), reason: '$tablet width');
        expect(scale.h, closeTo(SdScreenScale.maxScale, 0.001), reason: '$tablet height');
        expect(scale.r, closeTo(SdScreenScale.maxScale, 0.001), reason: '$tablet radius');
      }
    });

    // The bug the height ceiling exists for: floored at a phone's design
    // height, a landscape tablet resolved `.r` below 1 and drew icons and tap
    // targets smaller than the phone it was scaled up from.
    test('a landscape tablet never shrinks an icon or a tap target', () {
      final ({double w, double h, double r}) scale = ratios(const Size(1180, 820));

      expect(44 * scale.r, greaterThanOrEqualTo(44));
      expect(20 * scale.r, greaterThanOrEqualTo(20));
    });

    test('the scale never runs away as the window grows', () {
      for (final double width in <double>[600, 834, 1024, 1366, 2048]) {
        final ({double w, double h, double r}) scale = ratios(Size(width, width * 1.4));

        expect(
          scale.w,
          lessThanOrEqualTo(SdScreenScale.maxScale + 0.001),
          reason: 'a $width wide window must not scale past the clamp',
        );
      }
    });
  });
}
