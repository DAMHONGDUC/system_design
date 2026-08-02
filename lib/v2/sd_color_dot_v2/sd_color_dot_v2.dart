import 'package:flutter/material.dart';

import '../sd_spacing_v2/sd_spacing_v2.dart';

/// A small filled circle used as a colour key — next to a severity value, on
/// a calendar day, in a legend. Colour alone never carries the meaning; it
/// always sits beside the text or Semantics that says it.
class SdColorDotV2 extends StatelessWidget {
  const SdColorDotV2({required this.color, this.size, super.key});

  final Color color;

  /// Diameter. Defaults to `SdSpacingV2.r12`.
  final double? size;

  @override
  Widget build(BuildContext context) {
    final double diameter = size ?? SdSpacingV2.r12;

    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
