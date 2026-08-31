import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/sd_spacing_constant.dart';
import '../sd_context_v2/sd_context_v2.dart';
import '../sd_icon_v2/sd_icon_v2.dart';
import '../sd_outline_v2/sd_outline_v2.dart';
import '../sd_text_style_v2/sd_text_style_v2.dart';

part 'sd_text_field_v2_label.dart';

/// Every text input in the app.
///
/// A [label] sits above the box rather than inside it: Material's floating
/// label animates between two type sizes and two colours on focus, which is
/// motion nobody asked for on a form, and it leaves the field ambiguous the
/// moment there is text in it. A static line above says the same thing and
/// never moves.
///
/// The box is drawn here, not by [InputDecoration]: a 1px outline that
/// thickens and takes the accent on focus, no fill, so the same field reads
/// correctly on a page, on a card and inside a dialog. Material's underline
/// and its dense filled variants both fight the app's card language.
class SdTextFieldV2 extends StatelessWidget {
  const SdTextFieldV2({
    required this.controller,
    this.label,
    this.hint,
    this.helper,
    this.errorText,
    this.prefixIcon,
    this.suffix,
    this.focusNode,
    this.autofocus = false,
    this.enabled = true,
    this.maxLines = 1,
    this.textCapitalization = TextCapitalization.sentences,
    this.keyboardType,
    this.inputFormatters,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.onEditingComplete,
    super.key,
  });

  /// Height of the outline while idle, and while focused. Two values rather
  /// than a colour change alone: focus has to be legible without relying on
  /// hue (WIDGET_RULES § 6).
  static const double idleBorderWidth = SdOutlineV2.width;
  static const double focusedBorderWidth = 2;

  final TextEditingController controller;

  /// The line above the box. Null for a field whose surroundings already say
  /// what it is — a dialog with a title, a search bar with a magnifier.
  final String? label;

  final String? hint;

  /// A quiet line under the box: a format, an example, a consequence.
  final String? helper;

  /// Replaces [helper] and turns the outline to the error colour.
  final String? errorText;

  final IconData? prefixIcon;

  /// Trailing widget inside the box — a clear button, a unit, a spinner.
  final Widget? suffix;

  /// What the field will accept at all. A key that does nothing says "not
  /// here" better than an error under a field does — use this for the shape
  /// of the input (digits only), and [errorText] for its meaning (out of
  /// range).
  final List<TextInputFormatter>? inputFormatters;

  final FocusNode? focusNode;
  final bool autofocus;
  final bool enabled;
  final int maxLines;
  final TextCapitalization textCapitalization;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onEditingComplete;

  @override
  Widget build(BuildContext context) {
    final Color accent = errorText != null
        ? context.colorScheme.error
        : context.colorScheme.primary;
    final Color idle = SdOutlineV2.color(context);
    final TextStyle textStyle = context.textTheme.bodyLarge!.copyWith(
      color: enabled
          ? context.sdTheme.textPrimary
          : context.sdTheme.textSecondary,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (label != null) _Label(text: label!),
        TextField(
          controller: controller,
          focusNode: focusNode,
          autofocus: autofocus,
          enabled: enabled,
          maxLines: maxLines,
          textCapitalization: textCapitalization,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          textInputAction: textInputAction,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          onEditingComplete: onEditingComplete,
          style: textStyle,
          cursorColor: context.colorScheme.primary,
          decoration: InputDecoration(
            isDense: true,
            filled: false,
            hintText: hint,
            hintStyle: textStyle.copyWith(color: context.sdTheme.textSecondary),
            contentPadding: EdgeInsets.symmetric(
              horizontal: SdSpacingConstant.w16,
              vertical: SdSpacingConstant.h12,
            ),
            prefixIcon: prefixIcon == null
                ? null
                : Padding(
                    padding: EdgeInsets.only(
                      left: SdSpacingConstant.w12,
                      right: SdSpacingConstant.w8,
                    ),
                    child: SdIconV2(
                      icon: prefixIcon!,
                      size: SdSpacingConstant.r20,
                      color: context.sdTheme.textSecondary,
                    ),
                  ),
            prefixIconConstraints: const BoxConstraints(),
            suffixIcon: suffix,
            suffixIconConstraints: BoxConstraints(
              minWidth: SdSpacingConstant.w48,
              minHeight: SdSpacingConstant.w48,
            ),
            // Every state is spelled out: leaving one to Material means it's drawn by something other than this file.
            border: _border(idle),
            enabledBorder: _border(idle),
            disabledBorder: _border(idle.withValues(alpha: 0.14)),
            focusedBorder: _border(accent, width: focusedBorderWidth),
            errorBorder: _border(context.colorScheme.error),
            focusedErrorBorder: _border(
              context.colorScheme.error,
              width: focusedBorderWidth,
            ),
            // The helper/error line is drawn below, so the box never reserves space for one it doesn't have.
            helperText: null,
            errorText: null,
          ),
        ),
        if (errorText != null || helper != null)
          _HelperLine(
            text: errorText ?? helper!,
            color: errorText != null
                ? context.colorScheme.error
                : context.sdTheme.textSecondary,
          ),
      ],
    );
  }

  OutlineInputBorder _border(Color color, {double width = idleBorderWidth}) =>
      OutlineInputBorder(
        borderRadius: SdOutlineV2.borderRadius,
        borderSide: BorderSide(color: color, width: width),
      );
}
