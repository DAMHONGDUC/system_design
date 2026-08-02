import 'package:flutter/material.dart';

import '../../core/sd_spacing_constant.dart';
import '../sd_icon_v2/sd_icon_v2.dart';

/// A circular disc holding one icon — the leading badge on banners, cards and
/// rows. [color] tints the glyph, and the disc behind it at [tintAlpha] unless
/// [background] names its own fill.
class SdIconBadgeV2 extends StatelessWidget {
  const SdIconBadgeV2({
    required this.icon,
    required this.color,
    this.background,
    this.size,
    this.iconSize,
    super.key,
  });

  /// Fallback disc tint: the accent at low alpha, so the glyph still carries
  /// the colour.
  static const double tintAlpha = 0.16;

  final IconData icon;

  /// The glyph colour, and the disc's tint when [background] is null.
  final Color color;

  /// Opaque fill, for a badge that inverts (a dark disc on a bright card)
  /// instead of tinting.
  final Color? background;

  /// Diameter. Defaults to `SdSpacingConstant.r44`.
  final double? size;

  /// Glyph size. Defaults to `SdSpacingConstant.r22`.
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    final double diameter = size ?? SdSpacingConstant.r44;

    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        color: background ?? color.withValues(alpha: tintAlpha),
        shape: BoxShape.circle,
      ),
      child: SdIconV2(
        icon: icon,
        size: iconSize ?? SdSpacingConstant.r22,
        color: color,
      ),
    );
  }
}
