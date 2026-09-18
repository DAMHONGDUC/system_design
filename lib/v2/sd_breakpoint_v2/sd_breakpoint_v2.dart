import '../../core/sd_spacing_constant.dart';

/// The widths a layout stops growing at.
///
/// The app is one column of cards on every device, and on a tablet that column
/// has to stop somewhere: at 1180 wide a card list is a line the eye loses its
/// place in and a chart stretched into a horizon. Past the ceiling the extra
/// room becomes margin.
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
  /// The widest a column of content is ever drawn — what `SdScaffoldV2` caps
  /// its body at, and what a screen building its own `Scaffold` reaches for
  /// through `SdPageWidthV2`.
  static double get contentMaxWidth => SdSpacingConstant.w600;

  /// The widest the floating nav pill is ever drawn. Narrower than
  /// [contentMaxWidth] on purpose: five glyphs spread across a 690-wide bar
  /// stop reading as one control, and the thumb has to cross the whole screen
  /// to change tab.
  static double get floatingBarMaxWidth => SdSpacingConstant.w480;

  /// The widest a dialog is ever drawn. A question asked across a whole iPad
  /// reads as a page, not as a prompt.
  static double get dialogMaxWidth => SdSpacingConstant.w480;
}
