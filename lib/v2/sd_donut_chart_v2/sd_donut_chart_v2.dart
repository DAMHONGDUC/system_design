import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/sd_spacing_constant.dart';
import '../sd_color_dot_v2/sd_color_dot_v2.dart';
import '../sd_context_v2/sd_context_v2.dart';
import '../sd_text_style_v2/sd_text_style_v2.dart';

/// One slice: how much, what colour, and the label the legend gives it.
@immutable
class SdDonutSliceV2 {
  const SdDonutSliceV2({
    required this.value,
    required this.color,
    required this.label,
  });

  final double value;
  final Color color;

  /// Already-localized legend text for this slice.
  final String label;
}

/// Donut chart with a wrapping legend beneath it. A donut's slices carry no
/// text, so the legend is not decoration — it is the only thing that names
/// them, and it repeats each slice's colour beside its label so colour is
/// never the sole signal.
///
/// Slices with a zero value are dropped rather than drawn as a hairline.
class SdDonutChartV2 extends StatelessWidget {
  const SdDonutChartV2({required this.slices, super.key});

  final List<SdDonutSliceV2> slices;

  @override
  Widget build(BuildContext context) {
    final List<SdDonutSliceV2> present = slices
        .where((SdDonutSliceV2 s) => s.value > 0)
        .toList();

    return PieChart(
      PieChartData(
        sectionsSpace: SdSpacingConstant.w2,
        centerSpaceRadius: SdSpacingConstant.r44,
        sections: <PieChartSectionData>[
          for (final SdDonutSliceV2 slice in present)
            PieChartSectionData(
              value: slice.value,
              color: slice.color,
              radius: SdSpacingConstant.r28,
              showTitle: false,
            ),
        ],
      ),
    );
  }
}

/// The legend that names a [SdDonutChartV2]'s slices. Kept separate so the
/// chart can sit inside an `SdChartFrameV2` (which hides its child from
/// VoiceOver) while the legend stays readable to it.
class SdDonutLegendV2 extends StatelessWidget {
  const SdDonutLegendV2({required this.slices, super.key});

  final List<SdDonutSliceV2> slices;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: SdSpacingConstant.w16,
      runSpacing: SdSpacingConstant.h8,
      children: <Widget>[
        for (final SdDonutSliceV2 slice in slices)
          if (slice.value > 0)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SdColorDotV2(color: slice.color),
                SizedBox(width: SdSpacingConstant.w6),
                Text(
                  slice.label,
                  style: context.textTheme.bodySmall!.muted(context),
                ),
              ],
            ),
      ],
    );
  }
}
