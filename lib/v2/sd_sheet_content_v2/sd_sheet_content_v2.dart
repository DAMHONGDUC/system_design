import 'package:flutter/material.dart';

import '../../core/sd_spacing_constant.dart';
import '../sd_button_v2/sd_button_v2.dart';
import '../sd_content_padding_v2/sd_content_padding_v2.dart';
import '../sd_sheet_header_v2/sd_sheet_header_v2.dart';

/// The inside of a bottom sheet: an [SdSheetHeaderV2], then content that
/// scrolls when it has to, under a ceiling of [maxHeightFraction] of the
/// screen.
///
/// **A sheet that updates or adds anything commits from [confirmLabel]'s
/// button, pinned along the bottom edge** (owner's rule). The header keeps
/// only the X. That pairing — leave up in the corner, commit under the thumb
/// — is what lets a picker mark a choice without committing it: tapping a
/// tile only moves the highlight, and nothing leaves the sheet until the
/// button is pressed.
///
/// The button is pinned, never scrolled: a commit that has to be scrolled to
/// is a commit the user has to go looking for, and on a sheet at its 85%
/// ceiling it would sit below the fold on every open.
///
/// The ceiling is what keeps a sheet reading as a layer over the page — a
/// tall picker that grew to the status bar would just be a screen with a
/// rounded top. Content shorter than the ceiling still only takes what it
/// needs; the sheet does not stretch to meet it.
///
/// Only the *content* scrolls: the header stays pinned, and so does [footer].
/// A sheet is a route, not a screen, so it clears the home indicator itself
/// rather than through `SdContentPaddingV2.screen`.
///
/// Pass `isScrollControlled: true` when showing it — without that the sheet
/// route caps itself around half the screen and the ceiling never applies.
class SdSheetContentV2 extends StatelessWidget {
  const SdSheetContentV2({
    required this.title,
    required this.closeTooltip,
    required this.child,
    this.onConfirm,
    this.confirmLabel,
    this.footer,
    super.key,
  });

  /// Tallest a sheet may grow, as a fraction of the screen.
  static const double maxHeightFraction = 0.85;

  final String title;

  /// Already-localized tooltip for the leave button.
  final String closeTooltip;

  final Widget child;

  /// Applies whatever the sheet is collecting. **Null with a [confirmLabel]
  /// disables the button rather than removing it** — a commit that appears
  /// and disappears as the selection changes moves everything under the
  /// thumb, and a disabled button still says what the sheet is for.
  final VoidCallback? onConfirm;

  /// Already-localized label of that button — "Save" for an answer being
  /// given for the first time, "Update" for one being overwritten. **Null is
  /// what says a sheet has no commit**: a menu whose tap on a row IS the
  /// answer has nothing left to press.
  final String? confirmLabel;

  /// Pinned under the scroll area, above the commit button. For the answers
  /// that are neither commit nor leave — a "clear", a "not recorded".
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final double maxHeight =
        MediaQuery.sizeOf(context).height * maxHeightFraction;
    // Clears the keyboard when a field is focused, else the home indicator.
    final double safeBottom =
        MediaQuery.viewInsetsOf(context).bottom +
        MediaQuery.paddingOf(context).bottom +
        SdSpacingConstant.h16;

    final bool hasPinned = footer != null || confirmLabel != null;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SdSheetHeaderV2(title: title, closeTooltip: closeTooltip),
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                SdContentPaddingV2.horizontal,
                0,
                SdContentPaddingV2.horizontal,
                // Only the last pinned thing carries the safe area; anything above it just needs a gap.
                hasPinned ? SdSpacingConstant.h16 : safeBottom,
              ),
              child: child,
            ),
          ),
          if (footer != null)
            Padding(
              padding: EdgeInsets.fromLTRB(
                SdContentPaddingV2.horizontal,
                0,
                SdContentPaddingV2.horizontal,
                confirmLabel == null ? safeBottom : SdSpacingConstant.h8,
              ),
              child: footer,
            ),
          if (confirmLabel != null)
            Padding(
              padding: EdgeInsets.fromLTRB(
                SdContentPaddingV2.horizontal,
                0,
                SdContentPaddingV2.horizontal,
                safeBottom,
              ),
              child: SdButtonV2(
                variant: SdButtonVariantV2.primary,
                label: confirmLabel!,
                onPressed: onConfirm,
              ),
            ),
        ],
      ),
    );
  }
}
