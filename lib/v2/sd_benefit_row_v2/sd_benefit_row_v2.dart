import 'package:flutter/material.dart';

import '../../core/sd_spacing_constant.dart';
import '../../utils/text_ext.dart';
import '../sd_context_v2/sd_context_v2.dart';
import '../sd_icon_v2/sd_icon_v2.dart';
import '../sd_text_style_v2/sd_text_style_v2.dart';

/// How much air a row takes.
///
/// A prop rather than a second widget: the two look the same and differ only
/// in what they can afford (see `WIDGET_RULES.md`, "composition over config
/// flags" — the look is a prop).
enum SdBenefitDensityV2 {
  /// The default. A row that has the screen to itself.
  comfortable,

  /// Tighter gaps and a smaller icon, for a list that has to share a screen
  /// with something else — a paywall whose plans and CTA are pinned below it.
  /// The type scale does not change: a compact list is one that fits, not one
  /// that is harder to read.
  compact,
}

/// One "here is what you get" row: icon, title, and an optional supporting
/// line. Shared by the paywall and the login pitch, which sell different
/// things the same way.
class SdBenefitRowV2 extends StatelessWidget {
  const SdBenefitRowV2({
    required this.icon,
    required this.title,
    this.body,
    this.trailing,
    this.density = SdBenefitDensityV2.comfortable,
    super.key,
  });

  final IconData icon;
  final String title;

  /// How much air the row takes. See [SdBenefitDensityV2].
  final SdBenefitDensityV2 density;

  /// The supporting line. Null collapses the row to a single line — for a
  /// list that has to sit beside something else on one screen, where the
  /// titles already say enough.
  final String? body;

  /// Marker beside the title — a badge saying this one is not included, say.
  /// It sits on the title's line, not the row's centre, so a two-line body
  /// cannot drag it out of alignment with the heading it qualifies.
  final Widget? trailing;

  /// The gap under the row. A one-line row needs less air than a two-line one;
  /// the same gap for both makes a short list look sparse.
  double get _gap => switch ((density, body == null)) {
    (SdBenefitDensityV2.comfortable, true) => SdSpacingConstant.h12,
    (SdBenefitDensityV2.comfortable, false) => SdSpacingConstant.h16,
    (SdBenefitDensityV2.compact, true) => SdSpacingConstant.h8,
    (SdBenefitDensityV2.compact, false) => SdSpacingConstant.h12,
  };

  /// Compact shrinks the icon and the gap beside it. It leaves the text alone
  /// — see [SdBenefitDensityV2.compact].
  double get _iconSize => density == SdBenefitDensityV2.compact
      ? SdSpacingConstant.r20
      : SdSpacingConstant.r24;

  double get _iconGap => density == SdBenefitDensityV2.compact
      ? SdSpacingConstant.w12
      : SdSpacingConstant.w16;

  @override
  Widget build(BuildContext context) {
    final String? body = this.body;

    return Padding(
      padding: EdgeInsets.only(bottom: _gap),
      child: Row(
        // One line centres on its icon; two lines hang from the top, so the icon sits beside the title, not the whole block.
        crossAxisAlignment: body == null
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: <Widget>[
          SdIconV2(
            icon: icon,
            size: _iconSize,
            color: context.colorScheme.primary,
          ),
          SizedBox(width: _iconGap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Text(title, style: context.textTheme.titleMedium!),
                    ),
                    if (trailing != null) ...<Widget>[
                      SizedBox(width: SdSpacingConstant.w8),
                      trailing!,
                    ],
                  ],
                ),
                if (body.isNotNullAndNotEmpty) ...[
                  SizedBox(height: SdSpacingConstant.h4),
                  Text(
                    body!,
                    style: context.textTheme.bodyMedium!.muted(context),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
