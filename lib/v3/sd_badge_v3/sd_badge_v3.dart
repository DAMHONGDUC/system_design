import 'package:flutter/material.dart';

import '../../core/sd_spacing_constant.dart';
import '../sd_context_v3/sd_context_v3.dart';
import '../sd_icon_v3/sd_icon_v3.dart';
import '../sd_radius_v3/sd_radius_v3.dart';
import '../sd_text_style_v3/sd_text_style_v3.dart';

/// The tone a badge carries. The package never learns what a domain state
/// means — the app maps `ItemStatus.stale` to [warning] and hands it over.
enum SdBadgeToneV3 { neutral, success, warning, danger, info }

/// A small status marker: an item's `Listed`, an order's `To Ship`, a
/// listing's `Draft`.
///
/// **The badge always carries a label, and [icon] is additive.** Seller OS
/// draws twelve or so states across items, listings, orders and offers, and a
/// colour-only marker asks the seller to memorise a legend — which is exactly
/// the failure the "colour is never the only signal" rule exists to stop.
/// The tone tints the text and the fill; the word is what says which state it
/// is.
class SdBadgeV3 extends StatelessWidget {
  const SdBadgeV3({
    required this.label,
    this.tone = SdBadgeToneV3.neutral,
    this.icon,
    super.key,
  });

  final String label;
  final SdBadgeToneV3 tone;

  /// An optional leading glyph, for a state worth recognising before it is
  /// read — a failed sync in a long list.
  final IconData? icon;

  /// How much of the tone colour the fill keeps. Low enough that the label
  /// stays the loudest thing in the badge.
  static const double fillOpacity = 0.12;

  @override
  Widget build(BuildContext context) {
    final Color tint = switch (tone) {
      SdBadgeToneV3.neutral => context.sdTheme3.textSecondary,
      SdBadgeToneV3.success => context.sdTheme3.success,
      SdBadgeToneV3.warning => context.sdTheme3.warning,
      SdBadgeToneV3.danger => context.sdTheme3.danger,
      SdBadgeToneV3.info => context.sdTheme3.info,
    };

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: SdSpacingConstant.w8,
        vertical: SdSpacingConstant.h4,
      ),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: fillOpacity),
        borderRadius: SdRadiusV3.chipAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            SdIconV3(icon!, size: SdIconV3.smallSize, color: tint),
            SizedBox(width: SdSpacingConstant.w4),
          ],
          Text(
            label,
            style: context.textTheme3.labelSmall!.semiBold3.copyWith(color: tint),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
