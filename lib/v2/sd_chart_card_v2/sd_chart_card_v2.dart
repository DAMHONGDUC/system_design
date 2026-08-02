import 'package:flutter/material.dart';

import '../sd_context_v2/sd_context_v2.dart';
import '../sd_spacing_v2/sd_spacing_v2.dart';

/// A surface panel wrapping one chart, so stacked charts read as distinct
/// cards on the near-black background rather than bleeding into one another.
/// Shared by the History → Chart deck and the dashboard's severity card.
/// Titles live inside each chart widget.
class SdChartCardV2 extends StatelessWidget {
  const SdChartCardV2({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(SdSpacingV2.w16),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(SdSpacingV2.r16),
      ),
      child: child,
    );
  }
}
