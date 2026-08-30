import 'package:flutter/material.dart';

import '../sd_glass_surface_v4/sd_glass_surface_v4.dart';

class SdCardV4 extends StatelessWidget {
  const SdCardV4({
    required this.child,
    this.onTap,
    this.semanticLabel,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return SdGlassSurfaceV4(
      onTap: onTap,
      semanticLabel: semanticLabel,
      child: child,
    );
  }
}
