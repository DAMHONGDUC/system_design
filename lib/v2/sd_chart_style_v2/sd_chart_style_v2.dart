import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../sd_context_v2/sd_context_v2.dart';
import '../sd_spacing_v2/sd_spacing_v2.dart';

/// The one place the chart deck's axis, grid and tooltip styling lives, so
/// every chart reads as the same system: recessive grid, muted labels, a
/// tooltip on the elevated surface, and no legend unless the marks need one.
///
/// Everything colour- or text-bearing takes a `BuildContext`: the palette
/// comes from the host app's theme, never from a constant in here.
final class SdChartStyleV2 {
  static const double gridLineWidth = 1;

  /// Standard plot height for a card-sized chart.
  static double get plotHeight => SdSpacingV2.h160;

  static double get leftAxisWidth => SdSpacingV2.w28;
  static double get bottomAxisHeight => SdSpacingV2.h24;
  static double get bottomLabelGap => SdSpacingV2.h6;

  /// Muted, one step below body text — an axis label should never compete
  /// with the marks.
  static TextStyle axisLabel(BuildContext context) =>
      context.textTheme.bodySmall!.copyWith(
        color: context.sdTheme.textSecondary,
        fontSize: SdSpacingV2.sp10,
      );

  /// Tooltips sit *on* a card, so they take the elevated surface.
  static Color tooltipBackground(BuildContext context) =>
      context.sdTheme.surfaceElevated;

  static TextStyle tooltipLabel(BuildContext context) =>
      context.textTheme.bodySmall!.copyWith(color: context.sdTheme.textPrimary);

  /// Horizontal rules only — vertical ones add clutter without adding a read.
  static FlGridData horizontalGrid(BuildContext context, double interval) {
    final Color line = context.sdTheme.chartGrid;

    return FlGridData(
      drawVerticalLine: false,
      horizontalInterval: interval,
      getDrawingHorizontalLine: (double value) =>
          FlLine(color: line, strokeWidth: gridLineWidth),
    );
  }

  /// Left + bottom only; the top and right axes stay off everywhere.
  static FlTitlesData titles({
    required AxisTitles left,
    required AxisTitles bottom,
  }) => FlTitlesData(
    topTitles: const AxisTitles(),
    rightTitles: const AxisTitles(),
    leftTitles: left,
    bottomTitles: bottom,
  );

  /// Whole-number left axis at [interval].
  static AxisTitles countLeftTitles(BuildContext context, double interval) {
    final TextStyle style = axisLabel(context);

    return AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        interval: interval,
        reservedSize: leftAxisWidth,
        getTitlesWidget: (double value, TitleMeta meta) =>
            Text(value.toInt().toString(), style: style),
      ),
    );
  }

  /// Bottom axis labelled per category index. [label] returns null for an
  /// index that should stay blank — out of range, or thinned out so
  /// neighbouring labels don't collide.
  static AxisTitles categoryBottomTitles(
    BuildContext context,
    String? Function(int index) label, {
    double? interval,
  }) {
    final TextStyle style = axisLabel(context);
    final double gap = bottomLabelGap;

    return AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        interval: interval,
        reservedSize: bottomAxisHeight,
        getTitlesWidget: (double value, TitleMeta meta) {
          final String? text = label(value.toInt());

          if (text == null) return const SizedBox.shrink();

          return Padding(
            padding: EdgeInsets.only(top: gap),
            child: Text(text, style: style),
          );
        },
      ),
    );
  }
}
