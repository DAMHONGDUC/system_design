import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/sd_spacing_constant.dart';
import '../sd_chart_style_v2/sd_chart_style_v2.dart';

/// One bar: its height and the axis label under it. A null [label] leaves
/// that tick blank — how a series thins out labels that would collide.
@immutable
class SdBarV2 {
  const SdBarV2({required this.value, this.label});

  final double value;
  final String? label;
}

/// Single-series bar chart in the system's chart language: thin rounded bars,
/// recessive horizontal grid, muted labels, touch tooltip, no legend (the
/// frame's title names the one series).
///
/// Pass it as the child of an `SdChartFrameV2` — this widget draws the plot
/// and nothing else.
class SdBarChartV2 extends StatelessWidget {
  const SdBarChartV2({
    required this.bars,
    required this.color,
    required this.tooltip,
    this.barWidth,
    super.key,
  });

  /// Headroom above the tallest bar, so the top bar never touches the ceiling.
  static const double headroom = 0.5;

  /// Ticks on the value axis when the data is short enough to count.
  static const int targetTicks = 4;

  final List<SdBarV2> bars;

  /// The series colour.
  final Color color;

  /// Already-localized tooltip for a bar's value.
  final String Function(num value) tooltip;

  /// Bar thickness. Defaults to `SdSpacingConstant.w14`.
  final double? barWidth;

  @override
  Widget build(BuildContext context) {
    final double maxValue = bars.fold(
      0,
      (double m, SdBarV2 b) => max(m, b.value),
    );
    final double interval = maxValue <= targetTicks
        ? 1
        : (maxValue / targetTicks).ceilToDouble();
    final double width = barWidth ?? SdSpacingConstant.w14;
    final TextStyle tooltipStyle = SdChartStyleV2.tooltipLabel(context);
    final Color tooltipBackground = SdChartStyleV2.tooltipBackground(context);

    return BarChart(
      BarChartData(
        maxY: max(maxValue, 1) + headroom,
        alignment: BarChartAlignment.spaceAround,
        gridData: SdChartStyleV2.horizontalGrid(context, interval),
        borderData: FlBorderData(show: false),
        titlesData: SdChartStyleV2.titles(
          left: SdChartStyleV2.countLeftTitles(context, interval),
          bottom: SdChartStyleV2.categoryBottomTitles(
            context,
            (int index) => index < 0 || index >= bars.length
                ? null
                : bars[index].label,
          ),
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => tooltipBackground,
            getTooltipItem: (_, _, BarChartRodData rod, _) =>
                BarTooltipItem(tooltip(rod.toY), tooltipStyle),
          ),
        ),
        barGroups: <BarChartGroupData>[
          for (final (int index, SdBarV2 bar) in bars.indexed)
            BarChartGroupData(
              x: index,
              barRods: <BarChartRodData>[
                BarChartRodData(
                  toY: bar.value,
                  width: width,
                  color: color,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(SdSpacingConstant.r4),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
