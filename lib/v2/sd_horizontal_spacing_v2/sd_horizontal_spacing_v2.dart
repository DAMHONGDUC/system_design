import 'package:flutter/material.dart';

import '../sd_spacing_v2/sd_spacing_v2.dart';

class SdHorizontalSpacingV2 extends StatelessWidget {
  const SdHorizontalSpacingV2({super.key, this.width});

  final double? width;

  @override
  Widget build(BuildContext context) {
    final value = width ?? SdSpacingV2.w12;

    return SizedBox(width: value);
  }
}
