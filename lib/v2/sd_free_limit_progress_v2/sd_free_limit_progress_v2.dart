import 'package:flutter/material.dart';

import '../../core/sd_spacing_constant.dart';
import '../sd_context_v2/sd_context_v2.dart';
import '../sd_pressable_scale_v2/sd_pressable_scale_v2.dart';
import '../sd_text_style_v2/sd_text_style_v2.dart';

/// How much of a capped allowance is spent: one line that says it, and a
/// hairline bar that shows it.
///
/// Both strings arrive already localized — the widget only knows two counts.
class SdFreeLimitProgressV2 extends StatelessWidget {
  const SdFreeLimitProgressV2({
    required this.title,
    required this.countLabel,
    required this.used,
    required this.limit,
    required this.onTap,
    super.key,
  });

  /// Thin on purpose: this is a readout, not the progress of something the
  /// user is waiting on.
  static double get barHeight => SdSpacingConstant.h4;

  /// The headline, already localized.
  final String title;

  /// The counts as one string ("38/40"), already localized. Not a percentage:
  /// "38/40" says how many are left at a glance, where "95%" has to be worked
  /// out.
  final String countLabel;

  final int used;
  final int limit;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool spent = used >= limit;
    final double progress = limit <= 0 ? 1 : (used / limit).clamp(0, 1);
    // Spent, so the bar stops reading as neutral progress and starts reading
    // as a wall. The only colour change in the widget.
    final Color tint = spent
        ? context.colorScheme.error
        : context.colorScheme.primary;

    return SdPressableScaleV2(
      pressedScale: 0.99,
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
                    style: context.textTheme.bodySmall!.muted(context),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: SdSpacingConstant.w8),
                Text(
                  countLabel,
                  style: context.textTheme.bodySmall!.semiBold.copyWith(
                    color: tint,
                  ),
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
                backgroundColor: context.sdTheme.surfaceElevated,
                valueColor: AlwaysStoppedAnimation<Color>(tint),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
