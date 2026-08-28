import 'dart:math' as math;
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
/// The current tab is marked twice: its glyph fills in, and a second, brighter
/// pane of glass slides under it — see [_SelectedCapsule].
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

  /// Glass tuned from the app's own palette, so the bar is light over a light
  /// page and dark over a dark one.
  ///
  /// **Sheer and refractive, never frosted.** A high alpha under a heavy blur
  /// is a panel — it says "surface" and the page beneath it stops existing.
  /// Legibility comes from the blur and the specular rim, not from opacity,
  /// which is what lets the fill go this low.
  static LiquidGlassSettings barSettings(BuildContext context) {
    final Color base = context.sdTheme3.background;
    final bool dark = context.isDark3;

    return LiquidGlassSettings(
      glassColor: base.withValues(alpha: dark ? 0.26 : 0.30),
      // A thick pane at a real index of refraction: this is the pair that
      // bends the list underneath, and it is what separates glass from a
      // blurred rectangle.
      thickness: 22,
      refractiveIndex: 1.38,
      blur: 15,
      // iOS 26's specular rim is what draws the shape's edge. Lower in dark
      // mode, where the same rim over a dark page reads as a hot white line.
      lightIntensity: dark ? 0.9 : 1.45,
      ambientStrength: 0.4,
      // No rainbow fringing — this bar sits over columns of money, and
      // chromatic aberration on small text is the fastest way to make a
      // number hard to read. A rule, not a knob.
      chromaticAberration: 0,
      saturation: 1.15,
    );
  }

  /// The current tab's capsule: brighter than the bar and carrying no blur of
  /// its own.
  ///
  /// The bar has already blurred the page, and blurring a blurred backdrop a
  /// second time smears rather than frosts. What is left is refraction and a
  /// stronger rim, which is exactly how the system bar's indicator reads —
  /// a lens on the glass rather than a shape painted on it.
  static LiquidGlassSettings selectedCapsuleSettings(BuildContext context) {
    final bool dark = context.isDark3;

    return LiquidGlassSettings(
      // Literal white, not a palette colour: this is a highlight on glass in
      // both themes, and tinting it would make the mark colour again.
      glassColor: Colors.white.withValues(alpha: dark ? 0.14 : 0.34),
      thickness: 12,
      refractiveIndex: 1.42,
      blur: 0,
      lightIntensity: dark ? 1.3 : 1.7,
      ambientStrength: 0.5,
      chromaticAberration: 0,
      saturation: 1.05,
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
          settings: barSettings(context),
          fake: !SdGlassV3.isSupported,
          glassContainsChild: false,
          child: SizedBox(
            height: SdContentPaddingV3.floatingBarHeight,
            child: Stack(
              // Both children are unpositioned and both must fill the bar:
              // the capsule aligns itself inside the full width, and the row
              // divides it.
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

/// The glass capsule that marks the current tab and travels to the next one.
///
/// **It gets its own [LiquidGlassLayer] and never joins the bar's blend
/// group.** Shapes sharing a blend group are combined with a smooth union, so
/// a capsule lying wholly inside the bar's stadium unions into it and vanishes
/// — the one simplification here that looks free and silently deletes the
/// effect. Its own layer paints after the bar and takes the bar's own output
/// as its backdrop, which is the stacked-lens look the system bar has.
///
/// It slides rather than fading in and out: one shape moving is what says the
/// five destinations are a single row. And it **stretches along the way** —
/// see [_stretch].
class _SelectedCapsule extends StatefulWidget {
  const _SelectedCapsule({required this.count, required this.selectedIndex});

  final int count;
  final int selectedIndex;

  /// How much longer the capsule gets at the midpoint of a full-length
  /// journey, as a fraction of its resting width.
  ///
  /// Intrinsic to this shape's motion — it is what the travel *looks like*,
  /// not configuration about it.
  static double get maxStretch => 0.3;

  /// How much shorter it gets at the same moment. Smaller than [maxStretch]:
  /// the capsule is much wider than it is tall, so an equal squash reads as
  /// the whole mark shrinking rather than as one shape being pulled.
  static double get maxSquash => 0.1;

  /// The jump length, in destinations, at which [maxStretch] is reached.
  /// Beyond it the stretch is capped — a shape that keeps elongating with
  /// distance stops reading as glass and starts reading as a rubber band.
  static double get fullStretchDistance => 2;

  @override
  State<_SelectedCapsule> createState() => _SelectedCapsuleState();
}

class _SelectedCapsuleState extends State<_SelectedCapsule>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: SdMotionV3.normal,
  );

  late double _from = widget.selectedIndex.toDouble();
  late double _to = widget.selectedIndex.toDouble();

  /// Where the capsule is right now, in destination units.
  ///
  /// [SdMotionV3.emphasized], not [SdMotionV3.standard]: the capsule both
  /// leaves one destination and arrives at another in one animation, and a
  /// decelerating-only curve starts that move abruptly.
  double get _index => _from == _to
      ? _to
      : _from +
            (_to - _from) * SdMotionV3.emphasized.transform(_controller.value);

  /// The squash-and-stretch envelope: nothing at either end, everything in
  /// the middle, scaled by how far this jump travels.
  ///
  /// A sine bulge rather than the curve's own derivative — the two peak at
  /// the same moment, and the derivative of an eased curve is a second thing
  /// to keep in step with the first for no visible gain.
  double get _stretch {
    final double distance = (_to - _from).abs();
    final double reach = (distance / _SelectedCapsule.fullStretchDistance)
        .clamp(0.0, 1.0);

    return math.sin(math.pi * _controller.value) * reach;
  }

  @override
  void didUpdateWidget(_SelectedCapsule oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.selectedIndex == oldWidget.selectedIndex) return;

    // Start from where the capsule actually is, not from the tab it was last
    // heading to — tapping mid-flight redirects it rather than teleporting it.
    _from = _index;
    _to = widget.selectedIndex.toDouble();
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final EdgeInsets inset = SdContentPaddingV3.selectedTabInset;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double slot = constraints.maxWidth / widget.count;

        return AnimatedBuilder(
          animation: _controller,
          builder: (BuildContext context, Widget? _) {
            final double stretch = _stretch;
            final double width =
                slot * (1 + stretch * _SelectedCapsule.maxStretch) -
                inset.horizontal;
            final double height =
                constraints.maxHeight *
                    (1 - stretch * _SelectedCapsule.maxSquash) -
                inset.vertical;

            // The size is real layout, never a `Transform`: the shader reads
            // the shape's geometry, so a scaled capsule would refract at its
            // unscaled size.
            return Stack(
              children: <Widget>[
                Positioned(
                  left: slot * (_index + 0.5) - width / 2,
                  top: (constraints.maxHeight - height) / 2,
                  width: width,
                  height: height,
                  child: LiquidGlass.withOwnLayer(
                    key: SdGlassNavBarV3.selectedCapsuleKey,
                    shape: LiquidRoundedSuperellipse(
                      // Capped at half the height so a squashed capsule stays
                      // a stadium instead of asking for a corner it has no
                      // room for.
                      borderRadius: math.min(
                        SdContentPaddingV3.selectedTabRadius,
                        height / 2,
                      ),
                    ),
                    settings: SdGlassNavBarV3.selectedCapsuleSettings(context),
                    fake: !SdGlassV3.isSupported,
                    glassContainsChild: false,
                    child: const SizedBox.expand(),
                  ),
                ),
              ],
            );
          },
        );
      },
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
        // The ink stays inside the capsule's shape rather than the bar's, so
        // a press does not splash across the whole stadium.
        borderRadius: BorderRadius.circular(
          SdContentPaddingV3.selectedTabRadius,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // **The glyph thickens as well as lighting up.** `FILL` is a
            // variable-font axis, so this is one glyph morphing rather than
            // two glyphs swapping — weight is the second signal alongside
            // colour, which colour alone must never be. The capsule behind it
            // is the third, not a replacement for either.
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
