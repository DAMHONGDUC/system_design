import 'package:flutter/material.dart';

import '../../core/sd_spacing_constant.dart';

enum SdButtonVariantV4 { primary, secondary, tertiary, destructive }

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
    final TextStyle? labelStyle = Theme.of(context).textTheme.labelLarge;
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
    final Widget button = switch (variant) {
      SdButtonVariantV4.primary => FilledButton(
        onPressed: onPressed,
        style: style,
        child: Text(label, style: labelStyle),
      ),
      SdButtonVariantV4.secondary => OutlinedButton(
        onPressed: onPressed,
        style: style,
        child: Text(label, style: labelStyle),
      ),
      SdButtonVariantV4.tertiary => TextButton(
        onPressed: onPressed,
        style: style,
        child: Text(label, style: labelStyle),
      ),
      SdButtonVariantV4.destructive => FilledButton(
        onPressed: onPressed,
        style: style.copyWith(
          backgroundColor: WidgetStatePropertyAll<Color>(
            Theme.of(context).colorScheme.error,
          ),
          foregroundColor: WidgetStatePropertyAll<Color>(
            Theme.of(context).colorScheme.onError,
          ),
        ),
        child: Text(label, style: labelStyle),
      ),
    };

    return Semantics(button: true, label: label, child: button);
  }
}
