import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../sd_app_bar_button_v2/sd_app_bar_button_v2.dart';
import '../sd_context_v2/sd_context_v2.dart';
import '../sd_liquid_glass_theme_v2/sd_liquid_glass_theme_v2.dart';

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

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    // Every screen's leading button — explicit or auto-inserted for a
    // pushed route that can pop — is an SdAppBarButtonV2, the same class the
    // trailing actions use, so back and delete can never drift apart.
    // automaticallyImplyLeading: false below stops AppBar from also trying
    // to insert its own default back button on top of this.
    final canPop = ModalRoute.of(context)?.canPop ?? false;
    Widget? resolvedLeading =
        leading ??
        (canPop
            ? SdAppBarButtonV2(
                icon: SdAppBarButtonV2.backIcon,
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                onPressed: () => Navigator.maybePop(context),
              )
            : null);

    if (!SdGlassV2.isSupported) {
      return AppBar(
        title: title,
        actions: actions,
        leading: resolvedLeading,
        automaticallyImplyLeading: false,
        bottom: bottom,
      );
    }

    // Glass per element, but drawn by the button itself (SdAppBarButtonSurfaceV2)
    // so the touch swell carries the circle with it. Composite actions
    // (filter pill, view toggle) bring their own surface either way.
    //
    // Centered, not bare: AppBar forces the leading into a tight
    // `leadingWidth` box (56 by default), which would stretch a full-width
    // child into a wider oval than the naturally sized action circles.
    if (resolvedLeading != null) {
      resolvedLeading = Center(child: resolvedLeading);
    }

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: kChromeGlass.blur,
          sigmaY: kChromeGlass.blur,
        ),
        // Same colour as the app background — no divider, no distinct slab;
        // the translucency lets the blurred content glow through faintly.
        child: ColoredBox(
          color: context.sdTheme.background.withValues(alpha: 0.65),
          child: AppBar(
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
