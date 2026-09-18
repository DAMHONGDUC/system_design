import 'dart:math' as math;
import 'dart:ui' show Size;

/// The ceiling on how far screenutil is allowed to scale a design, and the
/// design size that enforces it.
///
/// screenutil multiplies every `.w` / `.h` / `.r` / `.sp` by
/// `window / designSize`, and that ratio has no upper bound. On a phone it
/// stays near 1 and nobody notices. On a tablet it does not: a 393-wide design
/// on an 820-wide iPad scales *2.09*, so a 16 gutter paints at 33 and a 56 bar
/// at 117 — the same app, photographed and enlarged, rather than an app using
/// the extra room. Landscape is worse in the other direction: the width ratio
/// hits 3.0 while `minTextAdapt` takes the *smaller* of the two ratios for
/// text, so the gutters triple while the type gets slightly *smaller* than on
/// an iPhone.
///
/// [designSize] removes the bound by moving the design instead of the window:
/// hand screenutil a design as large as the window divided by [maxScale] and
/// the ratio can never exceed [maxScale].
///
/// ```text
/// window 393×852  (iPhone 15)     → design 393×852   → scale 1.00  (unchanged)
/// window 820×1180 (iPad 11", ptr) → design 713×1026  → scale 1.15
/// window 1180×820 (iPad 11", lnd) → design 1026×852  → scale 1.15 / 0.96
/// ```
///
/// A tablet is *not* the place to stop scaling altogether (`scale 1.0` would
/// leave a phone-sized app marooned on a big screen); it is the place to stop
/// scaling *proportionally*. The extra width goes to layout — more columns, a
/// centred column of a readable width — which is a decision a widget makes,
/// not a multiplier.
final class SdScreenScale {
  const SdScreenScale._();

  /// How much larger than the design a tablet is allowed to render.
  ///
  /// 1.15 is "the same app, at arm's length": type and touch targets grow
  /// enough that an iPad held further away reads like a phone held close, and
  /// not so much that the app looks like a phone screenshot blown up. Every
  /// number in [SdSpacingConstant] moves by this and nothing else, so the
  /// rhythm between them is exactly the one it was drawn at.
  static const double maxScale = 1.15;

  /// The design size to hand `ScreenUtilInit`, given the window it will render
  /// into.
  ///
  /// Never smaller than [design], so every phone keeps the scale it has today
  /// — the widest iPhone is 440 logical pixels and 440 / [maxScale] is 383,
  /// still under a 393 design. The clamp only ever engages on a tablet or a
  /// desktop-sized window.
  static Size designSize(Size window, Size design) => Size(
    math.max(design.width, window.width / maxScale),
    math.max(design.height, window.height / maxScale),
  );
}
