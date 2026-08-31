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
    this.keyboardType = const TextInputType.numberWithOptions(decimal: true),
    this.onChanged,
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
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Semantics(
      textField: true,
      label: label,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: textTheme.labelLarge),
          SizedBox(height: SdSpacingConstant.h8),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            textInputAction: textInputAction,
            onChanged: onChanged,
            onTapOutside: (PointerDownEvent event) =>
                FocusManager.instance.primaryFocus?.unfocus(),
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              prefixIcon: prefixIcon,
              suffixIcon: suffixIcon,
              suffixText: suffix,
              suffixStyle: textTheme.labelLarge?.copyWith(
                color: colors.primary,
              ),
              errorText: errorText,
              helperText: helperText,
              contentPadding: EdgeInsets.symmetric(
                horizontal: SdSpacingConstant.w16,
                vertical: SdSpacingConstant.h16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(SdSpacingConstant.r12),
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
