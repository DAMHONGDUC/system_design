import 'package:flutter/widgets.dart';

/// Marks a subtree as having a floating bar resting at the bottom of the
/// screen — the shell's glass nav pill, or anything else occupying
/// `SdContentPaddingV3.floatingBarInset`.
///
/// Content already clears the bar on its own: every tab screen passes
/// `floatingNav: true` to `SdContentPaddingV3`. This exists for what is drawn
/// *over* every screen instead. `SdSnackBarUtilsV3` renders into the root
/// [Overlay], which sits above the whole app — from down there nothing can
/// tell a bar is present, so a message would land inside the band the bar
/// occupies.
///
/// Wrap the shell's body once. A pushed route sits outside the scope and
/// correctly reads `false`, because it covers the bar anyway.
class SdFloatingBarScopeV3 extends InheritedWidget {
  const SdFloatingBarScopeV3({required super.child, super.key});

  /// Whether a floating bar sits below [context].
  ///
  /// **A bool, not the inset.** The caller is a presenter reading from the
  /// screen's context and passing the answer to an overlay entry that builds
  /// somewhere else entirely; the entry can measure the bar itself through
  /// `SdContentPaddingV3.bottom(floatingNav: …)`, which is the same call a
  /// screen makes for its own last row. One rulebook, no second arithmetic.
  ///
  /// Reads without subscribing: callers fire from a callback, not a build,
  /// and a dependency registered from there would outlive the frame that
  /// asked for it.
  static bool hasBarBelow(BuildContext context) =>
      context.getInheritedWidgetOfExactType<SdFloatingBarScopeV3>() != null;

  /// Nothing to notify: the widget carries no value of its own, only the fact
  /// that it is there.
  @override
  bool updateShouldNotify(SdFloatingBarScopeV3 oldWidget) => false;
}
