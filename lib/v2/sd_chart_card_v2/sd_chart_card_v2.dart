import 'package:flutter/material.dart';

import '../../core/sd_spacing_constant.dart';
import '../sd_card_v2/sd_card_v2.dart';

/// A surface panel wrapping one chart, so stacked charts read as distinct
/// cards on the near-black background rather than bleeding into one another.
/// Shared by the History → Chart deck and the dashboard's severity card.
/// Titles live inside each chart widget.
class SdChartCardV2 extends StatelessWidget {
  const SdChartCardV2({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SdCardV2(
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: EdgeInsets.all(SdSpacingConstant.w16),
          child: child,
        ),
      ),
    );
  }
}
