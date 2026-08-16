import 'package:flutter/material.dart';

import '../../core/sd_spacing_constant.dart';
import '../sd_context_v3/sd_context_v3.dart';
import '../sd_icon_v3/sd_icon_v3.dart';
import '../sd_motion_v3/sd_motion_v3.dart';
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
  /// Owned here so the glyph can answer to focus, not only to text. A field
  /// that lights up when it is tapped is the cheapest signal that the next
  /// keystroke is going somewhere.
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    // Rebuilds when the field goes from empty to not, which is what decides
    // whether the clear button is there.
    widget.controller.addListener(_onChanged);
    _focus.addListener(_onChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    _focus
      ..removeListener(_onChanged)
      ..dispose();
    super.dispose();
  }

  void _onChanged() => setState(() {});

  void _clear() {
    widget.controller.clear();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    final bool hasText = widget.controller.text.isNotEmpty;
    final bool isFocused = _focus.hasFocus;
    final double height = widget.height ?? SdSearchFieldV3.expandedHeight;

    // Centres the glyph in the stadium's round cap: half the leftover either
    // side puts its centre exactly `height / 2` from the edge — which is also
    // where the clear button's glyph lands on the right, because that button
    // is square and `height` wide. The pill reads symmetrical at whatever
    // height it is currently drawn at, docked or expanded.
    final double capInset = (height - SdIconV3.defaultSize) / 2;

    return AnimatedContainer(
      duration: SdMotionV3.fast,
      curve: SdMotionV3.standard,
      height: height,
      decoration: BoxDecoration(
        color: context.sdTheme3.surfaceSunken,
        borderRadius: SdRadiusV3.fullAll,
        // A hairline at rest, thickening to primary on focus — the same pair
        // `SdTextFieldV3` wears. The sunken fill alone reads as a smudge on a
        // light page, where the page and the fill are two steps apart at
        // most; the edge is what makes it a control.
        border: Border.all(
          color: isFocused
              ? context.colorScheme3.primary
              : context.sdTheme3.border,
          width: isFocused ? SdSpacingConstant.w2 : SdSpacingConstant.h1,
        ),
      ),
      child: Row(
        children: <Widget>[
          SizedBox(width: capInset),
          SdIconV3(
            Icons.search_rounded,
            size: SdIconV3.defaultSize,
            // Muted with the hint at rest so an empty field reads as one
            // quiet group, and lifted the moment it is in use. A secondary
            // glyph beside a tertiary hint looks like two decisions nobody
            // made together.
            color: hasText || isFocused
                ? context.sdTheme3.textSecondary
                : context.sdTheme3.textTertiary,
          ),
          SizedBox(width: SdSpacingConstant.w8),
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: _focus,
              autofocus: widget.autofocus,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              textInputAction: TextInputAction.search,
              style: context.textTheme3.bodyLarge!.copyWith(
                color: context.sdTheme3.textPrimary,
              ),
              // **The pill is the box above, not this decoration.** Fill,
              // border and radius used to live here, and `InputDecorator`
              // sizes its content to itself: stretched from outside it
              // painted full height but laid the text out at the top, ten
              // points above the middle of a docked pill, which is what made
              // the field look mis-set against the actions beside it.
              // `textAlignVertical` cannot fix that — it has no spare space
              // to centre within. A plain `Row` centres its children and
              // needs no persuading.
              decoration: InputDecoration.collapsed(
                hintText: widget.hint,
                hintStyle: context.textTheme3.bodyLarge!.copyWith(
                  color: context.sdTheme3.textTertiary,
                ),
              ),
            ),
          ),
          if (hasText)
            IconButton(
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
              // whatever `constraints` says, which is taller than the docked
              // field.
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
          else
            SizedBox(width: capInset),
        ],
      ),
    );
  }
}
