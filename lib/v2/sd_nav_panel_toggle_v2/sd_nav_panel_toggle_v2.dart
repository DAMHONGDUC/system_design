import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../sd_app_bar_button_v2/sd_app_bar_button_v2.dart';
import '../sd_nav_panel_scope_v2/sd_nav_panel_scope_v2.dart';

/// The one control that opens and closes `SdNavPanelV2`.
///
/// **Where it is drawn is the whole of what it knows.** Expanded, it sits in
/// the panel's own header, because that is the thing it closes. Collapsed, the
/// panel draws nothing and cannot hold it, so the screen's chrome takes it as
/// its leading control — the way every app with a drawer does it. With the
/// control in the chrome, the top safe inset has one owner in both states (the
/// screen's app bar) and collapsed content starts exactly where it would with
/// no panel at all.
///
/// Same glyph in both states on purpose: it is the menu, and a user reaches for
/// the same mark whichever side of the toggle they are on. The two states are
/// told apart by the tooltip and by `Semantics(expanded:)`, never by swapping
/// the icon.
///
/// It is an `SdAppBarButtonV2` in both places, so the button that closes the
/// panel and the button that reopens it cannot come out two different sizes —
/// and the glass circle has real background to refract either way, the app
/// bar's blurred strip or the panel's flat surface.
class SdNavPanelToggleV2 extends StatelessWidget {
  const SdNavPanelToggleV2({
    required this.expanded,
    required this.label,
    required this.onPressed,
    super.key,
  });

  /// Whether the panel this closes is currently open. Announced, not drawn.
  final bool expanded;

  /// Tooltip and semantics label — "Collapse navigation" or "Expand
  /// navigation", localized by the host.
  final String label;

  final VoidCallback onPressed;

  /// The glyph, in both states.
  static const IconData menuIcon = Symbols.menu_rounded;

  /// The handle for whichever of the two places the control is drawn in right
  /// now — **never both at once**, so a finder on it is unambiguous
  /// mid-animation: the panel carries it only while expanded, [collapsedOf]
  /// only while it is not.
  static const Key toggleKey = Key('sd-nav-panel-v2-toggle');

  /// The control a collapsed panel owes [context], or null when there is
  /// nothing to reopen — no panel beside this screen, or one already open.
  ///
  /// **Every chrome with a leading slot calls this, and no screen does.** A
  /// screen that placed it itself is a screen that can forget to, and the one
  /// that forgets is the one a user gets stuck on.
  static Widget? collapsedOf(BuildContext context) {
    final SdNavPanelScopeV2? scope = SdNavPanelScopeV2.of(context);

    if (scope == null || scope.isExpanded) return null;

    return SdNavPanelToggleV2(
      key: toggleKey,
      expanded: false,
      label: scope.expandLabel,
      onPressed: scope.onExpand,
    );
  }

  @override
  Widget build(BuildContext context) => Semantics(
    expanded: expanded,
    child: SdAppBarButtonV2(
      icon: menuIcon,
      tooltip: label,
      onPressed: onPressed,
    ),
  );
}
