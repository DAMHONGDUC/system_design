import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/sd_spacing_constant.dart';

class SdTextFieldV4 extends StatelessWidget {
  const SdTextFieldV4({
    required this.controller,
    required this.label,
    this.suffix,
    this.helperText,
    this.errorText,
    this.inputFormatters,
    this.textInputAction,
    this.enabled = true,
    this.keyboardType = const TextInputType.numberWithOptions(decimal: true),
    this.onChanged,
    this.onSubmitted,
    this.prefixIcon,
    this.suffixIcon,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final String? suffix;
  final String? helperText;
  final String? errorText;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;
  final bool enabled;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSubmitted;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colors = Theme.of(context).colorScheme;
    final Color contentColor = enabled
        ? colors.onSurface
        : colors.onSurfaceVariant;

    return Semantics(
      textField: true,
      label: label,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: textTheme.labelLarge?.copyWith(color: contentColor),
          ),
          SizedBox(height: SdSpacingConstant.h8),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            textInputAction: textInputAction,
            enabled: enabled,
            onChanged: onChanged,
            onSubmitted: onSubmitted == null
                ? null
                : (String _) => onSubmitted!(),
            onTapOutside: (PointerDownEvent event) =>
                FocusManager.instance.primaryFocus?.unfocus(),
            style: textTheme.titleMedium?.copyWith(
              color: contentColor,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              prefixIcon: prefixIcon,
              suffixIcon: suffixIcon,
              suffixText: suffix,
              suffixStyle: textTheme.labelLarge?.copyWith(
                color: enabled ? colors.primary : contentColor,
              ),
              errorText: errorText,
              helperText: helperText,
              filled: !enabled,
              fillColor: colors.surfaceContainerHighest,
              contentPadding: EdgeInsets.symmetric(
                horizontal: SdSpacingConstant.w16,
                vertical: SdSpacingConstant.h16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(SdSpacingConstant.r12),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(SdSpacingConstant.r12),
                borderSide: BorderSide(color: colors.outlineVariant),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(SdSpacingConstant.r12),
                borderSide: BorderSide(color: colors.primary, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
