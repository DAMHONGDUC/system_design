import 'package:flutter/widgets.dart';

import '../../core/sd_spacing_constant.dart';

/// How much room the app has, in three sizes.
///
/// Named after the *window*, never the device: an iPad in Split View hands the
/// app a 507-wide window, and chrome that asked "am I on an iPad" would put a
/// navigation rail in it.
enum SdWindowClassV2 {
  /// Every phone, and a tablet sharing its screen with another app.
  compact,

  /// A tablet in portrait (an 11" iPad is 820), or one taking two thirds of a
  /// landscape screen.
  medium,

  /// A tablet in landscape, or a desktop window.
  expanded,
}

/// The widths a layout stops growing at.
///
/// The app is one column of cards on every device, and on a tablet that column
/// has to stop somewhere: at 1180 wide a card list is a line the eye loses its
/// place in and a chart stretched into a horizon. Past the ceiling the extra
/// room becomes margin.
///
/// The column takes the **app bar with it** — `SdScaffoldV2` caps the whole
/// screen, not just the body, so a title and its content share one leading
/// edge. A header that spanned the window over a narrower column reads as two
/// screens stacked.
///
/// **Three ceilings, not one**, for the same reason `SdContentPaddingV2` keeps
/// `topGap` and `bottomGap` apart: a page of content, a bar of five glyphs and
/// a one-question dialog are three different things that happen to measure the
/// same today, and the day one of them moves it has nothing to say about the
/// others.
///
/// These are `.w` values, so they scale with the design like everything else —
/// capped by `SdScreenScale`, which is what keeps a "600" column from becoming
/// a 1254 one on a landscape iPad. Every ceiling is wider than any phone, so
/// none of them changes a layout that ships today.
abstract final class SdBreakpointV2 {
  /// At or above this the window is [SdWindowClassV2.medium], and the shell's
  /// navigation moves from the bottom edge to the left-hand side.
  ///
  /// Material's own window-size boundary, unchanged: it is where the hardware
  /// actually is (an 11" iPad is 820 portrait, a 13" is 1024), and inventing
  /// our own would put the boundary in the middle of a device.
  static const double medium = 600;

  /// At or above this the window is [SdWindowClassV2.expanded] — a tablet in
  /// landscape. Nothing switches here yet; it is the boundary a second column
  /// would appear at.
  static const double expanded = 840;

  /// **Raw logical pixels, never scaled.** These are compared against the
  /// window, which screenutil knows nothing about; a `.w` here would move the
  /// boundary every time the design scaled and a device could land in two
  /// classes at once.
  static SdWindowClassV2 of(BuildContext context) =>
      forWidth(MediaQuery.sizeOf(context).width);

  static SdWindowClassV2 forWidth(double width) => switch (width) {
    >= expanded => SdWindowClassV2.expanded,
    >= medium => SdWindowClassV2.medium,
    _ => SdWindowClassV2.compact,
  };

  /// The widest a screen is ever drawn — app bar, pinned filter strip and body
  /// alike. `SdScaffoldV2` applies it; a screen building its own `Scaffold`
  /// (onboarding, the paywall) reaches for `SdPageWidthV2` instead.
  ///
  /// 800 design units, which is 920 rendered on an iPad. An 11" portrait
  /// window is narrower than that once the rail takes its column, so the cap
  /// only actually bites in landscape — which is the one window with room to
  /// waste.
  static double get contentMaxWidth => SdSpacingConstant.w800;

  /// The widest the floating nav pill is ever drawn. Narrower than
  /// [contentMaxWidth] on purpose: five glyphs spread across a 690-wide bar
  /// stop reading as one control, and the thumb has to cross the whole screen
  /// to change tab.
  static double get floatingBarMaxWidth => SdSpacingConstant.w480;

  /// The widest a dialog is ever drawn. A question asked across a whole iPad
  /// reads as a page, not as a prompt.
  static double get dialogMaxWidth => SdSpacingConstant.w480;
}
