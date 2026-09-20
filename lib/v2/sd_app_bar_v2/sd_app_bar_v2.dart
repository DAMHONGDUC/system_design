import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../../core/sd_spacing_constant.dart';
import '../sd_app_bar_button_v2/sd_app_bar_button_v2.dart';
import '../sd_context_v2/sd_context_v2.dart';
import '../sd_liquid_glass_theme_v2/sd_liquid_glass_theme_v2.dart';
import '../sd_nav_panel_toggle_v2/sd_nav_panel_toggle_v2.dart';

/// The app's single [AppBar]. Every screen gets it via [SdScaffoldV2] rather
/// than constructing an [AppBar] directly.
///
/// Chrome style: the bar itself is NOT a glass slab — its strip is the app
/// background colour (translucent) over a backdrop blur, so there is no
/// visible edge/divider and content scrolling behind it (via
/// `extendBodyBehindAppBar`) simply blurs out. The Liquid Glass treatment
/// is applied per element instead: the leading/back button and icon actions
/// each sit in their own glass circle. Scroll-under bodies pad their top by
/// `SdContentPaddingV2.top` so their first item starts below the bar — this
/// widget holds no spacing logic of its own, the one spacing class does.
///
/// **A collapsed `SdNavPanelV2` puts its reopen control in [leading].** Every
/// chrome with a leading slot asks `SdNavPanelToggleV2.collapsedOf` and no
/// screen does, so no screen can be the one that forgets it. A back arrow
/// outranks it — a route with something to pop is a route the panel is not
/// beside — and a screen passing its own [leading] keeps it, because it has a
/// reason to own that slot.
class SdAppBarV2 extends StatelessWidget implements PreferredSizeWidget {
  const SdAppBarV2({
    required this.title,
    this.actions,
    this.leading,
    this.bottom,
    super.key,
  });

  final Widget title;
  final List<Widget>? actions;
  final Widget? leading;
  final PreferredSizeWidget? bottom;

  /// `kToolbarHeight`'s 56, taken through the spacing scale rather than as the
  /// framework's raw constant.
  ///
  /// **A raw 56 is the one number on the screen that would not grow with the
  /// rest.** At `SdScreenScale.maxScale` its leading button is 55 and its title
  /// 27, which is a bar full to the edges on a tablet and an overflow at the
  /// next raise. `SdContentPaddingV2.appBarInset` and the nav panel's own header
  /// read this, so the three cannot drift.
  static double get toolbarHeight => SdSpacingConstant.h56;

  @override
  Size get preferredSize =>
      Size.fromHeight(toolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    // - every leading button (explicit or auto-inserted for a route that can pop) is an SdAppBarButtonV2, so back and delete can't drift apart
    // - automaticallyImplyLeading: false stops AppBar inserting its own default back button on top
    final canPop = ModalRoute.of(context)?.canPop ?? false;
    Widget? resolvedLeading =
        leading ??
        (canPop
            ? SdAppBarButtonV2(
                icon: SdAppBarButtonV2.backIcon,
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                onPressed: () => Navigator.maybePop(context),
              )
            // The reopen control of a collapsed nav panel, or null when there is no panel beside this screen or it is already open.
            : SdNavPanelToggleV2.collapsedOf(context));

    if (!SdGlassV2.isSupported) {
      return AppBar(
        title: title,
        actions: actions,
        leading: resolvedLeading,
        automaticallyImplyLeading: false,
        bottom: bottom,
        toolbarHeight: toolbarHeight,
      );
    }

    // - glass per element, drawn by the button itself (SdAppBarButtonSurfaceV2) so the touch swell carries the circle
    // - composite actions (filter pill, view toggle) bring their own surface either way

    // Centered, not bare: AppBar's tight `leadingWidth` box (56 default) would stretch a full-width child into a wider oval than the action circles.
    if (resolvedLeading != null) {
      resolvedLeading = Center(child: resolvedLeading);
    }

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: kChromeGlass.blur,
          sigmaY: kChromeGlass.blur,
        ),
        // Same colour as the app background — no divider, no distinct slab; translucency lets content glow through.
        child: ColoredBox(
          color: context.sdTheme.background.withValues(alpha: 0.65),
          child: AppBar(
            toolbarHeight: toolbarHeight,
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            surfaceTintColor: Colors.transparent,
            title: title,
            leading: resolvedLeading,
            automaticallyImplyLeading: false,
            actions: actions,
            bottom: bottom,
          ),
        ),
      ),
    );
  }
}
