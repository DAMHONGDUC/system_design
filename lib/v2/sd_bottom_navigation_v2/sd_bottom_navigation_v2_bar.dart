part of 'sd_bottom_navigation_v2.dart';

/// The floating frosted pill itself: the glass frame, and inside it a
/// highlight that *slides* under the selected destination instead of
/// Material's fade-in indicator.
///
/// Private because it is not separately useful: without
/// [SdFloatingBarScopeV2] above it and `extendBody` around it, the bar
/// refracts a blank strip and every screen behind it loses its last row. The
/// two ship as one widget for that reason.
class _GlassNavBar extends StatelessWidget {
  const _GlassNavBar({
    required this.destinations,
    required this.selectedIndex,
    required this.onSelected,
  });

  /// Barely there: this is a wide surface, and the same 18% the small icons
  /// pop by would read as the whole bar lurching.
  static const double _popPeakScale = 1.02;

  final List<SdNavDestinationV2> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  /// The tint on the thumb. Strong enough to read as a switcher thumb over
  /// the glass without becoming a solid button.
  static const double selectedThumbOpacity = 0.22;

  /// Test seam. The thumb's whole point is where it is and how wide it is
  /// mid-flight, and both are real layout — a test measures its rect rather
  /// than reading a widget's arguments back.
  @visibleForTesting
  static const Key selectedCapsuleKey = Key('sd-bottom-navigation-v2-thumb');

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(
      SdContentPaddingV2.floatingBarHorizontal,
      0,
      SdContentPaddingV2.floatingBarHorizontal,
      SdContentPaddingV2.navBarOffset(context),
    ),
    child: SdPopScaleV2(
      peakScale: _popPeakScale,
      // The pill keeps its bottom edge on the safe-area line and grows up.
      alignment: Alignment.bottomCenter,
      child: LiquidGlass.withOwnLayer(
        settings: kChromeGlass,
        shape: LiquidRoundedSuperellipse(
          borderRadius: SdContentPaddingV2.floatingBarRadius,
        ),
        clipBehavior: Clip.antiAlias,
        // `Scaffold` hands its bottom slot the device inset; the pill already
        // clears it through `navBarOffset`, and taking it twice lifts the bar
        // off the bottom of the screen by a home indicator's height.
        child: MediaQuery.removePadding(
          context: context,
          removeBottom: true,
          child: SizedBox(
            // Shared with the log flow's step bar and with what content
            // clears — see `SdContentPaddingV2.floatingBarHeight`.
            height: SdContentPaddingV2.floatingBarHeight,
            child: Stack(
              // Expand, or the row of segments takes only the height of its
              // own glyphs and the Stack parks it at the top edge.
              fit: StackFit.expand,
              children: <Widget>[
                _SelectedThumb(
                  count: destinations.length,
                  selectedIndex: selectedIndex,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    for (final (int index, SdNavDestinationV2 destination)
                        in destinations.indexed)
                      Expanded(
                        child: _NavSegment(
                          destination: destination,
                          selected: index == selectedIndex,
                          onTap: () => onSelected(index),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

/// The tinted thumb that marks the current tab and slides to the next one.
///
/// **Always one segment wide.** This is a glyph-only bar: a thumb that widens
/// has no label to make room for and reads as unrelated motion.
class _SelectedThumb extends StatelessWidget {
  const _SelectedThumb({required this.count, required this.selectedIndex});

  /// Calm, and under the 400ms ceiling (WIDGET_RULES § 6).
  static const Duration _slide = Duration(milliseconds: 250);

  final int count;
  final int selectedIndex;

  @override
  Widget build(BuildContext context) => AnimatedAlign(
    duration: _slide,
    curve: Curves.easeOutCubic,
    // Alignment.x spans -1 (start) … 1 (end).
    alignment: AlignmentDirectional(
      count == 1 ? 0 : -1 + 2 * selectedIndex / (count - 1),
      0,
    ),
    child: FractionallySizedBox(
      widthFactor: 1 / count,
      heightFactor: 1,
      child: Padding(
        // Slim inset so the thumb hugs the pill's border. Paint only — the
        // segment underneath is still hit edge to edge.
        padding: EdgeInsets.symmetric(
          horizontal: SdSpacingConstant.w6,
          vertical: SdSpacingConstant.h6,
        ),
        child: DecoratedBox(
          key: _GlassNavBar.selectedCapsuleKey,
          decoration: BoxDecoration(
            color: context.colorScheme.primary.withValues(
              alpha: _GlassNavBar.selectedThumbOpacity,
            ),
            // Oversized radius = stadium caps, matching the pill.
            borderRadius: BorderRadius.circular(SdSpacingConstant.r64),
          ),
        ),
      ),
    ),
  );
}
