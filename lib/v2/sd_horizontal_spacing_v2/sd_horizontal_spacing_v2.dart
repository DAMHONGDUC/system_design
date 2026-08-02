import 'package:flutter/material.dart';

import '../../core/sd_spacing_constant.dart';

class SdHorizontalSpacingV2 extends StatelessWidget {
  const SdHorizontalSpacingV2({super.key, this.width});

  final double? width;

  @override
  Widget build(BuildContext context) {
    final value = width ?? SdSpacingConstant.w12;

    return SizedBox(width: value);
  }
}
