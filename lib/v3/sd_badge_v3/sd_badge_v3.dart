import 'package:flutter/material.dart';

import '../../core/sd_spacing_constant.dart';
import '../sd_context_v3/sd_context_v3.dart';
import '../sd_icon_v3/sd_icon_v3.dart';
import '../sd_radius_v3/sd_radius_v3.dart';
import '../sd_text_style_v3/sd_text_style_v3.dart';

/// The tone a badge carries. The package never learns what a domain state
/// means — the app maps `ItemStatus.stale` to [warning] and hands it over.
enum SdBadgeToneV3 { neutral, success, warning, danger, info }

/// How much room a badge takes around its label.
///
/// **[compact] is the presentation for read-only metadata on a card** — a list
/// row carries three or four of these beside a photo, a title and a price, so
/// the padding is what has to give. It scales the inset, the glyph and the gap
/// together, exactly as `SdButtonSizeV3` does: the same shape smaller, never
/// differently proportioned. The label keeps its size, because the word is the
/// signal and shrinking it is what makes a dense row unreadable.
enum SdBadgeSizeV3 {
  regular,
  compact;

  double get scale => switch (this) {
    SdBadgeSizeV3.regular => 1,
    SdBadgeSizeV3.compact => 0.75,
  };
}

/// A small status marker: an item's `Listed`, an order's `To Ship`, a
/// listing's `Draft`.
///
/// **The badge always carries a label, and [icon] is additive.** Reseller Studio
/// draws twelve or so states across items, listings, orders and offers, and a
/// colour-only marker asks the seller to memorise a legend — which is exactly
/// the failure the "colour is never the only signal" rule exists to stop.
/// The tone tints the text and the fill; the word is what says which state it
/// is.
class SdBadgeV3 extends StatelessWidget {
  const SdBadgeV3({
    required this.label,
    this.tone = SdBadgeToneV3.neutral,
    this.color,
    this.icon,
    this.size = SdBadgeSizeV3.regular,
    super.key,
  });

  final String label;
  final SdBadgeToneV3 tone;

  /// An exact colour, overriding [tone].
  ///
  /// **For a set the five tones cannot tell apart** — an app with seven
  /// condition grades needs seven hues, and the same value shown as a badge
  /// here and as an `SdTagV3` there has to come out the same colour. The app
  /// maps its enum to one colour and hands it to both; the package still
  /// learns nothing about what the value means.
  final Color? color;

  /// An optional leading glyph, for a state worth recognising before it is
  /// read — a failed sync in a long list.
  final IconData? icon;

  /// How tightly the badge is padded. See [SdBadgeSizeV3].
  final SdBadgeSizeV3 size;

  /// How much of the tone colour the fill keeps. Low enough that the label
  /// stays the loudest thing in the badge.
  static const double fillOpacity = 0.12;

  @override
  Widget build(BuildContext context) {
    final double scale = size.scale;
    final Color tint =
        color ??
        switch (tone) {
          SdBadgeToneV3.neutral => context.sdTheme3.textSecondary,
          SdBadgeToneV3.success => context.sdTheme3.success,
          SdBadgeToneV3.warning => context.sdTheme3.warning,
          SdBadgeToneV3.danger => context.sdTheme3.danger,
          SdBadgeToneV3.info => context.sdTheme3.info,
        };

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: SdSpacingConstant.w8 * scale,
        vertical: SdSpacingConstant.h4 * scale,
      ),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: fillOpacity),
        borderRadius: SdRadiusV3.chipAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            SdIconV3(icon!, size: SdIconV3.smallSize * scale, color: tint),
            SizedBox(width: SdSpacingConstant.w4 * scale),
          ],
          Text(
            label,
            style: context.textTheme3.labelSmall!.semiBold3.copyWith(
              color: tint,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
