import 'package:flutter/material.dart';

import '../sd_content_padding_v3/sd_content_padding_v3.dart';
import '../sd_context_v3/sd_context_v3.dart';
import '../sd_floating_bar_scope_v3/sd_floating_bar_scope_v3.dart';
import '../sd_motion_v3/sd_motion_v3.dart';
import '../sd_nav_cell_v3/sd_nav_cell_v3.dart';
import '../sd_nav_panel_scope_v3/sd_nav_panel_scope_v3.dart';
import '../sd_nav_panel_toggle_v3/sd_nav_panel_toggle_v3.dart';
import '../sd_scaffold_v3/sd_scaffold_v3.dart';

part 'sd_nav_panel_v3_panel.dart';

/// Proportional tablet navigation; the host owns expansion and routing state.
/// The toggle is separate from the destinations so it never becomes a tab.
///
/// **Collapsed, the panel draws nothing at all.** It publishes
/// [SdNavPanelScopeV3] over the content and the screen's own chrome hosts the
/// reopen control — see [SdNavPanelToggleV3.collapsedOf]. So the content
/// starts where it would with no sidebar, and the top safe inset has one
/// owner in both states: the screen's app bar.
class SdNavPanelV3 extends StatelessWidget {
  const SdNavPanelV3({
    required this.body,
    required this.destinations,
    required this.selectedIndex,
    required this.onSelected,
    required this.isExpanded,
    required this.onExpansionChanged,
    required this.expandLabel,
    required this.collapseLabel,
    super.key,
  }) : assert(destinations.length > 0),
       assert(selectedIndex >= 0 && selectedIndex < destinations.length);

  final Widget body;
  final List<SdNavDestinationV3> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final bool isExpanded;
  final ValueChanged<bool> onExpansionChanged;
  final String expandLabel;
  final String collapseLabel;

  static const int expandedPanelFlex = 1;
  static const int expandedContentFlex = 4;
  static const int collapsedPanelFlex = 0;
  static const int collapsedContentFlex = 4;

  @visibleForTesting
  static const Key selectedCapsuleKey = Key('sd-nav-panel-capsule');

  @visibleForTesting
  static const Key panelSurfaceKey = Key('sd-nav-panel-surface');

  @visibleForTesting
  static const Key panelRegionKey = Key('sd-nav-panel-region');

  @visibleForTesting
  static const Key contentRegionKey = Key('sd-nav-panel-content');

  @override
  Widget build(BuildContext context) => SdScaffoldV3(
    pageMargin: false,
    body: SdFloatingBarScopeV3(
      edge: SdFloatingBarEdgeV3.leading,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(
          begin: isExpanded ? 1 : 0,
          end: isExpanded ? 1 : 0,
        ),
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : SdMotionV3.normal,
        curve: SdMotionV3.emphasized,
        builder: (context, progress, child) => Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(
              key: panelRegionKey,
              width:
                  MediaQuery.sizeOf(context).width *
                  expandedPanelFlex /
                  (expandedPanelFlex + expandedContentFlex) *
                  progress,
              child: ClipRect(
                child: OverflowBox(
                  alignment: Alignment.centerLeft,
                  minWidth:
                      MediaQuery.sizeOf(context).width *
                      expandedPanelFlex /
                      (expandedPanelFlex + expandedContentFlex),
                  maxWidth:
                      MediaQuery.sizeOf(context).width *
                      expandedPanelFlex /
                      (expandedPanelFlex + expandedContentFlex),
                  child: progress > 0
                      ? IgnorePointer(
                          ignoring: !isExpanded,
                          child: ExcludeSemantics(
                            excluding: !isExpanded,
                            child: _Panel(
                              destinations: destinations,
                              selectedIndex: selectedIndex,
                              onSelected: onSelected,
                              isExpanded: isExpanded,
                              onToggle: () => onExpansionChanged(false),
                              toggleLabel: collapseLabel,
                            ),
                          ),
                        )
                      : null,
                ),
              ),
            ),
            Expanded(
              child: SdNavPanelScopeV3(
                isExpanded: isExpanded,
                onExpand: () => onExpansionChanged(true),
                expandLabel: expandLabel,
                child: Align(
                  key: contentRegionKey,
                  alignment: Alignment.topCenter,
                  child: body,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
