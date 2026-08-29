import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../core/sd_spacing_constant.dart';
import '../sd_glass_circle_v2/sd_glass_circle_v2.dart';
import '../sd_icon_v2/sd_icon_v2.dart';
import '../sd_pop_scale_v2/sd_pop_scale_v2.dart';

/// What an [SdAppBarButtonV2] sits on — a prop, like `SdButtonVariantV2`.
///
/// - [glassCircle] — its own frosted circle. For a button on the app bar's
///   blurred strip or on a flat opaque panel (a bottom sheet's header):
///   either way there is real background under it to refract.
/// - [none] — the bare glyph, for a button on a surface that is ALREADY
///   Liquid Glass (the paywall's own header): nesting a glass layer inside
///   one has nothing left to catch the light and just reads flat.
enum SdAppBarButtonSurfaceV2 { glassCircle, none }

/// Every icon button in an app bar — the leading back arrow and the trailing
/// actions alike — and the two actions of a sheet header. One class, so the
/// back button on one screen can never end up a different size from the
/// delete button next to it.
///
/// Three things it fixes in place:
/// - a small glyph, [iconSize] (20) rather than Material's 24, so the bar
///   stays quiet next to the title;
/// - a [tapSize] (48) target around it that is entirely invisible — the
///   finger gets the full Material touch area even though the mark it aims
///   at is small (mid-attack, a small target is a cruel one);
/// - a swell on touch ([SdPopScaleV2]) — the icon grows out from under the
///   fingertip and settles back, which a small glyph needs because a
///   press-*in* would simply disappear under the finger.
///
/// Both a tap and a long press make it pop: the feedback rides the raw
/// pointer-down, so it never waits to find out which one it was.
///
/// The button owns its [surface] rather than letting the bar wrap one around
/// it — the swell has to take the circle with it, and a circle applied from
/// outside would sit still while its contents grew.
class SdAppBarButtonV2 extends StatelessWidget {
  const SdAppBarButtonV2({
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.color,
    this.surface = SdAppBarButtonSurfaceV2.glassCircle,
    super.key,
  });

  /// The glyph. Deliberately below [SdIconV2]'s 24 default.
  static double get iconSize => SdSpacingConstant.r20;

  /// The invisible square the touch may land in — Material's minimum, and
  /// the footprint `SdAppBarV2`'s glass circle takes for these.
  static double get tapSize => SdSpacingConstant.r44;

  /// Platform-native back arrow, for whoever needs to spell out a leading
  /// button rather than let `SdAppBarV2` insert one.
  static IconData get backIcon => switch (defaultTargetPlatform) {
    TargetPlatform.iOS || TargetPlatform.macOS => Symbols.arrow_back_ios_new_rounded,
    _ => Symbols.arrow_back_rounded,
  };

  final IconData icon;

  /// Null disables the button — it stops popping too, since nothing happens.
  final VoidCallback? onPressed;

  final String? tooltip;

  /// Falls back to the ambient icon theme, like every other [SdIconV2].
  final Color? color;

  final SdAppBarButtonSurfaceV2 surface;

  @override
  Widget build(BuildContext context) {
    final Widget target = GestureDetector(
      // Opaque so the whole invisible square takes the tap, not just the glyph in its middle.
      behavior: HitTestBehavior.opaque,
      onTap: onPressed,
      child: SizedBox.square(
        dimension: tapSize,
        child: Center(
          child: SdIconV2(icon: icon, size: iconSize, color: color),
        ),
      ),
    );
    // Inside the pop, so the swell carries the surface and glyph together rather than growing inside a static circle.
    final Widget dressed = switch (surface) {
      SdAppBarButtonSurfaceV2.glassCircle => SdGlassCircleV2(child: target),
      SdAppBarButtonSurfaceV2.none => target,
    };

    return Tooltip(
      message: tooltip ?? '',
      excludeFromSemantics: tooltip == null,
      child: onPressed == null ? dressed : SdPopScaleV2(child: dressed),
    );
  }
}
