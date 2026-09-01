import 'package:flutter/animation.dart';

/// The one owner of v4 durations and curves. Feature code names a motion, it
/// never spells out milliseconds.
final class SdMotionV4 {
  /// Scrolling freshly produced content into view.
  static const Duration reveal = Duration(milliseconds: 320);

  /// Expanding or collapsing a disclosure.
  static const Duration disclose = Duration(milliseconds: 200);

  /// Decelerating curve for content the user did not drag themselves.
  static const Curve settle = Curves.easeOutCubic;
}
