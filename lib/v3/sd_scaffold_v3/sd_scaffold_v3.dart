import 'package:flutter/material.dart';

import '../sd_content_padding_v3/sd_content_padding_v3.dart';
import '../sd_context_v3/sd_context_v3.dart';
import '../sd_keyboard_dismiss_v3/sd_keyboard_dismiss_v3.dart';

/// The scaffold every v3 screen sits in.
///
/// It exists to do one thing consistently: paint [SdThemeV3.background]
/// behind the page, so a screen never inherits whatever `Scaffold` decided
/// `colorScheme.surface` was. `surface` in v3 is the *card*, one step above
/// the page — a bare `Scaffold` therefore renders the page in the card colour
/// and every card on it disappears.
///
/// **It does wrap its body in [SdKeyboardDismissV3]**, so a tap on anything
/// that is not a control drops focus and closes the keyboard. Wired here
/// rather than per screen because a form that forgot it is a form with no way
/// out but the platform's own gesture.
///
/// **It does not wrap its body in a `SafeArea`.** Insets are
/// `SdContentPaddingV3`'s job, and a scaffold that padded too would double up
/// with every screen that already asked. See that class.
///
/// **It does draw the tablet margin, and it is the only thing that does.**
/// `SdContentPaddingV3.pageMargin` is zero at phone width, so this costs a
/// phone nothing; above it, the margin goes around the whole `Scaffold`
/// rather than around its body, because a header spanning the window over an
/// inset body reads as two screens stacked. The surface behind it is not
/// decoration either — a pushed route has nothing of its own back there, and
/// the strips either side would show whatever the route below left.
class SdScaffoldV3 extends StatelessWidget {
  const SdScaffoldV3({
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.resizeToAvoidBottomInset = true,
    this.extendBody = false,
    this.pageMargin = true,
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

  /// False for the two shell chromes, true for everything else.
  ///
  /// The shell is what the margin is measured *against* — it holds the nav
  /// and hands each screen the column beside it — so a shell that also paid
  /// the margin would pay it twice on every tab screen.
  final bool pageMargin;

  @override
  Widget build(BuildContext context) {
    final Color background = context.sdTheme3.background;
    final double margin = pageMargin
        ? SdContentPaddingV3.pageMargin(context)
        : 0;

    final Widget scaffold = Scaffold(
      backgroundColor: background,
      appBar: appBar,
      body: SdKeyboardDismissV3(child: body),
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      extendBody: extendBody,
    );

    if (margin == 0) return scaffold;

    return ColoredBox(
      color: background,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: margin),
        child: scaffold,
      ),
    );
  }
}
