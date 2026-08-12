import 'package:flutter/material.dart';

import '../sd_context_v3/sd_context_v3.dart';

/// The scaffold every v3 screen sits in.
///
/// It exists to do one thing consistently: paint [SdThemeV3.background]
/// behind the page, so a screen never inherits whatever `Scaffold` decided
/// `colorScheme.surface` was. `surface` in v3 is the *card*, one step above
/// the page — a bare `Scaffold` therefore renders the page in the card colour
/// and every card on it disappears.
///
/// **It does not wrap its body in a `SafeArea`.** Insets are
/// `SdContentPaddingV3`'s job, and a scaffold that padded too would double up
/// with every screen that already asked. See that class.
class SdScaffoldV3 extends StatelessWidget {
  const SdScaffoldV3({
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.resizeToAvoidBottomInset = true,
    this.extendBody = false,
    super.key,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  /// Leave true on any screen with a form — false is for screens whose layout
  /// must not move when the keyboard opens (a scanner viewfinder).
  final bool resizeToAvoidBottomInset;

  /// Runs the body under [bottomNavigationBar] instead of stopping above it.
  ///
  /// **Required whenever that slot holds `SdGlassNavBarV3`**, and pointless
  /// otherwise. The glass bar only reads as glass if there is content moving
  /// behind it; without this the scaffold reserves its height and the bar
  /// refracts a blank strip of page. The screens behind it then owe its
  /// footprint — see `SdContentPaddingV3.floatingBarInset`.
  final bool extendBody;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.sdTheme3.background,
    appBar: appBar,
    body: body,
    bottomNavigationBar: bottomNavigationBar,
    floatingActionButton: floatingActionButton,
    floatingActionButtonLocation: floatingActionButtonLocation,
    resizeToAvoidBottomInset: resizeToAvoidBottomInset,
    extendBody: extendBody,
  );
}
