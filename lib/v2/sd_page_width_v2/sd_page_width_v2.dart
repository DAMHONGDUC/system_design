import 'package:flutter/widgets.dart';

import '../sd_breakpoint_v2/sd_breakpoint_v2.dart';

/// Caps its child at [SdBreakpointV2.contentMaxWidth] and centres it.
///
/// This is the whole of the app's tablet layout that is not a decision about
/// content: every screen is a single column, and on a wide window that column
/// stops growing and the leftover becomes margin.
///
/// `SdScaffoldV2` already wraps its body in this, so a screen built on it gets
/// it for nothing. Reach for it directly only where a screen builds its own
/// `Scaffold` (onboarding, the paywall) or where only *part* of a body is
/// content — `SdCollapsingFilterScaffoldV2` wraps its list but not the frosted
/// filter strip above it, which is chrome and spans the window.
///
/// **On a phone it does nothing.** The cap is wider than any phone, so this
/// widget is a no-op there and cannot change a layout that ships today.
class SdPageWidthV2 extends StatelessWidget {
  const SdPageWidthV2({required this.child, this.maxWidth, super.key});

  final Widget child;

  /// Overrides [SdBreakpointV2.contentMaxWidth] for the rare screen that
  /// reads better narrower (a single form) or wider (a full-bleed chart).
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    return Align(
      // Top, not centre: a child that shrink-wraps (a Column of
      // `mainAxisSize.min`) would otherwise float to the middle of the
      // viewport, which is a different screen from the one it was drawn as.
      // A scroll view fills the loose constraints either way.
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? SdBreakpointV2.contentMaxWidth,
        ),
        child: child,
      ),
    );
  }
}
