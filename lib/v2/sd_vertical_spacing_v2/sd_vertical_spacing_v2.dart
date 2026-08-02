import 'package:flutter/material.dart';

import '../sd_spacing_v2/sd_spacing_v2.dart';

class SdVerticalSpacingV2 extends StatelessWidget {
  const SdVerticalSpacingV2({super.key, this.height, this.xRatio = 1.0});

  final double? height;
  final double xRatio;

  @override
  Widget build(BuildContext context) {
    final value = (height ?? SdSpacingV2.h12) * xRatio;

    return SizedBox(height: value);
  }
}
