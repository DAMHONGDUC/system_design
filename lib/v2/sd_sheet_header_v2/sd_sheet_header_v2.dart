import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../core/sd_spacing_constant.dart';
import '../sd_app_bar_button_v2/sd_app_bar_button_v2.dart';
import '../sd_content_padding_v2/sd_content_padding_v2.dart';
import '../sd_context_v2/sd_context_v2.dart';

/// What the confirming icon of an [SdSheetHeaderV2] is for — a prop, like
/// every other look in this system.
///
/// - [confirm] — a tick: the sheet is collecting an answer that did not exist
///   yet (pick a time for a new reminder).
/// - [edit] — a pencil: the sheet is changing something that already has a
///   value. Same weight, different promise, so the user can tell "I am
///   adding" from "I am overwriting" before they commit.
enum SdSheetActionV2 { confirm, edit }

/// The header every bottom sheet with actions uses: leave on the left, title
/// in the middle, commit on the right.
///
/// Both wear their own frosted glass circle — the sheet is a flat opaque
/// panel, so a glass disc on it has real background to refract — and the
/// commit's glyph takes the secondary colour, which is what still tells the
/// action that writes something from the one that abandons.
///
/// [onConfirm] null shows no commit at all (a picker where the tap itself is
/// the answer, a sheet that only reads). The slot stays reserved so the title
/// sits on the sheet's centre either way.
class SdSheetHeaderV2 extends StatelessWidget {
  const SdSheetHeaderV2({
    required this.title,
    required this.closeTooltip,
    this.onConfirm,
    this.confirmTooltip,
    this.action = SdSheetActionV2.confirm,
    super.key,
  });

  final String title;

  /// Already-localized tooltip for the leave button.
  final String closeTooltip;

  /// Applies whatever the sheet is collecting; null hides the icon.
  final VoidCallback? onConfirm;

  /// Already-localized tooltip for the commit button. Ignored without
  /// [onConfirm].
  final String? confirmTooltip;

  final SdSheetActionV2 action;

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
          if (onConfirm == null)
            SizedBox(width: SdAppBarButtonV2.tapSize)
          else
            SdAppBarButtonV2(
              icon: switch (action) {
                SdSheetActionV2.confirm => Symbols.check_rounded,
                SdSheetActionV2.edit => Symbols.edit_rounded,
              },
              // Same glass disc as the X; the tinted glyph marks this as the action that writes something.
              color: context.colorScheme.secondary,
              tooltip: confirmTooltip,
              onPressed: onConfirm,
            ),
        ],
      ),
    );
  }
}
