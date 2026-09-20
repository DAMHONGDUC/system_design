/// The three window widths the app lays out for.
///
/// A named width rather than a number at a call site: `width > 600` says
/// nothing about what 600 was, and the second call site to type it is the one
/// that types a different number.
///
/// Read it from `context.sdBreakpoint3`, never by comparing a width.
///
/// **How far a token is allowed to scale is not here** — that is
/// `SdScreenScale`, and it is deliberately one class away from this one. A
/// width class is a layout decision made at a threshold; the scale is a ratio
/// that never steps at one. Two answers to "how big is this tablet?" is how
/// they drift.
enum SdBreakpoint {
  /// Every phone the app ships to, and a split view narrow enough to be one.
  compact,

  /// Tablet portrait, an unfolded foldable, a half-width split view.
  medium,

  /// Tablet landscape — the only width with room beside the content.
  expanded;

  /// True for anything that is not a phone.
  ///
  /// The common question: most layouts care whether there is spare width, not
  /// how much of it there is.
  bool get isWide => this != SdBreakpoint.compact;
}

/// Where one width ends and the next begins.
///
/// **These are raw logical pixels and deliberately not `SdSpacingConstant`.**
/// Every value there is scaled by screenutil against the design canvas, and a
/// threshold that decides how wide the window is cannot itself be scaled by
/// how wide the window is — it would move as the thing it measures moves.
final class SdBreakpointConstant {
  /// Below this the window is a phone.
  static const double compactMaxWidth = 600;

  /// Below this the window is a tablet held upright: spare width, but not
  /// enough to put anything beside the content.
  static const double mediumMaxWidth = 840;

  /// Which width a window of [width] logical pixels is.
  static SdBreakpoint of(double width) {
    if (width < compactMaxWidth) return SdBreakpoint.compact;
    if (width < mediumMaxWidth) return SdBreakpoint.medium;

    return SdBreakpoint.expanded;
  }
}
