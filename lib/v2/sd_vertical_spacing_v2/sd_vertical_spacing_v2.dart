import 'package:flutter/material.dart';

import '../../core/sd_spacing_constant.dart';

class SdVerticalSpacingV2 extends StatelessWidget {
  const SdVerticalSpacingV2({super.key, this.height, this.xRatio = 1.0});

  final double? height;
  final double xRatio;

  @override
  Widget build(BuildContext context) {
    final value = (height ?? SdSpacingConstant.h12) * xRatio;

    return SizedBox(height: value);
  }
}
