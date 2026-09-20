import 'package:flutter/widgets.dart';

/// What `SdNavPanelV2` publishes to the screen standing beside it.
///
/// The panel collapses to nothing at all, so something on screen has to be
/// able to bring it back. The panel says only *that* it is collapsed and *how*
/// to reopen it, and whichever chrome the screen is already wearing hosts the
/// control — see `SdNavPanelToggleV2.collapsedOf`. The alternative, a strip
/// holding a menu icon above the content, is a row of chrome that belongs to no
/// screen, pushes every one of them down, and takes a second claim on the top
/// safe inset the screen's own app bar already owns.
///
/// Wrapped once around the content column. A route pushed on the root
/// navigator — every detail screen in this app — sits outside the scope and
/// reads null, which is correct: there is no panel beside it to reopen.
///
/// **It carries the state and the callback, never the widget.** The control is
/// a look, and a look that arrived through an inherited widget is one two
/// chromes could draw differently without either file saying so.
class SdNavPanelScopeV2 extends InheritedWidget {
  const SdNavPanelScopeV2({
    required this.isExpanded,
    required this.onExpand,
    required this.expandLabel,
    required super.child,
    super.key,
  });

  final bool isExpanded;

  /// Reopens the panel. Only ever called while [isExpanded] is false.
  final VoidCallback onExpand;

  /// The reopen control's tooltip and semantics label, localized by the host.
  final String expandLabel;

  /// The panel beside [context], or null where there is none.
  static SdNavPanelScopeV2? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SdNavPanelScopeV2>();

  @override
  bool updateShouldNotify(SdNavPanelScopeV2 oldWidget) =>
      oldWidget.isExpanded != isExpanded ||
      oldWidget.expandLabel != expandLabel ||
      oldWidget.onExpand != onExpand;
}
