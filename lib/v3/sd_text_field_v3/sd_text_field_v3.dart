import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/sd_spacing_constant.dart';
import '../sd_context_v3/sd_context_v3.dart';
import '../sd_field_label_v3/sd_field_label_v3.dart';
import '../sd_icon_v3/sd_icon_v3.dart';
import '../sd_radius_v3/sd_radius_v3.dart';
import '../sd_text_style_v3/sd_text_style_v3.dart';

/// The one text input in v3 — feature code never uses a raw [TextField] or
/// [TextFormField].
///
/// **The label sits above the field, not inside it.** A floating label saves
/// vertical space and costs the one thing every form in Reseller Studio needs: with
/// the field filled, the label is the only thing saying what the number means,
/// and a shrunk label over a filled box is the first thing to become
/// unreadable at arm's length in a stockroom.
///
/// **[errorText] renders under the field and tints the border**, and both
/// happen together — colour is never the only signal. A field with an error
/// is also announced to screen readers through [Semantics].
class SdTextFieldV3 extends StatelessWidget {
  const SdTextFieldV3({
    required this.label,
    required this.controller,
    this.hint,
    this.isRequired = false,
    this.errorText,
    this.helperText,
    this.keyboardType,
    this.inputFormatters,
    this.prefixIcon,
    this.suffix,
    this.obscureText = false,
    this.enabled = true,
    this.maxLines = 1,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.autofillHints,
    super.key,
  });

  /// Always shown, always above the field.
  final String label;

  final TextEditingController controller;

  /// Placeholder. Drawn in `SdThemeV3.textPlaceholder`, which is fainter than
  /// any text meant to be read — a hint the seller mistakes for a value is a
  /// field they tap straight past.
  final String? hint;

  /// Draws the asterisk after [label]. It says the form will refuse to submit
  /// without this field; it does not enforce anything itself, and which state
  /// makes a field required is a domain question (hard rule 2).
  final bool isRequired;

  /// Non-null tints the border and renders the message below. The app's
  /// validators produce this; the field never validates anything itself.
  final String? errorText;

  /// A hint under the field when there is no error. Hidden while [errorText]
  /// is set, so the two never stack and shift the form.
  final String? helperText;

  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final IconData? prefixIcon;

  /// A trailing widget — a currency code, a clear button, a unit. A widget
  /// rather than an icon so a call site can pass text without this growing a
  /// second trailing slot.
  final Widget? suffix;

  final bool obscureText;
  final bool enabled;
  final int maxLines;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;
  final List<String>? autofillHints;

  bool get _hasError => errorText != null;

  @override
  Widget build(BuildContext context) {
    final Color borderColor = _hasError
        ? context.sdTheme3.danger
        : context.sdTheme3.border;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SdFieldLabelV3(label: label, isRequired: isRequired, enabled: enabled),
        SizedBox(height: SdSpacingConstant.h6),
        Semantics(
          textField: true,
          label: label,
          enabled: enabled,
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            enabled: enabled,
            obscureText: obscureText,
            maxLines: obscureText ? 1 : maxLines,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            textInputAction: textInputAction,
            autofillHints: autofillHints,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
            style: context.textTheme3.bodyLarge!.copyWith(
              color: context.sdTheme3.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: context.textTheme3.bodyLarge!.placeholder3(context),
              filled: true,
              fillColor: enabled
                  ? context.colorScheme3.surface
                  : context.sdTheme3.surfaceSunken,
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: SdSpacingConstant.w12,
                vertical: SdSpacingConstant.h12,
              ),
              prefixIcon: prefixIcon == null
                  ? null
                  : Padding(
                      padding: EdgeInsets.only(
                        left: SdSpacingConstant.w12,
                        right: SdSpacingConstant.w8,
                      ),
                      child: SdIconV3(
                        prefixIcon!,
                        size: SdIconV3.smallSize,
                        color: context.sdTheme3.textSecondary,
                      ),
                    ),
              prefixIconConstraints: const BoxConstraints(),
              suffixIcon: suffix == null
                  ? null
                  : Padding(
                      padding: EdgeInsets.only(right: SdSpacingConstant.w12),
                      child: suffix,
                    ),
              suffixIconConstraints: const BoxConstraints(),
              // The error is rendered below by hand so it can use the app's
              // own text style; InputDecoration's own errorText would draw a
              // second one in Material's.
              border: _outline(borderColor),
              enabledBorder: _outline(borderColor),
              disabledBorder: _outline(context.sdTheme3.divider),
              focusedBorder: _outline(
                _hasError
                    ? context.sdTheme3.danger
                    : context.colorScheme3.primary,
                width: SdSpacingConstant.w2,
              ),
            ),
          ),
        ),
        if (_hasError) ...<Widget>[
          SizedBox(height: SdSpacingConstant.h4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SdIconV3(
                Icons.error_outline,
                size: SdIconV3.smallSize,
                color: context.sdTheme3.danger,
              ),
              SizedBox(width: SdSpacingConstant.w4),
              Expanded(
                child: Text(
                  errorText!,
                  style: context.textTheme3.bodySmall!.copyWith(
                    color: context.sdTheme3.danger,
                  ),
                ),
              ),
            ],
          ),
        ] else if (helperText != null) ...<Widget>[
          SizedBox(height: SdSpacingConstant.h4),
          Text(
            helperText!,
            style: context.textTheme3.bodySmall!.faint3(context),
          ),
        ],
      ],
    );
  }

  OutlineInputBorder _outline(Color color, {double? width}) =>
      OutlineInputBorder(
        borderRadius: SdRadiusV3.inputAll,
        borderSide: BorderSide(color: color, width: width ?? 1),
      );
}
