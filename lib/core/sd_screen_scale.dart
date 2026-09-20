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
/// the extra room.
///
/// [designSize] removes the bound by moving the design instead of the window:
/// hand screenutil a design as large as the window divided by [maxScale] and
/// the ratio can never exceed [maxScale].
///
/// **Four tokens, four of screenutil's ratios, and they must not disagree.**
/// `.w` takes the width ratio, `.sp` takes it too (`ScreenUtilInit`'s default
/// `fontSizeResolver` is `FontSizeResolvers.width`, which is what actually
/// decides type here — `minTextAdapt` is inert beside it), `.h` takes the
/// height ratio, and `.r` — every icon, every radius, every square tap target —
/// takes **`min` of the two**. So a design height floored at a phone's while
/// the width grew is not a detail: on a landscape iPad the height ratio came
/// out 0.96 against a width ratio of 1.15, and the app drew 23-wide icons and
/// **42-wide tap targets** — smaller than the phone it was scaled up from, and
/// under Apple's 44 minimum — beside 18 gutters and 16 type.
///
/// That is why the height follows the same ceiling as the width once the clamp
/// engages, rather than never dropping below the design: past that point the
/// window is a tablet, and a tablet should render **one** scale.
///
/// ```text
/// window 393×852  (iPhone 15)     → design 393×852  → 1.00 / 1.00 (unchanged)
/// window 440×956  (iPhone 16 Max) → design 393×852  → 1.12 / 1.12 (unchanged)
/// window 820×1180 (iPad 11", ptr) → design 656×944  → 1.25 / 1.25
/// window 1180×820 (iPad 11", lnd) → design 944×656  → 1.25 / 1.25
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
  /// "The same app, at arm's length": type and touch targets grow enough that
  /// an iPad held further away reads like a phone held close, and not so much
  /// that the app looks like a phone screenshot blown up. Every number in
  /// `SdSpacingConstant` moves by this and nothing else, so the rhythm between
  /// them is exactly the one it was drawn at.
  ///
  /// 1.25, raised from 1.15 (owner's call, 2026-09-20): at 1.15 an iPad read as
  /// a phone layout with a lot of empty page around it. Anything above 1.25
  /// wants a taller app bar than `SdAppBarV2.toolbarHeight` gives, and past
  /// ~1.4 the app is the blown-up screenshot this class exists to prevent.
  static const double maxScale = 1.25;

  /// The design size to hand `ScreenUtilInit`, given the window it will render
  /// into.
  ///
  /// Never narrower than [design], so every phone keeps the scale it has today
  /// — the widest iPhone is 440 logical pixels and 440 / [maxScale] is 352,
  /// still under a 393 design. The clamp only ever engages above
  /// `design.width * maxScale` (491), which is a tablet or a desktop-sized
  /// window and never a phone in any orientation this app ships in.
  static Size designSize(Size window, Size design) {
    final double width = math.max(design.width, window.width / maxScale);

    // Once the width clamp engages the window is a tablet, and the height
    // follows the same ceiling rather than a phone's floor — see the class
    // comment: a floor here is what made `.r` shrink icons and tap targets in
    // landscape while everything measured across the window grew.
    return Size(
      width,
      width > design.width
          ? window.height / maxScale
          : math.max(design.height, window.height / maxScale),
    );
  }
}
