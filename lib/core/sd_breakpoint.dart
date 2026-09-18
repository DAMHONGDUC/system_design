import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// The three window widths the app lays out for.
///
/// A named width rather than a number at a call site: `width > 600` says
/// nothing about what 600 was, and the second call site to type it is the one
/// that types a different number.
///
/// Read it from `context.sdBreakpoint3`, never by comparing a width.
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

/// Where one width ends and the next begins, and how far a token's scale is
/// allowed to travel.
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

  /// The most screenutil may scale a token by.
  ///
  /// Above every phone the app ships to — the widest is a little over 1.1 —
  /// so a phone resolves exactly the dimension it resolved before the clamp
  /// existed and nothing in [SdBreakpoint.compact] moves. A tablet stops
  /// here, which is the whole point: extra width should buy more content, not
  /// a larger copy of the same content.
  static const double maxTokenScale = 1.15;

  /// Which width a window of [width] logical pixels is.
  static SdBreakpoint of(double width) {
    if (width < compactMaxWidth) return SdBreakpoint.compact;
    if (width < mediumMaxWidth) return SdBreakpoint.medium;

    return SdBreakpoint.expanded;
  }

  /// The design size to hand `ScreenUtilInit` so a token's scale never passes
  /// [maxTokenScale].
  ///
  /// screenutil divides the window by the design size, so the clamp is
  /// applied by growing the canvas rather than by capping the result — which
  /// is why this returns a size rather than a factor.
  ///
  /// **Clamped, never switched at a threshold.** A canvas that changed at one
  /// width would make every dimension in the app jump at that width; nothing
  /// notices on a device that cannot resize, and it is a lurch on the one
  /// device that can.
  static Size designSizeFor({required Size window, required Size base}) =>
      Size(
        math.max(base.width, window.width / maxTokenScale),
        math.max(base.height, window.height / maxTokenScale),
      );
}
