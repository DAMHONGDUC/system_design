import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../core/sd_spacing_constant.dart';
import '../sd_app_bar_button_v2/sd_app_bar_button_v2.dart';
import '../sd_content_padding_v2/sd_content_padding_v2.dart';
import '../sd_context_v2/sd_context_v2.dart';

/// The header every bottom sheet wears: leave on the left, title in the
/// middle, nothing on the right.
///
/// The X wears its own frosted glass circle — the sheet is a flat opaque
/// panel, so a glass disc on it has real background to refract.
///
/// **The commit is not here.** It used to be a tick (or a pencil) opposite
/// the X, which put the button that writes something in the corner furthest
/// from the thumb and sized it like an icon. Owner's rule: a sheet that
/// updates or adds anything commits from a labelled button pinned along its
/// bottom edge — [SdSheetContentV2] draws it. The right slot stays reserved
/// so the title still sits on the sheet's centre.
class SdSheetHeaderV2 extends StatelessWidget {
  const SdSheetHeaderV2({
    required this.title,
    required this.closeTooltip,
    super.key,
  });

  final String title;

  /// Already-localized tooltip for the leave button.
  final String closeTooltip;

  /// Inset of the row itself. Not the content gutter: the buttons carry
  /// [SdAppBarButtonV2.tapSize] of invisible target around a much smaller
  /// glyph, so the row is pulled in by only the difference — which lands the
  /// glyphs themselves on the same vertical line as the content below them.
  static double get edgeInset {
    final double glyphInset =
        (SdAppBarButtonV2.tapSize - SdAppBarButtonV2.iconSize) / 2;

    return (SdContentPaddingV2.horizontal - glyphInset).clamp(
      0,
      double.infinity,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        edgeInset,
        SdSpacingConstant.h4,
        edgeInset,
        SdSpacingConstant.h16,
      ),
      child: Row(
        children: <Widget>[
          SdAppBarButtonV2(
            icon: Symbols.close_rounded,
            tooltip: closeTooltip,
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.titleMedium,
            ),
          ),
          // Balances the X, so the title reads centred on the sheet rather than on the space left of it.
          SizedBox(width: SdAppBarButtonV2.tapSize),
        ],
      ),
    );
  }
}
