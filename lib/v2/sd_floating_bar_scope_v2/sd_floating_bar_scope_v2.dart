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
/// every screen under `SdNavigationRailV2`, where the shell's nav is down the
/// left-hand side and the bottom edge is free.
///
/// **It answers presence, not a distance.** The one number a bar occupies
/// lives in `SdContentPaddingV2`, and this file deliberately imports nothing
/// from there: content padding is what asks the question, so the answer
/// cannot be allowed to depend on it.
class SdFloatingBarScopeV2 extends InheritedWidget {
  const SdFloatingBarScopeV2({required super.child, super.key});

  /// Whether a floating bar rests on the bottom edge below [context].
  ///
  /// Reads without subscribing. One caller is a presenter firing from a
  /// callback, where a dependency would outlive the frame that asked for it;
  /// the other is a layout read, and presence only ever changes when the shell
  /// swaps the pill for a rail, which rebuilds this whole subtree anyway.
  static bool isBelow(BuildContext context) =>
      context.getInheritedWidgetOfExactType<SdFloatingBarScopeV2>() != null;

  /// Nothing to notify: the widget carries no value of its own, only the fact
  /// that it is there.
  @override
  bool updateShouldNotify(SdFloatingBarScopeV2 oldWidget) => false;
}
