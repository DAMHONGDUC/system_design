import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

import '../../core/sd_spacing_constant.dart';
import '../sd_content_padding_v2/sd_content_padding_v2.dart';
import '../sd_context_v2/sd_context_v2.dart';
import '../sd_liquid_glass_theme_v2/sd_liquid_glass_theme_v2.dart';
import '../sd_nav_destination_v2/sd_nav_destination_v2.dart';
import '../sd_nav_segment_v2/sd_nav_segment_v2.dart';
import '../sd_pop_scale_v2/sd_pop_scale_v2.dart';

/// The shell's navigation for a window wide enough to put it down the side:
/// `SdBottomNavigationV2`'s pill, stood on its end against the leading edge.
///
/// **Same destinations, same glyph cell, same sliding thumb** — it shares
/// `SdNavSegmentV2` with the bar rather than drawing its own, so a tab cannot
/// look like one control on a phone and a different one on an iPad. What
/// differs is the axis and two things that follow from it:
///
/// - **It takes real layout space.** The pill floats and the body scrolls
///   behind it, because a phone has no width to give away. A tablet does, and
///   a rail in its own column means no screen has to pad a side for it —
///   which matters because every screen in this app builds its horizontal
///   insets by hand.
/// - **No swipe between tabs.** The pill's adjacent-tab swipe is a thumb
///   gesture on a device held in one hand. At this width a horizontal drag is
///   a chart being panned or a row being dismissed, and stealing it would
///   break both.
///
/// It deliberately does NOT wrap the body in `SdFloatingBarScopeV2`: nothing
/// rests on the bottom edge here, so a snackbar sits where it should and the
/// five tab screens stop reserving a pill's height of nothing (see
/// `SdContentPaddingV2.bottom`).
class SdNavigationRailV2 extends StatelessWidget {
  const SdNavigationRailV2({
    required this.body,
    required this.destinations,
    required this.selectedIndex,
    required this.onSelected,
    super.key,
  }) : assert(destinations.length > 0, 'A nav rail needs a destination.'),
       assert(
         selectedIndex >= 0 && selectedIndex < destinations.length,
         'selectedIndex is out of range for destinations.',
       );

  final Widget body;
  final List<SdNavDestinationV2> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  /// Test seam. How long the rail is and how thick it is are both real layout,
  /// so a test measures its rect rather than reading arguments back.
  @visibleForTesting
  static const Key railSurfaceKey = Key('sd-navigation-rail-v2-surface');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: <Widget>[
          _GlassNavRail(
            destinations: destinations,
            selectedIndex: selectedIndex,
            onSelected: onSelected,
          ),
          Expanded(child: body),
        ],
      ),
    );
  }
}

/// The floating frosted pill itself, vertical.
class _GlassNavRail extends StatelessWidget {
  const _GlassNavRail({
    required this.destinations,
    required this.selectedIndex,
    required this.onSelected,
  });

  /// The same barely-there pop the horizontal pill uses: this is a large
  /// surface, and the 18% the small icons pop by would read as the whole rail
  /// lurching.
  static const double _popPeakScale = 1.02;

  /// The tint on the thumb, shared with the bar so the two chromes mark the
  /// current tab at the same strength.
  static const double selectedThumbOpacity = 0.22;

  /// Test seam, as on the bar: the thumb's whole point is where it is and how
  /// tall it is mid-flight, and both are real layout.
  @visibleForTesting
  static const Key selectedCapsuleKey = Key('sd-navigation-rail-v2-thumb');

  final List<SdNavDestinationV2> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) => SizedBox(
    // The column the rail occupies: the pill's thickness plus its air either
    // side, derived from the pill's own numbers — see `floatingRailWidth`.
    width: SdContentPaddingV2.floatingRailWidth,
    child: Center(
      child: SdPopScaleV2(
        peakScale: _popPeakScale,
        child: LiquidGlass.withOwnLayer(
          settings: kChromeGlass,
          shape: LiquidRoundedSuperellipse(
            borderRadius: SdContentPaddingV2.floatingBarRadius,
          ),
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            key: SdNavigationRailV2.railSurfaceKey,
            // Thickness is the bar's height: the rail IS the pill turned, so
            // one number governs both and they cannot drift.
            width: SdContentPaddingV2.floatingBarHeight,
            // One cell per destination — longer than the rail is thick, so a
            // five-tab rail reads as one control rather than a column of
            // squares. See `floatingRailCellHeight`.
            height:
                SdContentPaddingV2.floatingRailCellHeight * destinations.length,
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                _SelectedThumb(
                  count: destinations.length,
                  selectedIndex: selectedIndex,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    for (final (int index, SdNavDestinationV2 destination)
                        in destinations.indexed)
                      Expanded(
                        child: SdNavSegmentV2(
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

/// The tinted thumb that marks the current tab and slides down to the next.
///
/// **Always one segment tall**, for the reason the bar's is always one segment
/// wide: this is a glyph-only chrome, and a thumb that grew has no label to
/// make room for.
class _SelectedThumb extends StatelessWidget {
  const _SelectedThumb({required this.count, required this.selectedIndex});

  /// Calm, and the same 250ms the bar's thumb and the rest of the app's chrome
  /// move in.
  static const Duration _slide = Duration(milliseconds: 250);

  final int count;
  final int selectedIndex;

  @override
  Widget build(BuildContext context) => AnimatedAlign(
    duration: _slide,
    curve: Curves.easeOutCubic,
    // Alignment.y spans -1 (top) … 1 (bottom).
    alignment: AlignmentDirectional(
      0,
      count == 1 ? 0 : -1 + 2 * selectedIndex / (count - 1),
    ),
    child: FractionallySizedBox(
      widthFactor: 1,
      heightFactor: 1 / count,
      child: Padding(
        // Slim inset so the thumb hugs the pill's border. Paint only — the
        // segment underneath is still hit edge to edge.
        padding: EdgeInsets.symmetric(
          horizontal: SdSpacingConstant.w6,
          vertical: SdSpacingConstant.h6,
        ),
        child: DecoratedBox(
          key: _GlassNavRail.selectedCapsuleKey,
          decoration: BoxDecoration(
            color: context.colorScheme.primary.withValues(
              alpha: _GlassNavRail.selectedThumbOpacity,
            ),
            // Oversized radius = stadium caps, matching the pill.
            borderRadius: BorderRadius.circular(SdSpacingConstant.r64),
          ),
        ),
      ),
    ),
  );
}
