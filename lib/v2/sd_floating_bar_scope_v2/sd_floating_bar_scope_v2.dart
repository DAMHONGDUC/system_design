import 'package:flutter/material.dart';

import '../sd_content_padding_v2/sd_content_padding_v2.dart';

/// Marks a subtree as having a floating bar resting at the bottom of the
/// screen — the app shell's nav pill, or anything else that shares
/// [SdContentPaddingV2.floatingBarInset].
///
/// Content already clears the bar through
/// `SdContentPaddingV2.bottom(floatingNav: true)`, which each screen passes
/// for itself. This exists for what is drawn *over* every screen instead: a
/// snackbar goes into the root overlay, above the whole app, so it has no way
/// to know a bar is down there and would otherwise land on top of it.
///
/// Wrap the shell's body once. Routes pushed above the shell sit outside it
/// and correctly read zero, because they cover the bar anyway.
class SdFloatingBarScopeV2 extends InheritedWidget {
  const SdFloatingBarScopeV2({required super.child, super.key});

  /// How much of the bottom edge a floating bar occupies below [context], or
  /// 0 where there is none.
  ///
  /// Reads without subscribing: callers are presenters firing from a callback,
  /// not builds, and a dependency registered from there would outlive the
  /// frame that asked for it.
  static double insetOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<SdFloatingBarScopeV2>() == null
      ? 0
      : SdContentPaddingV2.floatingBarInset(context);

  /// Nothing to notify: the widget carries no value of its own, only the fact
  /// that it is there.
  @override
  bool updateShouldNotify(SdFloatingBarScopeV2 oldWidget) => false;
}
