import 'package:flutter/material.dart';

import '../../core/sd_spacing_constant.dart';

enum SdButtonVariantV4 { primary, secondary }

class SdButtonV4 extends StatelessWidget {
  const SdButtonV4({
    required this.label,
    required this.onPressed,
    this.variant = SdButtonVariantV4.primary,
    this.expand = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final SdButtonVariantV4 variant;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final ButtonStyle style = ButtonStyle(
      minimumSize: WidgetStatePropertyAll<Size>(
        Size(
          expand ? double.infinity : SdSpacingConstant.w48,
          SdSpacingConstant.h48,
        ),
      ),
      padding: WidgetStatePropertyAll<EdgeInsets>(
        EdgeInsets.symmetric(horizontal: SdSpacingConstant.w20),
      ),
      shape: WidgetStatePropertyAll<OutlinedBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SdSpacingConstant.r12),
        ),
      ),
    );
    final Widget button = variant == SdButtonVariantV4.primary
        ? FilledButton(onPressed: onPressed, style: style, child: Text(label))
        : OutlinedButton(
            onPressed: onPressed,
            style: style,
            child: Text(label),
          );

    return Semantics(button: true, label: label, child: button);
  }
}
