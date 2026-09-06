import 'package:flutter/material.dart';

import '../../core/sd_spacing_constant.dart';
import '../sd_context_v3/sd_context_v3.dart';
import '../sd_text_style_v3/sd_text_style_v3.dart';

/// How much of a capped allowance is spent: one line that says it, and a
/// hairline bar that shows it.
///
/// **Only ever drawn for an allowance that has a ceiling.** A plan with no
/// limit has nothing to fill, and a full-looking bar labelled "unlimited" is
/// the opposite of what it would mean — the caller decides, because the
/// package never learns what a plan is.
///
/// Both strings arrive already localized; the widget only knows two counts.
class SdFreeLimitProgressV3 extends StatelessWidget {
  const SdFreeLimitProgressV3({
    required this.title,
    required this.countLabel,
    required this.used,
    required this.limit,
    this.onTap,
    super.key,
  });

  /// Thin on purpose: this is a readout, not the progress of something the
  /// seller is waiting on.
  static double get barHeight => SdSpacingConstant.h4;

  /// The headline, already localized.
  final String title;

  /// The counts as one string ("1/1"), already localized. Not a percentage:
  /// "1/1" says how many are left at a glance, where "100%" has to be worked
  /// out.
  final String countLabel;

  final int used;

  /// The ceiling. Zero or less is treated as spent rather than divided by.
  final int limit;

  /// Where the meter leads — the paywall, normally. Null leaves it a readout.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool spent = used >= limit;
    final double progress = limit <= 0 ? 1 : (used / limit).clamp(0, 1);
    // Spent, so the bar stops reading as neutral progress and starts reading
    // as a wall. The only colour change in the widget, and the count label
    // says the same thing in words.
    final Color tint = spent
        ? context.sdTheme3.danger
        : context.colorScheme3.primary;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: SdSpacingConstant.h4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    title,
                    style: context.textTheme3.bodySmall!.muted3(context),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: SdSpacingConstant.w8),
                Text(
                  countLabel,
                  style: context.textTheme3.bodySmall!.semiBold3.tabular3
                      .copyWith(color: tint),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            SizedBox(height: SdSpacingConstant.h6),
            ClipRRect(
              borderRadius: BorderRadius.circular(barHeight / 2),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: barHeight,
                backgroundColor: context.sdTheme3.surfaceSunken,
                valueColor: AlwaysStoppedAnimation<Color>(tint),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
