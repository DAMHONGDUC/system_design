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
///
/// **Its height is fixed rather than intrinsic.** Two reasons, both
/// load-bearing: the clear button appearing used to grow the field by four
/// points (an `IconButton`'s tap target is taller than the field's own
/// content), so the row twitched the moment a seller typed a character; and
/// `SdSearchHeaderV3` animates this field between two rectangles as the page
/// scrolls, which it can only do if the height it is lerping is a number it
/// can read without laying the field out.
///
/// It has two of those numbers: [height] while the field owns its own row,
/// and [dockedHeight] once it has shrunk into the app bar. See [dockedHeight]
/// for why they differ.
class SdSearchFieldV3 extends StatefulWidget {
  const SdSearchFieldV3({
    required this.controller,
    required this.hint,
    required this.clearTooltip,
    this.height,
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
    super.key,
  });

  /// What this instance is drawn at, defaulting to [height].
  ///
  /// `SdSearchHeaderV3` passes the lerped value while the field is travelling
  /// between its own row and the app bar, so the pill and its clear button
  /// shrink together instead of the button overflowing the box.
  final double? height;

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

  /// The field's height while it owns its own row, and the default for
  /// [height]. Also the clear button's tap target, which is square — so the
  /// button can never be the thing that decides how tall the field is.
  static double get expandedHeight => SdSpacingConstant.h48;

  /// The height the field settles at once it has docked into the app bar.
  ///
  /// **44 — the same height as `SdAppBarActionV3.slot`, on purpose.** The two
  /// controls share that row, so giving them one height makes them one row of
  /// chrome rather than two things that happen to be centred near each other.
  /// It used to equal the full bar height, which left the pill running edge to
  /// edge with no air above or below it while the action beside it floated;
  /// one control bursting out of the row reads as a misalignment even when
  /// both are centred. The leftover splits evenly as padding.
  static double get dockedHeight => SdSpacingConstant.h44;

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
    final double height = widget.height ?? SdSearchFieldV3.expandedHeight;

    return SizedBox(
      height: height,
      child: TextField(
        controller: widget.controller,
        autofocus: widget.autofocus,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        textInputAction: TextInputAction.search,
        // The box is taller than one line of text, so the line has to be
        // told where to sit in it.
        textAlignVertical: TextAlignVertical.center,
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
          // Collapsed, not merely dense: `isDense` still reserves Material's
          // minimum field height, which is taller than [height].
          isCollapsed: true,
          contentPadding: EdgeInsets.symmetric(
            horizontal: SdSpacingConstant.w12,
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
              ? IconButton(
                  onPressed: _clear,
                  tooltip: widget.clearTooltip,
                  padding: EdgeInsets.zero,
                  // Square and tied to the field's *current* height, so the
                  // button shrinks with the pill as it docks instead of
                  // overflowing it.
                  constraints: BoxConstraints.tightFor(
                    width: height,
                    height: height,
                  ),
                  // Without this an IconButton reserves a 48pt tap target
                  // whatever `constraints` says, which is taller than the
                  // docked field.
                  style: IconButton.styleFrom(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  icon: SdIconV3(
                    Icons.cancel_rounded,
                    size: SdIconV3.smallSize,
                    color: context.sdTheme3.textTertiary,
                    semanticLabel: widget.clearTooltip,
                  ),
                )
              : null,
          suffixIconConstraints: const BoxConstraints(),
          // A hairline at rest, thickening to primary on focus — the same
          // pair `SdTextFieldV3` wears. The sunken fill alone reads as a
          // smudge on a light page, where the page and the fill are two
          // steps apart at most; the edge is what makes it a control.
          border: _border(context.sdTheme3.border),
          enabledBorder: _border(context.sdTheme3.border),
          focusedBorder: _border(
            context.colorScheme3.primary,
            width: SdSpacingConstant.w2,
          ),
        ),
      ),
    );
  }

  OutlineInputBorder _border(Color color, {double? width}) =>
      OutlineInputBorder(
        borderRadius: SdRadiusV3.fullAll,
        borderSide: BorderSide(
          color: color,
          width: width ?? SdSpacingConstant.h1,
        ),
      );
}
