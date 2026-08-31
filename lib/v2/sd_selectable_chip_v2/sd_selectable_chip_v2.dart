import 'package:flutter/material.dart';

import '../../core/sd_spacing_constant.dart';
import '../sd_context_v2/sd_context_v2.dart';
import '../sd_text_style_v2/sd_text_style_v2.dart';

/// One value inside a multi-choice filter: a pill that toggles rather than
/// navigates.
///
/// **It is the control `SdTagV2` refuses to be.** That one states a row's
/// state and takes no tap; this one is pressed. `SdFilterPillV2` is the third
/// of the family and the only one that opens something — a pill with a
/// chevron, sitting outside the sheet these live in.
///
/// **Selected is a tinted fill AND a full-strength border AND the accent
/// label**, never the tint alone: several of these sit in one wrap, and a
/// 12%-alpha fill is not a difference the eye finds while scanning a grid of
/// twenty (hard rule 3 keeps the surface dark, so the fill can never get
/// louder).
class SdSelectableChipV2 extends StatelessWidget {
  const SdSelectableChipV2({
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });

  /// How much of the accent the selected fill carries.
  static const double _selectedFillOpacity = 0.16;

  /// Alpha of the resting border — an edge that shows the chip's bounds
  /// without competing with a selected neighbour.
  static const double _restingBorderOpacity = 0.2;

  /// Already localized — this package renders no copy of its own.
  final String label;

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    final Color foreground = selected
        ? scheme.primary
        : scheme.onSurfaceVariant;

    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected
            ? scheme.primary.withValues(alpha: _selectedFillOpacity)
            : scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(SdSpacingConstant.r20),
        child: InkWell(
          borderRadius: BorderRadius.circular(SdSpacingConstant.r20),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(SdSpacingConstant.r20),
              border: Border.all(
                color: selected
                    ? scheme.primary
                    : scheme.onSurfaceVariant.withValues(
                        alpha: _restingBorderOpacity,
                      ),
              ),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: SdSpacingConstant.w12,
              vertical: SdSpacingConstant.h8,
            ),
            child: Text(
              label,
              style: selected
                  ? context.textTheme.labelLarge!.semiBold.copyWith(
                      color: foreground,
                    )
                  : context.textTheme.labelLarge!.copyWith(color: foreground),
            ),
          ),
        ),
      ),
    );
  }
}
