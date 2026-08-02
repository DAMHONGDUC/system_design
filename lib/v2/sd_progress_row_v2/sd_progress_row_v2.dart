import 'package:flutter/material.dart';

import '../../core/sd_spacing_constant.dart';
import '../sd_context_v2/sd_context_v2.dart';
import '../sd_text_style_v2/sd_text_style_v2.dart';

/// A labelled proportional track: name on the left, a bar filled to
/// [fraction] in the middle, its value on the right.
///
/// Stacked, these read as a horizontal bar chart — cleaner and lighter than
/// rotating a real one when the categories are few and each needs a name.
class SdProgressRowV2 extends StatelessWidget {
  const SdProgressRowV2({
    required this.label,
    required this.value,
    required this.fraction,
    this.color,
    super.key,
  });

  /// Width of the leading label column, so stacked rows align their tracks.
  static double get labelWidth => SdSpacingConstant.w56 + SdSpacingConstant.w28;

  /// Width of the trailing value column.
  static double get valueWidth => SdSpacingConstant.w28;

  static double get trackHeight => SdSpacingConstant.h16;

  /// Already-localized category name.
  final String label;

  /// Already-formatted value shown at the end of the row.
  final String value;

  /// 0–1; clamped, so a caller that over-counts cannot overflow the track.
  final double fraction;

  /// Fill colour. Defaults to the theme's primary.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final Color fill = color ?? context.colorScheme.primary;

    return Row(
      children: <Widget>[
        SizedBox(
          width: labelWidth,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.bodySmall,
          ),
        ),
        SizedBox(width: SdSpacingConstant.w8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(SdSpacingConstant.r4),
            child: Stack(
              children: <Widget>[
                Container(
                  height: trackHeight,
                  color: context.sdTheme.chartGrid,
                ),
                FractionallySizedBox(
                  widthFactor: fraction.clamp(0, 1),
                  child: Container(
                    height: trackHeight,
                    decoration: BoxDecoration(
                      color: fill,
                      borderRadius: BorderRadius.circular(SdSpacingConstant.r4),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: SdSpacingConstant.w8),
        SizedBox(
          width: valueWidth,
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: context.textTheme.bodySmall!.muted(context),
          ),
        ),
      ],
    );
  }
}
