import 'package:flutter/widgets.dart';

/// What the tablet sidebar publishes to the screen beside it.
///
/// The sidebar can be collapsed to nothing, and something on screen has to be
/// able to bring it back. That control used to be a strip the sidebar drew
/// above the content — a row of chrome that pushed every screen down and
/// belonged to no screen. Now the sidebar only says *that* it is collapsed and
/// *how* to reopen it, and whichever chrome the screen is already wearing
/// hosts the control: see [SdNavPanelToggleV3.collapsedOf].
///
/// Wrap the sidebar's content column once. A route pushed on the root
/// navigator sits outside the scope and reads null, which is correct — there
/// is no sidebar beside it to reopen.
///
/// **It carries the state and the callback, and never the widget.** The
/// control is a look, and a look that arrived through an inherited widget is
/// one two chromes could draw differently without either file saying so.
class SdNavPanelScopeV3 extends InheritedWidget {
  const SdNavPanelScopeV3({
    required this.isExpanded,
    required this.onExpand,
    required this.expandLabel,
    required super.child,
    super.key,
  });

  final bool isExpanded;

  /// Reopens the sidebar. Only ever called while [isExpanded] is false.
  final VoidCallback onExpand;

  final String expandLabel;

  /// The sidebar beside [context], or null when there is none.
  static SdNavPanelScopeV3? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SdNavPanelScopeV3>();

  @override
  bool updateShouldNotify(SdNavPanelScopeV3 oldWidget) =>
      oldWidget.isExpanded != isExpanded ||
      oldWidget.expandLabel != expandLabel ||
      oldWidget.onExpand != onExpand;
}
