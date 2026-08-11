import 'package:flutter/material.dart';

import '../../core/sd_spacing_constant.dart';
import '../sd_card_v3/sd_card_v3.dart';
import '../sd_context_v3/sd_context_v3.dart';
import '../sd_icon_v3/sd_icon_v3.dart';
import '../sd_text_style_v3/sd_text_style_v3.dart';

/// How a [SdStatTileV3]'s value should be read. The app decides which one a
/// number deserves — the package never learns that revenue is money.
///
/// - [neutral] — a count: orders, units, items.
/// - [profit] — money earned, or a positive delta.
/// - [loss] — money lost, or a negative delta.
enum SdStatToneV3 { neutral, profit, loss }

/// One figure with its label — Home's Revenue / Profit / Orders / Inventory,
/// and every headline number on the Analytics screens.
///
/// **[value] is a `String`, and that is deliberate.** Formatting money means
/// knowing the workspace's currency, its locale and its decimal rules, all of
/// which live in the app; a package that took a `double` would have to learn
/// them, and every tile would render in whatever locale the package guessed.
/// The app formats, the tile lays out.
///
/// **A null [value] renders [emptyPlaceholder], not `0`.** The master plan is
/// explicit that missing pricing data shows `Profit: —` rather than a number,
/// because a zero is a claim: it tells a seller they made nothing, when the
/// truth is that nobody has entered the cost yet.
class SdStatTileV3 extends StatelessWidget {
  const SdStatTileV3({
    required this.label,
    required this.value,
    this.tone = SdStatToneV3.neutral,
    this.caption,
    this.icon,
    this.onTap,
    super.key,
  });

  /// What is shown when [value] is null — the em dash the plan asks for.
  static const String emptyPlaceholder = '—';

  final String label;

  /// Pre-formatted by the app. Null means "not enough data", and renders as
  /// [emptyPlaceholder].
  final String? value;

  final SdStatToneV3 tone;

  /// A secondary line under the figure — "vs last week", "12 items".
  final String? caption;

  final IconData? icon;

  /// Makes the tile a tap target: Home's tiles push a detail screen.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool hasValue = value != null;

    final Color valueColor = switch (tone) {
      SdStatToneV3.neutral => context.sdTheme3.textPrimary,
      SdStatToneV3.profit => context.sdTheme3.profit,
      SdStatToneV3.loss => context.sdTheme3.loss,
    };

    return SdCardV3(
      onTap: onTap,
      semanticLabel: '$label: ${value ?? emptyPlaceholder}',
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
                  color: context.sdTheme3.textSecondary,
                ),
                SizedBox(width: SdSpacingConstant.w6),
              ],
              Expanded(
                child: Text(
                  label,
                  style: context.textTheme3.labelMedium!.muted3(context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: SdSpacingConstant.h8),
          Text(
            value ?? emptyPlaceholder,
            style: context.textTheme3.headlineSmall!.bold3.tabular3.copyWith(
              // An em dash is not a figure — tinting it profit-green would
              // say the seller earned something.
              color: hasValue ? valueColor : context.sdTheme3.textTertiary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (caption != null) ...<Widget>[
            SizedBox(height: SdSpacingConstant.h4),
            Text(
              caption!,
              style: context.textTheme3.bodySmall!.faint3(context),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
