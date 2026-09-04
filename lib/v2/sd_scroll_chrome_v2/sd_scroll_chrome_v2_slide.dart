part of 'sd_scroll_chrome_v2.dart';

/// Slides one piece of chrome off [edge] while the body under it is moving,
/// and back when it stops.
///
/// Wrap the chrome at its outermost box — margins included — so a whole
/// travel of its own height clears the screen: the nav pill wrapped inside
/// its bottom offset would stop with that offset still on screen.
///
/// **It changes no layout.** The slide is a paint transform and the chrome
/// keeps its slot, which is the only reason this is safe on a `Scaffold`
/// whose body already passes behind the bar and the pill: the body does not
/// move, so nothing reflows twice per gesture.
///
/// With no [SdScrollChromeV2] above it the child is returned untouched.
class SdScrollChromeSlideV2 extends StatelessWidget {
  const SdScrollChromeSlideV2({
    required this.edge,
    required this.child,
    this.pinned = false,
    super.key,
  });

  /// The same 250ms the rest of the app's chrome moves in, well under the
  /// 400ms ceiling (WIDGET_RULES § 6).
  static const Duration duration = Duration(milliseconds: 250);

  final SdScrollChromeEdgeV2 edge;

  /// True keeps the chrome where it is. For the one case where hiding it
  /// takes away what the user is working in — the medications tab while its
  /// search field owns the app bar.
  final bool pinned;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ValueListenable<bool>? visible = pinned
        ? null
        : SdScrollChromeV2.maybeOf(context);

    if (visible == null) return child;

    return ValueListenableBuilder<bool>(
      valueListenable: visible,
      // Passed through rather than rebuilt: the chrome's own content has
      // nothing to do with whether it is showing.
      child: child,
      builder: (BuildContext context, bool showing, Widget? child) =>
          IgnorePointer(
            // Gone means gone: a tap where the bar used to be reaches the
            // list, not a button that is off screen.
            ignoring: !showing,
            child: AnimatedSlide(
              offset: showing ? Offset.zero : edge.hiddenOffset,
              duration: duration,
              curve: Curves.easeOutCubic,
              child: child,
            ),
          ),
    );
  }
}
