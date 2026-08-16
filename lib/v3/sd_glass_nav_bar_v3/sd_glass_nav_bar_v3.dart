import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

import '../../core/sd_spacing_constant.dart';
import '../sd_content_padding_v3/sd_content_padding_v3.dart';
import '../sd_context_v3/sd_context_v3.dart';
import '../sd_elevation_v3/sd_elevation_v3.dart';
import '../sd_icon_v3/sd_icon_v3.dart';
import '../sd_motion_v3/sd_motion_v3.dart';

/// Whether this device can actually render the glass effect.
///
/// The effect is a fragment-shader image filter, and only Impeller can run
/// one: true on iOS, true on Android devices that get the Vulkan backend,
/// false on Android's Skia fallback and in widget tests. When false the bar
/// renders `FakeGlass` — a flat translucent fill — which keeps the same
/// geometry and legibility without the shader.
///
/// **The idea is borrowed from `SdGlassV2`, not the code.** v3 never imports
/// v2 (hard rule 17); the support check is four lines and copying it is
/// cheaper than the coupling.
abstract final class SdGlassV3 {
  static bool? _debugOverride;

  /// Test seam: the widget-test engine is Skia, so [isSupported] is false
  /// there and every test would exercise the fallback instead of the shipped
  /// look.
  @visibleForTesting
  static set debugSupported(bool? value) => _debugOverride = value;

  static bool get isSupported =>
      _debugOverride ?? ImageFilter.isShaderFilterSupported;
}

/// One destination in [SdGlassNavBarV3].
///
/// A value type rather than a widget so the bar controls every dimension —
/// a destination that brought its own `Icon` would size itself and the row
/// would stop lining up.
@immutable
class SdNavDestinationV3 {
  const SdNavDestinationV3({
    required this.icon,
    required this.label,
    this.selectedIcon,
  });

  final IconData icon;

  /// Shown when this destination is current. Usually the filled variant of
  /// [icon] — weight is a second signal alongside colour, which colour alone
  /// must never be.
  final IconData? selectedIcon;

  /// Always rendered. Five glyphs with no words is a memory test, and
  /// "Analytics" and "More" have no unambiguous icon.
  final String label;
}

/// A floating glass tab bar, in the iOS 26 idiom.
///
/// **The body scrolls behind it**, which is the whole point of the look and
/// the reason it is not a `Scaffold.bottomNavigationBar` in the ordinary
/// sense: it is handed to that slot, but the scaffold sets `extendBody` so
/// content passes underneath and refracts through the glass.
///
/// That makes the bar's geometry *layout*, not decoration — every screen
/// behind it has to clear its footprint. `SdContentPaddingV3.floatingBarInset`
/// is the one place that number lives, and tab screens pass
/// `floatingNav: true` to pick it up. Get this wrong and the last row of
/// every list hides behind the bar.
///
/// Degrades to a flat translucent fill where the shader cannot run — see
/// [SdGlassV3]. The geometry is identical either way, so nothing reflows.
class SdGlassNavBarV3 extends StatelessWidget {
  const SdGlassNavBarV3({
    required this.destinations,
    required this.selectedIndex,
    required this.onSelected,
    super.key,
  });

  final List<SdNavDestinationV3> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final double inset = SdContentPaddingV3.navBarOffset(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        SdContentPaddingV3.floatingBarHorizontal,
        0,
        SdContentPaddingV3.floatingBarHorizontal,
        inset,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            SdContentPaddingV3.floatingBarRadius,
          ),
          // **[SdElevationV3.modal], not [SdElevationV3.raised]** — owner's
          // call that the bar should read as more present. It is the one
          // piece of chrome that floats over every screen and never scrolls
          // away, so it belongs in the same depth band as a sheet rather than
          // sitting at the same height as the cards it passes over.
          boxShadow: SdElevationV3.modal(context),
        ),
        child: LiquidGlass.withOwnLayer(
          // A superellipse, not a circle-cornered rectangle: it is the
          // corner Apple's own chrome uses, and next to a real iOS control a
          // plain rounded rect reads as slightly wrong without being able to
          // say why.
          shape: LiquidRoundedSuperellipse(
            borderRadius: SdContentPaddingV3.floatingBarRadius,
          ),
          settings: _settings(context),
          fake: !SdGlassV3.isSupported,
          glassContainsChild: false,
          child: SizedBox(
            height: SdContentPaddingV3.floatingBarHeight,
            child: Row(
              children: <Widget>[
                for (int i = 0; i < destinations.length; i++)
                  Expanded(
                    child: _NavItem(
                      destination: destinations[i],
                      selected: i == selectedIndex,
                      onTap: () => onSelected(i),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Glass tuned from the app's own palette, so the bar is light over a light
  /// page and dark over a dark one.
  ///
  /// The alpha is the whole trick: too opaque and it is just a card, too
  /// sheer and the labels stop being readable over a busy list. The value
  /// below keeps contrast while still letting content show through.
  LiquidGlassSettings _settings(BuildContext context) {
    final Color base = context.sdTheme3.background;

    return LiquidGlassSettings(
      // Sheer enough that content is visibly moving underneath — at 0.62 the
      // bar read as a frosted white panel rather than as glass. The blur is
      // what keeps the labels legible over a busy list, not the opacity.
      glassColor: base.withValues(alpha: context.isDark3 ? 0.42 : 0.46),
      thickness: 14,
      blur: 14,
      // A visible but not theatrical edge highlight. iOS 26's specular rim is
      // what makes the shape read as glass rather than as a blurred panel.
      lightIntensity: context.isDark3 ? 0.6 : 1.1,
      ambientStrength: 0.3,
      // No rainbow fringing — this bar sits over columns of money, and
      // chromatic aberration on small text is the fastest way to make a
      // number hard to read.
      chromaticAberration: 0,
      saturation: 1.1,
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final SdNavDestinationV3 destination;
  final bool selected;
  final VoidCallback onTap;

  /// How solid the current tab's glyph goes, on the font's `FILL` axis.
  ///
  /// Intrinsic to this item — it is what "selected" *looks like* here, not
  /// configuration about it.
  static double get selectedFill => 1;
  static double get unselectedFill => 0;

  @override
  Widget build(BuildContext context) {
    final Color color = selected
        ? context.colorScheme3.primary
        : context.sdTheme3.textSecondary;

    return Semantics(
      button: true,
      selected: selected,
      label: destination.label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          SdContentPaddingV3.floatingBarRadius,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // **The glyph thickens; nothing appears behind it.** That is how
            // iOS marks the current tab, and it is why there is no indicator
            // pill here — a filled shape behind the icon is Material's idiom
            // and reads as a foreign control sitting inside iOS chrome.
            //
            // `FILL` is a variable-font axis, so this is one glyph morphing
            // rather than two glyphs swapping. Weight is the second signal
            // alongside colour, which colour alone must never be.
            TweenAnimationBuilder<double>(
              duration: SdMotionV3.fast,
              curve: SdMotionV3.standard,
              tween: Tween<double>(
                end: selected ? selectedFill : unselectedFill,
              ),
              builder: (BuildContext context, double fill, Widget? _) =>
                  SdIconV3(
                    selected
                        ? (destination.selectedIcon ?? destination.icon)
                        : destination.icon,
                    size: SdIconV3.defaultSize,
                    color: color,
                    fill: fill,
                  ),
            ),
            SizedBox(height: SdSpacingConstant.h2),
            Text(
              destination.label,
              style: context.textTheme3.labelSmall!.copyWith(
                color: color,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
