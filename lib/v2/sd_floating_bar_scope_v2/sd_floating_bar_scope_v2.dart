import 'package:flutter/material.dart';

/// Marks a subtree as having a floating bar resting at the bottom of the
/// screen — the app shell's nav pill, or anything else that shares
/// `SdContentPaddingV2.floatingBarInset`.
///
/// Content already clears the bar through
/// `SdContentPaddingV2.bottom(floatingNav: true)`, which each screen passes
/// for itself. This exists for what is drawn *over* every screen instead: a
/// snackbar goes into the root overlay, above the whole app, so it has no way
/// to know a bar is down there and would otherwise land on top of it.
///
/// Wrap the shell's body once. Routes pushed above the shell sit outside it
/// and correctly read false, because they cover the bar anyway — and so does
/// every screen under `SdNavPanelV2`, where the shell's nav is down the
/// left-hand side and the bottom edge is free.
///
/// **It answers presence, not a distance.** The one number a bar occupies
/// lives in `SdContentPaddingV2`, and this file deliberately imports nothing
/// from there: content padding is what asks the question, so the answer
/// cannot be allowed to depend on it.
enum SdFloatingBarEdgeV2 {
  /// `SdBottomNavigationV2` — the pill across the bottom of a phone.
  bottom,

  /// `SdNavPanelV2` — the panel down the leading edge of a tablet, open or
  /// collapsed: either way nothing rests on the bottom edge.
  leading,
}

class SdFloatingBarScopeV2 extends InheritedWidget {
  const SdFloatingBarScopeV2({
    required super.child,
    this.edge = SdFloatingBarEdgeV2.bottom,
    super.key,
  });

  /// Which edge the shell's navigation is on.
  final SdFloatingBarEdgeV2 edge;

  /// Which edge the shell's navigation is on below [context], or null where
  /// there is no shell navigation at all — a route pushed above the shell,
  /// which every detail screen in this app is.
  ///
  /// Reads without subscribing. One caller is a presenter firing from a
  /// callback, where a dependency would outlive the frame that asked for it;
  /// the others are layout reads, and the answer only ever changes when the
  /// shell swaps one chrome for the other, which rebuilds this whole subtree
  /// anyway.
  static SdFloatingBarEdgeV2? edgeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<SdFloatingBarScopeV2>()?.edge;

  /// Whether a floating bar rests on the bottom edge below [context].
  static bool isBelow(BuildContext context) =>
      edgeOf(context) == SdFloatingBarEdgeV2.bottom;

  @override
  bool updateShouldNotify(SdFloatingBarScopeV2 oldWidget) =>
      oldWidget.edge != edge;
}
