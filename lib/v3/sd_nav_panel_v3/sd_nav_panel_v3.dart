import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../sd_content_padding_v3/sd_content_padding_v3.dart';
import '../sd_context_v3/sd_context_v3.dart';
import '../sd_floating_bar_scope_v3/sd_floating_bar_scope_v3.dart';
import '../sd_icon_v3/sd_icon_v3.dart';
import '../sd_motion_v3/sd_motion_v3.dart';
import '../sd_nav_cell_v3/sd_nav_cell_v3.dart';
import '../sd_scaffold_v3/sd_scaffold_v3.dart';

part 'sd_nav_panel_v3_panel.dart';

/// Proportional tablet navigation; the host owns expansion and routing state.
/// The toggle is separate from the destinations so it never becomes a tab.
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

  @visibleForTesting
  static const Key toggleKey = Key('sd-nav-panel-toggle');

  @override
  Widget build(BuildContext context) => SdScaffoldV3(
    pageMargin: false,
    body: SdFloatingBarScopeV3(
      edge: SdFloatingBarEdgeV3.leading,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Flexible(
            fit: FlexFit.tight,
            flex: isExpanded ? expandedPanelFlex : collapsedPanelFlex,
            child: SizedBox(
              key: panelRegionKey,
              width: isExpanded ? null : 0,
              child: isExpanded
                  ? _Panel(
                      destinations: destinations,
                      selectedIndex: selectedIndex,
                      onSelected: onSelected,
                      isExpanded: isExpanded,
                      onToggle: () => onExpansionChanged(!isExpanded),
                      toggleLabel: collapseLabel,
                    )
                  : null,
            ),
          ),
          Expanded(
            flex: isExpanded ? expandedContentFlex : collapsedContentFlex,
            child: Column(
              key: contentRegionKey,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (!isExpanded)
                  SafeArea(
                    bottom: false,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: _PanelToggle(
                        expanded: false,
                        label: expandLabel,
                        onPressed: () => onExpansionChanged(true),
                      ),
                    ),
                  ),
                Expanded(
                  child: Align(alignment: Alignment.topCenter, child: body),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
