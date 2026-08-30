import 'package:flutter/material.dart';

import '../../core/sd_spacing_constant.dart';

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
    final BorderRadius radius = BorderRadius.circular(SdSpacingConstant.r16);
    final Widget content = Padding(
      padding: EdgeInsets.all(SdSpacingConstant.r16),
      child: child,
    );

    return Semantics(
      button: onTap != null,
      label: semanticLabel,
      child: Material(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        child: onTap == null
            ? content
            : InkWell(onTap: onTap, borderRadius: radius, child: content),
      ),
    );
  }
}
