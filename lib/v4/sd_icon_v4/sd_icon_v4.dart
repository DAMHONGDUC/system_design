import 'package:flutter/material.dart';

import '../../core/sd_spacing_constant.dart';

class SdIconV4 extends StatelessWidget {
  const SdIconV4(this.icon, {this.color, this.semanticLabel, super.key});

  final IconData icon;
  final Color? color;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      size: SdSpacingConstant.r24,
      color: color,
      semanticLabel: semanticLabel,
    );
  }
}
