import 'package:flutter/material.dart';

import '../../core/sd_spacing_constant.dart';
import '../sd_icon_v3/sd_icon_v3.dart';
import '../sd_radius_v3/sd_radius_v3.dart';

/// A glyph in a tinted, rounded square.
///
/// The leading element of almost every row and card in the app. It exists
/// because a bare grey icon beside a label is the single flattest thing a UI
/// can put in a list: **the tint is what carries meaning at a glance**, and
/// the container is what gives a row a visual anchor to scan down.
///
/// [tint] is passed in rather than derived from an enum here, so the app maps
/// its own domain states (`stale` → warning, `sync failed` → danger) onto a
/// colour from `SdThemeV3` and this widget stays string- and domain-free.
///
/// **The tint is never the only signal.** Every call site pairs this with a
/// label; the colour speeds recognition up for someone who already knows the
/// list, and says nothing on its own.
class SdIconTileV3 extends StatelessWidget {
  const SdIconTileV3({
    required this.icon,
    required this.tint,
    this.size = SdIconTileSizeV3.medium,
    this.filled = false,
    super.key,
  });

  final IconData icon;

  /// The accent. Used at [backgroundOpacity] behind the glyph, and at full
  /// strength for the glyph itself — or inverted when [filled].
  final Color tint;

  final SdIconTileSizeV3 size;

  /// Solid [tint] behind an on-tint glyph, for the one element on a card that
  /// should be loudest. Off by default: a list where every row is filled is a
  /// list with no hierarchy at all.
  final bool filled;

  /// How much of [tint] the container keeps when not [filled]. Low enough
  /// that the glyph stays the thing being read.
  static const double backgroundOpacity = 0.12;

  @override
  Widget build(BuildContext context) => Container(
    width: size.box,
    height: size.box,
    decoration: BoxDecoration(
      color: filled ? tint : tint.withValues(alpha: backgroundOpacity),
      borderRadius: BorderRadius.circular(size.radius),
    ),
    alignment: Alignment.center,
    child: SdIconV3(
      icon,
      size: size.glyph,
      // A filled tile carries a light glyph. White rather than a theme slot:
      // the tint is arbitrary and only the app knows what reads on it, but
      // every accent in this system is dark enough for white to be the safe
      // answer.
      color: filled ? const Color(0xFFFFFFFF) : tint,
    ),
  );
}

/// How big an [SdIconTileV3] is. The three sizes correspond to the three
/// places one appears: inside a dense row, leading a list row, and heading a
/// card.
enum SdIconTileSizeV3 {
  small,
  medium,
  large;

  double get box => switch (this) {
    SdIconTileSizeV3.small => SdSpacingConstant.r28,
    SdIconTileSizeV3.medium => SdSpacingConstant.r36,
    SdIconTileSizeV3.large => SdSpacingConstant.r44,
  };

  double get glyph => switch (this) {
    SdIconTileSizeV3.small => SdIconV3.smallSize,
    SdIconTileSizeV3.medium => SdIconV3.defaultSize,
    SdIconTileSizeV3.large => SdIconV3.largeSize,
  };

  /// A rounded square, not a circle — a circle reads as an avatar, and these
  /// sit next to real avatars on the Team screen.
  double get radius => switch (this) {
    SdIconTileSizeV3.small => SdRadiusV3.chip,
    SdIconTileSizeV3.medium => SdRadiusV3.input,
    SdIconTileSizeV3.large => SdRadiusV3.input,
  };
}
