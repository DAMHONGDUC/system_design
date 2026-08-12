import 'package:flutter/material.dart';

import '../../core/sd_spacing_constant.dart';
import '../sd_content_padding_v3/sd_content_padding_v3.dart';
import '../sd_context_v3/sd_context_v3.dart';
import '../sd_elevation_v3/sd_elevation_v3.dart';
import '../sd_icon_v3/sd_icon_v3.dart';
import '../sd_radius_v3/sd_radius_v3.dart';
import '../sd_text_style_v3/sd_text_style_v3.dart';

/// The one figure a screen is actually about, on a filled card.
///
/// **A screen gets at most one.** Four equal tiles say four things are
/// equally important, which on a dashboard is the same as saying none of them
/// is — the hero exists to break that tie. Everything else stays an
/// `SdStatTileV3`.
///
/// The gradient is passed in as [gradient] rather than named here: the
/// package holds no colours, and only the app knows whether its brand ramp
/// or its profit ramp belongs behind this number.
///
/// **[value] is a pre-formatted `String`, and null renders
/// [SdStatTileV3.emptyPlaceholder]** — same contract as the small tile, for
/// the same reason: a zero would claim the seller earned nothing when the
/// truth is the data is not there.
class SdHeroStatV3 extends StatelessWidget {
  const SdHeroStatV3({
    required this.label,
    required this.value,
    required this.gradient,
    required this.foreground,
    this.caption,
    this.icon,
    this.trailing,
    this.onTap,
    super.key,
  });

  /// Rendered when [value] is null. Deliberately the same em dash the small
  /// tile uses — two different "no data" marks on one screen is a puzzle.
  static const String emptyPlaceholder = '—';

  final String label;

  /// Pre-formatted by the app. Null means "not enough data".
  final String? value;

  /// The fill. Two or more stops; the app owns the colours.
  final Gradient gradient;

  /// Text and glyph colour on top of [gradient]. Passed rather than assumed
  /// white — a light gradient needs dark text, and the package cannot know
  /// which it was handed.
  final Color foreground;

  /// A secondary line under the figure — a margin, a comparison.
  final String? caption;

  final IconData? icon;

  /// A badge or chip in the top-right — a trend, a period selector.
  final Widget? trailing;

  final VoidCallback? onTap;

  /// How far the caption and label fade against [foreground]. They are
  /// supporting text on a saturated fill, where full-strength white competes
  /// with the number.
  static const double supportingOpacity = 0.75;

  @override
  Widget build(BuildContext context) {
    final Color supporting = foreground.withValues(alpha: supportingOpacity);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: SdRadiusV3.cardAll,
        boxShadow: SdElevationV3.raised(context),
      ),
      child: ClipRRect(
        borderRadius: SdRadiusV3.cardAll,
        child: Material(
          color: Colors.transparent,
          child: Ink(
            decoration: BoxDecoration(gradient: gradient),
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: SdContentPaddingV3.card,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        if (icon != null) ...<Widget>[
                          SdIconV3(
                            icon!,
                            size: SdIconV3.smallSize,
                            color: supporting,
                          ),
                          SizedBox(width: SdSpacingConstant.w6),
                        ],
                        Expanded(
                          child: Text(
                            label,
                            style: context.textTheme3.labelMedium!.semiBold3
                                .copyWith(color: supporting),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        ?trailing,
                      ],
                    ),
                    SizedBox(height: SdSpacingConstant.h8),
                    Text(
                      value ?? emptyPlaceholder,
                      style: context.textTheme3.headlineMedium!.tabular3
                          .copyWith(color: foreground),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (caption != null) ...<Widget>[
                      SizedBox(height: SdSpacingConstant.h4),
                      Text(
                        caption!,
                        style: context.textTheme3.bodySmall!.copyWith(
                          color: supporting,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
