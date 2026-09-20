import 'package:flutter/widgets.dart';

/// Which edge the shell's navigation chrome is resting on.
enum SdFloatingBarEdgeV3 {
  /// The phone's floating glass pill, over the bottom of the content.
  bottom,

  /// The tablet's rail, in its own column at the leading edge.
  leading,
}

/// Marks a subtree as having the shell's navigation chrome beside it, and
/// says which edge it is on.
///
/// Content already clears the chrome on its own: a tab screen passes
/// `floatingNav: true` to `SdContentPaddingV3`, and the margin either side of
/// a screen comes from the same class. This exists for the two things that
/// cannot work it out from where they are drawn — an overlay rendered above
/// the whole app, and the padding class itself, which has to know whether the
/// bottom edge is occupied before it reserves room there.
///
/// Wrap the shell's body once. A pushed route sits outside the scope and
/// correctly reads `null`: the chrome is gone, which is a different answer
/// from "the bar is at the bottom" and the reason this carries an edge rather
/// than a bool.
///
/// **It answers presence and edge, and nothing else.** It must never import
/// the padding class: padding is what asks the question, so the answer cannot
/// depend on it. Every caller computes its own distance from the edge it is
/// given.
class SdFloatingBarScopeV3 extends InheritedWidget {
  const SdFloatingBarScopeV3({
    required this.edge,
    required super.child,
    super.key,
  });

  final SdFloatingBarEdgeV3 edge;

  /// Which edge the chrome is on, or null when there is none.
  ///
  /// Reads without subscribing: one caller fires from a callback rather than
  /// a build, and a dependency registered from there would outlive the frame
  /// that asked for it. The readers that *are* in a build are safe because
  /// the edge only ever changes by the shell swapping one chrome widget for
  /// another, which rebuilds the subtree anyway.
  static SdFloatingBarEdgeV3? edgeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<SdFloatingBarScopeV3>()?.edge;

  /// Whether a floating bar sits below [context].
  ///
  /// **Not the same as "there is a chrome".** A rail occupies a side, so
  /// nothing below a screen is covered and nothing has to clear it.
  static bool hasBarBelow(BuildContext context) =>
      edgeOf(context) == SdFloatingBarEdgeV3.bottom;

  @override
  bool updateShouldNotify(SdFloatingBarScopeV3 oldWidget) =>
      oldWidget.edge != edge;
}
