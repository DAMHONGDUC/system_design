import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

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

  /// **Required on every destination, and the semantics label of every
  /// segment.** The bar is intentionally glyph-only, but it is not icon-only
  /// to a screen reader.
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
/// **Five equal segments, one glyph each, and no painted labels** — owner's
/// rule. The current tab is marked by its filled glyph and a tinted thumb that
/// slides inside the bar under its equal-width segment.
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

  /// Test seam. The capsule's whole point is where it is and how wide it is
  /// mid-flight, and both are real layout — a test measures its rect rather
  /// than reading a widget's arguments back.
  @visibleForTesting
  static const Key selectedCapsuleKey = Key('sd-nav-selected-capsule');

  /// The tint inside the one glass surface. Strong enough to read as a
  /// switcher thumb over a light page without becoming a solid button.
  static const double selectedThumbOpacity = 0.22;

  /// Glass tuned from the app's own palette, so the bar is light over a light
  /// page and dark over a dark one.
  static LiquidGlassSettings barSettings(BuildContext context) {
    final Color base = context.sdTheme3.background;
    final bool dark = context.isDark3;

    return LiquidGlassSettings(
      glassColor: base.withValues(alpha: dark ? 0.26 : 0.30),
      thickness: 22,
      refractiveIndex: 1.38,
      blur: 15,
      lightIntensity: dark ? 0.9 : 1.45,
      ambientStrength: 0.4,
      chromaticAberration: 0,
      saturation: 1.15,
    );
  }

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
          boxShadow: SdElevationV3.modal(context),
        ),
        child: LiquidGlass.withOwnLayer(
          shape: LiquidRoundedSuperellipse(
            borderRadius: SdContentPaddingV3.floatingBarRadius,
          ),
          settings: barSettings(context),
          fake: !SdGlassV3.isSupported,
          glassContainsChild: false,
          child: SizedBox(
            height: SdContentPaddingV3.floatingBarHeight,
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                _SelectedCapsule(
                  count: destinations.length,
                  selectedIndex: selectedIndex,
                ),
                Row(
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The tinted thumb that marks the current tab and slides to the next one.
///
/// **Always one segment wide.** This is an icon-only bar: a capsule that
/// widens has no label to make room for and reads as unrelated motion.
class _SelectedCapsule extends StatelessWidget {
  const _SelectedCapsule({required this.count, required this.selectedIndex});

  final int count;
  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    final EdgeInsets inset = SdContentPaddingV3.selectedTabInset;

    return AnimatedAlign(
      duration: SdMotionV3.normal,
      curve: SdMotionV3.emphasized,
      alignment: AlignmentDirectional(
        count == 1 ? 0 : -1 + 2 * selectedIndex / (count - 1),
        0,
      ),
      child: FractionallySizedBox(
        widthFactor: 1 / count,
        heightFactor: 1,
        child: Padding(
          padding: inset,
          child: DecoratedBox(
            key: SdGlassNavBarV3.selectedCapsuleKey,
            decoration: BoxDecoration(
              color: context.colorScheme3.primary.withValues(
                alpha: SdGlassNavBarV3.selectedThumbOpacity,
              ),
              borderRadius: BorderRadius.circular(
                SdContentPaddingV3.selectedTabRadius,
              ),
            ),
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
  }
}

/// One equal-width segment in the glyph-only navigation bar.
class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final SdNavDestinationV3 destination;
  final bool selected;
  final VoidCallback onTap;

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
      container: true,
      label: destination.label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          SdContentPaddingV3.selectedTabRadius,
        ),
        child: Center(
          child: TweenAnimationBuilder<double>(
            duration: SdMotionV3.fast,
            curve: SdMotionV3.standard,
            tween: Tween<double>(end: selected ? selectedFill : unselectedFill),
            builder: (BuildContext context, double fill, Widget? _) => SdIconV3(
              selected
                  ? (destination.selectedIcon ?? destination.icon)
                  : destination.icon,
              size: SdIconV3.defaultSize,
              color: color,
              fill: fill,
            ),
          ),
        ),
      ),
    );
  }
}
