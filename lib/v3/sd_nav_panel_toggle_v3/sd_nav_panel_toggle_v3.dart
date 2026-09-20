import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../core/sd_spacing_constant.dart';
import '../sd_icon_v3/sd_icon_v3.dart';
import '../sd_nav_panel_scope_v3/sd_nav_panel_scope_v3.dart';

/// The one control that opens and closes the tablet sidebar.
///
/// Same glyph in both states on purpose: it is the menu, and a seller reaches
/// for the same mark whichever side of the toggle they are on.
///
/// **Where it is drawn depends on which state it is in.** Expanded, it sits in
/// the sidebar's own header, because that is the thing it closes. Collapsed,
/// the sidebar is gone and cannot draw anything — so the screen's chrome takes
/// it as its leading control, the way every app with a drawer does it. The
/// alternative, a strip of chrome above the content, is a row that belongs to
/// no screen and pushes all of them down.
class SdNavPanelToggleV3 extends StatelessWidget {
  const SdNavPanelToggleV3({
    required this.expanded,
    required this.label,
    required this.onPressed,
    super.key,
  });

  final bool expanded;
  final String label;
  final VoidCallback onPressed;

  /// The handle for whichever of the two places the control is drawn in right
  /// now — never both at once, so a finder on it is unambiguous mid-animation:
  /// the sidebar carries it only while expanded, [collapsedOf] only while not.
  static const Key toggleKey = Key('sd-nav-panel-toggle');

  /// The width a chrome gives it, so a title beside it lands where the same
  /// title lands on a screen whose bar draws its own leading. `AppBar` takes
  /// this much on its own; a chrome laying itself out asks for it.
  static double get slot => SdSpacingConstant.w56;

  /// The control a collapsed sidebar owes [context], or null when there is
  /// nothing to reopen — no sidebar beside this screen, or one already open.
  ///
  /// **Every chrome with a leading slot calls this, and no screen does.** A
  /// screen that placed it itself is a screen that can forget to, and the one
  /// that forgets is the one a seller gets stuck on.
  static Widget? collapsedOf(BuildContext context) {
    final SdNavPanelScopeV3? scope = SdNavPanelScopeV3.of(context);

    if (scope == null || scope.isExpanded) return null;

    return SdNavPanelToggleV3(
      key: toggleKey,
      expanded: false,
      label: scope.expandLabel,
      onPressed: scope.onExpand,
    );
  }

  @override
  Widget build(BuildContext context) => Semantics(
    expanded: expanded,
    child: IconButton(
      tooltip: label,
      onPressed: onPressed,
      icon: SdIconV3(Symbols.menu),
    ),
  );
}
