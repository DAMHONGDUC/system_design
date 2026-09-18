import 'package:flutter/material.dart';

import '../sd_app_bar_v2/sd_app_bar_v2.dart';
import '../sd_content_padding_v2/sd_content_padding_v2.dart';
import '../sd_liquid_glass_theme_v2/sd_liquid_glass_theme_v2.dart';

/// The app's standard screen scaffold. Every top-level screen uses this
/// instead of a bare [Scaffold] so the frosted [SdAppBarV2] and the
/// behind-the-bar layout are wired in one place.
///
/// When [SdGlassV2.isSupported] is true it sets `extendBodyBehindAppBar` so the
/// body refracts through the glass.
///
/// It deliberately adds NO padding of its own — no SafeArea, no insets. Every
/// screen pads its own scrollable through `SdContentPaddingV2`, so the device
/// insets are computed in exactly one place and can never be applied twice
/// (a scaffold-level SafeArea plus a body that also clears a floating bar is
/// how that used to happen).
class SdScaffoldV2 extends StatelessWidget {
  const SdScaffoldV2({
    required this.title,
    required this.body,
    this.actions,
    this.leading,
    this.appBarBottom,
    this.floatingActionButton,
    this.bottomNavigationBar,
    super.key,
  });

  final Widget title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? leading;
  final PreferredSizeWidget? appBarBottom;
  final Widget? floatingActionButton;

  /// A bottom bar (e.g. the log flow's floating step progress). When set and
  /// glass is on, the body extends behind it so it refracts through the glass;
  /// pad the body's bottom by `SdContentPaddingV2.bottomBar` so its last item
  /// clears it.
  final Widget? bottomNavigationBar;

  @override
  Widget build(BuildContext context) {
    // The margin goes around the whole Scaffold, not just the body: the app
    // bar is part of the screen, and a title spanning the window over an inset
    // body reads as two screens stacked.
    //
    // It is a margin and not a centred ceiling because every gap on a tablet
    // is one number — see `SdContentPaddingV2.tabletMargin`. Zero on a phone,
    // so this is the same single Scaffold there.
    //
    // It lives HERE rather than in the shell because the detail screens are
    // siblings of the shell route, not children of it: a pushed attack or
    // medication gets no rail, and would otherwise be the one screen in the
    // app running edge to edge.
    //
    // The `ColoredBox` is what the margin is painted with. A pushed route has
    // no surface of its own behind it, so without this the two strips either
    // side of a detail screen would show whatever the route below happened to
    // leave — on a fresh push, black.
    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: SdContentPaddingV2.pageMargin(context),
        ),
        child: _scaffold(context),
      ),
    );
  }

  Widget _scaffold(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: SdGlassV2.isSupported,
      // Let the body flow behind a floating glass bottom bar so it refracts through it (mirrors the shell's bottom nav).
      extendBody: SdGlassV2.isSupported && bottomNavigationBar != null,
      appBar: SdAppBarV2(
        title: title,
        actions: actions,
        leading: leading,
        bottom: appBarBottom,
      ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      // - tap anywhere outside a focused field drops focus and dismisses the keyboard
      // - translucent so it never eats taps meant for buttons/list rows; only reached when nothing nearer claims it
      // - a scroll drag defeats the tap, so scrolling is unaffected
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        behavior: HitTestBehavior.translucent,
        child: body,
      ),
    );
  }
}
