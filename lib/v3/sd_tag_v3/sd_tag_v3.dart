import 'package:flutter/material.dart';

import '../../core/sd_spacing_constant.dart';
import '../sd_context_v3/sd_context_v3.dart';
import '../sd_icon_v3/sd_icon_v3.dart';
import '../sd_radius_v3/sd_radius_v3.dart';
import '../sd_text_style_v3/sd_text_style_v3.dart';

/// One choice in a group of them — a radio wearing the colour of what it
/// selects.
///
/// **This is the picked-from-a-short-list control.** A status, a condition
/// grade: a handful of values that are the answer to one question, where
/// hiding them behind a row that opens a sheet costs two taps to see what the
/// choices even are. Laid out as tags, the whole vocabulary reads at once.
///
/// **[color] is handed in, never decided here** — the package does not learn
/// what a domain value means (`WIDGET_RULES.md` §1). The app maps its enum to
/// a colour and passes it, which is also what lets every value in a set carry
/// a different one.
///
/// **Colour is never the only signal**: the label is always spelled out, and
/// the chosen tag is filled *and* draws a filled radio. A viewer who cannot
/// tell the hues apart still sees which one is picked.
class SdTagV3 extends StatelessWidget {
  const SdTagV3({
    required this.label,
    required this.color,
    required this.selected,
    required this.onSelected,
    this.icon,
    super.key,
  });

  final String label;

  /// What this value looks like when it is chosen — its fill, its border and
  /// its text.
  final Color color;

  final bool selected;
  final VoidCallback onSelected;

  /// An optional glyph in place of the radio, for a group whose values are
  /// recognised faster by shape than by a dot.
  final IconData? icon;

  /// How much of [color] the chosen tag keeps behind it. Low enough that the
  /// label stays the loudest thing in it — the same strength `SdBadgeV3`
  /// fills with, so a chosen tag and the badge for the same value read as one
  /// colour rather than two versions of it.
  static const double fillOpacity = 0.12;

  @override
  Widget build(BuildContext context) {
    final Color foreground = selected ? color : context.sdTheme3.textSecondary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onSelected,
        borderRadius: SdRadiusV3.chipAll,
        child: Ink(
          padding: EdgeInsets.symmetric(
            horizontal: SdSpacingConstant.w12,
            vertical: SdSpacingConstant.h8,
          ),
          decoration: BoxDecoration(
            color: selected
                ? color.withValues(alpha: fillOpacity)
                : Colors.transparent,
            borderRadius: SdRadiusV3.chipAll,
            border: Border.all(
              color: selected ? color : context.sdTheme3.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SdIconV3(
                icon ??
                    (selected
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_unchecked_rounded),
                size: SdIconV3.smallSize,
                color: foreground,
              ),
              SizedBox(width: SdSpacingConstant.w6),
              Text(
                label,
                style: context.textTheme3.bodySmall!.semiBold3.copyWith(
                  color: foreground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
