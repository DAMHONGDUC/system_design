import 'package:flutter/material.dart';

import '../sd_app_bar_v2/sd_app_bar_v2.dart';
import '../sd_content_padding_v2/sd_content_padding_v2.dart';
import '../sd_context_v2/sd_context_v2.dart';
import '../sd_floating_bar_scope_v2/sd_floating_bar_scope_v2.dart';
import '../sd_nav_destination_v2/sd_nav_destination_v2.dart';
import '../sd_nav_panel_scope_v2/sd_nav_panel_scope_v2.dart';
import '../sd_nav_panel_toggle_v2/sd_nav_panel_toggle_v2.dart';
import '../sd_nav_segment_v2/sd_nav_segment_v2.dart';

part 'sd_nav_panel_v2_panel.dart';

/// The shell's navigation for a window wide enough to put it down the side: a
/// collapsible panel taking a fifth of the window, joined to the content.
///
/// **Same destinations, same list, same order as the phone's pill.** The
/// breakpoint chooses the frame and never the contents — a destination that
/// existed only on a tablet is the bug that rule exists to stop. It shares
/// `SdNavSegmentV2` with the pill rather than drawing its own cell, so a tab
/// cannot read as one control on a phone and another on an iPad. What differs
/// follows from the axis and from the room: the cell draws its label
/// ([SdNavSegmentShapeV2.row]), and the panel takes a real column instead of
/// floating over the body.
///
/// **It is a surface, not glass.** The pill floats over content that scrolls
/// behind it, which is what glass is for; this meets the content region edge to
/// edge with nothing behind it to refract, the way iPad Settings joins its
/// sidebar to its pane.
///
/// **Collapsed, it draws nothing at all** — not a narrow rail, not a strip of
/// chrome above the content. It publishes [SdNavPanelScopeV2] over the content
/// and the screen's own app bar hosts the reopen control; see
/// `SdNavPanelToggleV2.collapsedOf`.
///
/// It publishes `SdFloatingBarEdgeV2.leading` in both states, which is what
/// lets the five tab screens stop reserving a pill's height of nothing on the
/// bottom edge — see `SdContentPaddingV2.bottom`.
class SdNavPanelV2 extends StatelessWidget {
  const SdNavPanelV2({
    required this.body,
    required this.destinations,
    required this.selectedIndex,
    required this.onSelected,
    required this.isExpanded,
    required this.onExpansionChanged,
    required this.expandLabel,
    required this.collapseLabel,
    super.key,
  }) : assert(destinations.length > 0, 'A nav panel needs a destination.'),
       assert(
         selectedIndex >= 0 && selectedIndex < destinations.length,
         'selectedIndex is out of range for destinations.',
       );

  final Widget body;
  final List<SdNavDestinationV2> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  /// **The host owns this**, so toggling keeps the selected tab and all of its
  /// navigation state; the panel is told.
  final bool isExpanded;

  final ValueChanged<bool> onExpansionChanged;

  /// The reopen control's tooltip, localized by the host.
  final String expandLabel;

  /// The close control's tooltip, localized by the host.
  final String collapseLabel;

  /// Calm, and the same 250ms the rest of the app's chrome moves in.
  static const Duration _travel = Duration(milliseconds: 250);

  /// Eased at both ends: the panel and the content move as one joined pair, so
  /// the curve has to settle rather than arrive.
  static const Curve _curve = Curves.easeInOutCubic;

  /// The tint on the capsule marking the current tab, shared with the pill's
  /// thumb so the two chromes mark it at the same strength.
  static const double selectedCapsuleOpacity = 0.22;

  /// Test seam. The panel's width in each state is real layout, so a test
  /// measures this rect rather than reading an argument back.
  @visibleForTesting
  static const Key panelRegionKey = Key('sd-nav-panel-v2-region');

  /// Test seam: the painted surface, which exists only while the panel does.
  @visibleForTesting
  static const Key panelSurfaceKey = Key('sd-nav-panel-v2-surface');

  /// Test seam: the region the screen beside the panel is given.
  @visibleForTesting
  static const Key contentRegionKey = Key('sd-nav-panel-v2-content');

  /// Test seam: where the capsule is and how tall it is mid-flight are both
  /// real layout.
  @visibleForTesting
  static const Key selectedCapsuleKey = Key('sd-nav-panel-v2-capsule');

  @override
  Widget build(BuildContext context) {
    final double panelWidth = SdContentPaddingV2.navPanelWidth(context);
    final double target = isExpanded ? 1 : 0;

    return Scaffold(
      body: SdFloatingBarScopeV2(
        edge: SdFloatingBarEdgeV2.leading,
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: target, end: target),
          // The user who turned motion off in iOS Settings is not asked to find
          // a second switch here; the widths change on the next frame instead.
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : _travel,
          curve: _curve,
          builder: (BuildContext context, double progress, Widget? _) => Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // The room the panel takes, so the content is beside it and
                  // not under it.
                  SizedBox(width: panelWidth * progress),
                  Expanded(
                    child: KeyedSubtree(
                      key: contentRegionKey,
                      child: SdNavPanelScopeV2(
                        isExpanded: isExpanded,
                        onExpand: () => onExpansionChanged(true),
                        expandLabel: expandLabel,
                        child: body,
                      ),
                    ),
                  ),
                ],
              ),
              // **Painted after the content, never beside it in paint order.**
              // A full-screen route's modal barrier blocks the semantics of
              // everything painted before it, and the body is a Navigator full
              // of them — a panel painted first is a panel VoiceOver cannot
              // reach at all, which is what the rail before it was. It covers
              // only its own strip, so nothing below it loses a tap.
              PositionedDirectional(
                start: 0,
                top: 0,
                bottom: 0,
                child: _PanelRegion(
                  width: panelWidth,
                  progress: progress,
                  isExpanded: isExpanded,
                  child: _Panel(
                    destinations: destinations,
                    selectedIndex: selectedIndex,
                    onSelected: onSelected,
                    isExpanded: isExpanded,
                    collapseLabel: collapseLabel,
                    onCollapse: () => onExpansionChanged(false),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
