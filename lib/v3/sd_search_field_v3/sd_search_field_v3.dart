import 'package:flutter/material.dart';

import '../../core/sd_spacing_constant.dart';
import '../sd_context_v3/sd_context_v3.dart';
import '../sd_icon_v3/sd_icon_v3.dart';
import '../sd_radius_v3/sd_radius_v3.dart';

/// A search box.
///
/// Its own widget rather than an `SdTextFieldV3` with the label left off,
/// because a search field is a different shape and follows different rules:
/// **no label** (the magnifier and the placeholder already say what it is,
/// and a "Search" caption above a field whose hint reads "Title, SKU or
/// barcode" says the same thing twice), a **sunken** fill rather than a
/// raised one, a **stadium** radius, and a clear button that appears only
/// once there is something to clear.
///
/// It sits at the top of the screens a seller uses most, where the vertical
/// space a floating label costs is worth more than the label.
class SdSearchFieldV3 extends StatefulWidget {
  const SdSearchFieldV3({
    required this.controller,
    required this.hint,
    required this.clearTooltip,
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
    super.key,
  });

  final TextEditingController controller;

  /// Placeholder. The only text in the field, so it has to say what is
  /// searchable — "Title, SKU or barcode", not "Search".
  final String hint;

  /// Tooltip and semantics label for the clear button. A parameter because
  /// this package holds no strings.
  final String clearTooltip;

  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;

  @override
  State<SdSearchFieldV3> createState() => _SdSearchFieldV3State();
}

class _SdSearchFieldV3State extends State<SdSearchFieldV3> {
  @override
  void initState() {
    super.initState();
    // Rebuilds when the field goes from empty to not, which is the only thing
    // this widget's own state tracks — whether to show the clear button.
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() => setState(() {});

  void _clear() {
    widget.controller.clear();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    final bool hasText = widget.controller.text.isNotEmpty;

    return TextField(
      controller: widget.controller,
      autofocus: widget.autofocus,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      textInputAction: TextInputAction.search,
      style: context.textTheme3.bodyLarge!.copyWith(
        color: context.sdTheme3.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: context.textTheme3.bodyLarge!.copyWith(
          color: context.sdTheme3.textTertiary,
        ),
        filled: true,
        fillColor: context.sdTheme3.surfaceSunken,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(
          horizontal: SdSpacingConstant.w16,
          vertical: SdSpacingConstant.h12,
        ),
        prefixIcon: Padding(
          padding: EdgeInsets.only(
            left: SdSpacingConstant.w16,
            right: SdSpacingConstant.w12,
          ),
          child: SdIconV3(
            Icons.search_rounded,
            size: SdIconV3.defaultSize,
            color: context.sdTheme3.textSecondary,
          ),
        ),
        prefixIconConstraints: const BoxConstraints(),
        suffixIcon: hasText
            ? Padding(
                padding: EdgeInsets.only(right: SdSpacingConstant.w8),
                child: IconButton(
                  onPressed: _clear,
                  tooltip: widget.clearTooltip,
                  icon: SdIconV3(
                    Icons.cancel_rounded,
                    size: SdIconV3.smallSize,
                    color: context.sdTheme3.textTertiary,
                    semanticLabel: widget.clearTooltip,
                  ),
                ),
              )
            : null,
        suffixIconConstraints: const BoxConstraints(),
        // No visible outline: the sunken fill is the affordance, and an
        // outline on top of it reads as two nested boxes.
        border: _border(Colors.transparent),
        enabledBorder: _border(Colors.transparent),
        focusedBorder: _border(context.colorScheme3.primary),
      ),
    );
  }

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
    borderRadius: SdRadiusV3.fullAll,
    borderSide: BorderSide(color: color, width: SdSpacingConstant.w2),
  );
}
