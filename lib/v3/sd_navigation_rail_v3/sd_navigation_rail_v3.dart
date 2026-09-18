import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

import '../sd_content_padding_v3/sd_content_padding_v3.dart';
import '../sd_context_v3/sd_context_v3.dart';
import '../sd_elevation_v3/sd_elevation_v3.dart';
import '../sd_floating_bar_scope_v3/sd_floating_bar_scope_v3.dart';
import '../sd_motion_v3/sd_motion_v3.dart';
import '../sd_nav_cell_v3/sd_nav_cell_v3.dart';
import '../sd_scaffold_v3/sd_scaffold_v3.dart';

/// The same five destinations, standing up. **The tablet's chrome.**
///
/// The shell builds this instead of `SdGlassNavBarV3` on anything wider than
/// a phone, and nothing else in the app knows which one is up. The two share
/// [SdNavCellV3] and the glass; what differs is a consequence of the axis and
/// nothing else.
///
/// **A real column, not a floating strip.** A phone has no width to give away
/// and a tablet does, so the rail takes its own column and the body gets what
/// is left — which means no screen has to pad a side for it. That is also why
/// this is not handed to `Scaffold.bottomNavigationBar` and why `extendBody`
/// is not set: nothing passes underneath.
///
/// **No inner margin.** The gap between the rail and the content is the
/// content's own `SdContentPaddingV3.pageMargin`. A margin drawn here would
/// stack on top of it and make one of the three gaps wider than the other
/// two.
///
/// **No adjacent-tab swipe.** That is a thumb gesture on a one-handed device;
/// at this width a horizontal drag is a chart being panned or a row being
/// dismissed, and taking it would break both.
class SdNavigationRailV3 extends StatelessWidget {
  const SdNavigationRailV3({
    required this.body,
    required this.destinations,
    required this.selectedIndex,
    required this.onSelected,
    super.key,
  }) : assert(destinations.length > 0),
       assert(selectedIndex >= 0 && selectedIndex < destinations.length);

  final Widget body;
  final List<SdNavDestinationV3> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  /// Test seam, the same one the pill offers: the thumb's rect is real layout
  /// and a test measures it rather than reading arguments back.
  @visibleForTesting
  static const Key selectedCapsuleKey = Key('sd-navigation-rail-capsule');

  @override
  Widget build(BuildContext context) => SdScaffoldV3(
    pageMargin: false,
    body: SdFloatingBarScopeV3(
      edge: SdFloatingBarEdgeV3.leading,
      child: Row(
        children: <Widget>[
          _Rail(
            destinations: destinations,
            selectedIndex: selectedIndex,
            onSelected: onSelected,
          ),
          Expanded(child: body),
        ],
      ),
    ),
  );
}

/// The glass capsule itself: as long as its cells and no longer, centred down
/// the window.
///
/// Sized to the cells rather than run to the full height because it is the
/// same control as the phone's pill — a bar that reached both edges would be
/// a sidebar, which is a different thing wearing the same glyphs.
class _Rail extends StatelessWidget {
  const _Rail({
    required this.destinations,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<SdNavDestinationV3> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final double thickness = SdContentPaddingV3.railThickness;
    final double radius = thickness / 2;

    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: SdContentPaddingV3.tabletMargin,
      ),
      child: Center(
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            boxShadow: SdElevationV3.modal(context),
          ),
          child: LiquidGlass.withOwnLayer(
            shape: LiquidRoundedSuperellipse(borderRadius: radius),
            settings: SdGlassV3.settings(context),
            fake: !SdGlassV3.isSupported,
            glassContainsChild: false,
            child: SizedBox(
              width: thickness,
              height:
                  SdContentPaddingV3.railCellLength * destinations.length,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  _SelectedCapsule(
                    count: destinations.length,
                    selectedIndex: selectedIndex,
                  ),
                  Column(
                    children: <Widget>[
                      for (int i = 0; i < destinations.length; i++)
                        Expanded(
                          child: SdNavCellV3(
                            destination: destinations[i],
                            selected: i == selectedIndex,
                            onTap: () => onSelected(i),
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
}

/// The tinted thumb, sliding down the rail instead of across the bar.
class _SelectedCapsule extends StatelessWidget {
  const _SelectedCapsule({required this.count, required this.selectedIndex});

  final int count;
  final int selectedIndex;

  @override
  Widget build(BuildContext context) => AnimatedAlign(
    duration: SdMotionV3.normal,
    curve: SdMotionV3.emphasized,
    alignment: AlignmentDirectional(
      0,
      count == 1 ? 0 : -1 + 2 * selectedIndex / (count - 1),
    ),
    child: FractionallySizedBox(
      widthFactor: 1,
      heightFactor: 1 / count,
      child: Padding(
        padding: SdContentPaddingV3.selectedTabInset,
        child: DecoratedBox(
          key: SdNavigationRailV3.selectedCapsuleKey,
          decoration: BoxDecoration(
            color: context.colorScheme3.primary.withValues(
              alpha: SdGlassV3.selectedThumbOpacity,
            ),
            borderRadius: BorderRadius.circular(
              SdContentPaddingV3.selectedTabRadius,
            ),
          ),
          child: const SizedBox.expand(),
        ),
      ),
    ),
  );
}
