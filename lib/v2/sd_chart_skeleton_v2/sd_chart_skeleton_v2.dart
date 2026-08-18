import 'package:flutter/material.dart';

import '../../core/sd_spacing_constant.dart';
import '../sd_card_v2/sd_card_v2.dart';
import '../sd_chart_style_v2/sd_chart_style_v2.dart';
import '../sd_skeleton_v2/sd_skeleton_v2.dart';

/// The shape of a chart that has not arrived: a caption line, then the plot.
///
/// **Cardless, like the bodies it stands in for.** A chart body is content,
/// not a card — whoever places it owns the surface, and a skeleton that
/// brought its own would be a card appearing and disappearing around the same
/// chart. [SdChartCardSkeletonV2] is the version for a surface that is a card
/// in both states.
///
/// It reserves [SdChartStyleV2.plotHeight], the height every chart in this
/// generation draws at, so nothing below it reflows when the data lands.
class SdChartSkeletonV2 extends StatelessWidget {
  const SdChartSkeletonV2({this.height, super.key});

  /// How wide the caption line runs. Short of full, because the heading it
  /// stands in for is a few words rather than a paragraph.
  static const double captionFraction = 0.45;

  /// Defaults to [SdChartStyleV2.plotHeight].
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // The heading or hero figure most chart bodies carry above the plot.
        SdSkeletonV2.line(fraction: captionFraction),
        SizedBox(height: SdSkeletonV2.lineGap),
        SdSkeletonV2(height: height ?? SdChartStyleV2.plotHeight),
      ],
    );
  }
}

/// An [SdChartSkeletonV2] on the card its chart will land on.
///
/// For a surface whose loading state is the whole card, so the card does not
/// appear only once the read returns.
class SdChartCardSkeletonV2 extends StatelessWidget {
  const SdChartCardSkeletonV2({this.height, super.key});

  final double? height;

  @override
  Widget build(BuildContext context) {
    return SdCardV2(
      child: Padding(
        padding: EdgeInsets.all(SdSpacingConstant.w16),
        child: SdChartSkeletonV2(height: height),
      ),
    );
  }
}
