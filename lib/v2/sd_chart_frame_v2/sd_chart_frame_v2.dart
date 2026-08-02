import 'package:flutter/material.dart';

import '../../core/sd_spacing_constant.dart';
import '../sd_context_v2/sd_context_v2.dart';

/// Title above one chart, and the chart itself hidden from VoiceOver behind a
/// summary — marks are unreadable to a screen reader, so [semanticsLabel]
/// says what they add up to instead.
class SdChartFrameV2 extends StatelessWidget {
  const SdChartFrameV2({
    required this.title,
    required this.semanticsLabel,
    required this.child,
    this.height,
    super.key,
  });

  final String title;

  /// What the chart says, for VoiceOver. The marks themselves are excluded.
  final String semanticsLabel;

  final Widget child;

  /// Plot height — `SdChartStyleV2.plotHeight` for a plotted chart. Null for
  /// one that sizes itself, like a column of proportional rows.
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(title, style: context.textTheme.titleMedium!),
        SizedBox(height: SdSpacingConstant.h12),
        Semantics(
          label: semanticsLabel,
          child: ExcludeSemantics(
            child: SizedBox(height: height, child: child),
          ),
        ),
      ],
    );
  }
}
