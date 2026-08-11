import 'package:flutter/material.dart';

import '../../core/sd_spacing_constant.dart';
import '../sd_context_v3/sd_context_v3.dart';
import '../sd_motion_v3/sd_motion_v3.dart';
import '../sd_radius_v3/sd_radius_v3.dart';
import '../sd_text_style_v3/sd_text_style_v3.dart';

/// One selectable filter — Inventory's `All | Listed | Reserved | Sold |
/// Stale`, Orders' `All | To Ship | Shipped | Delivered | Returns`.
///
/// **[count] is part of the chip, not a badge stuck beside it.** Every filter
/// strip in Seller OS answers "how many" as well as "which", and a seller
/// scanning the strip decides where to tap from the number. Rendering it
/// inside means the count can never drift away from the label it counts, and
/// the selected chip's count inherits the selected foreground automatically.
///
/// A null [count] renders the label alone — right for a filter whose total is
/// not known yet, which is not the same as a filter whose total is zero.
class SdFilterChipV3 extends StatelessWidget {
  const SdFilterChipV3({
    required this.label,
    required this.selected,
    required this.onSelected,
    this.count,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  /// How many rows sit behind this filter. Null means "not counted yet";
  /// zero renders as `0` and is a real answer.
  final int? count;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = context.colorScheme3;
    final Color foreground = selected
        ? colors.onPrimary
        : context.sdTheme3.textSecondary;

    return Semantics(
      button: true,
      selected: selected,
      child: AnimatedContainer(
        duration: SdMotionV3.fast,
        curve: SdMotionV3.standard,
        decoration: BoxDecoration(
          color: selected ? colors.primary : Colors.transparent,
          borderRadius: SdRadiusV3.fullAll,
          border: Border.all(
            color: selected ? colors.primary : context.sdTheme3.border,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: SdRadiusV3.fullAll,
          child: InkWell(
            onTap: onSelected,
            borderRadius: SdRadiusV3.fullAll,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: SdSpacingConstant.w14,
                vertical: SdSpacingConstant.h8,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    label,
                    style: context.textTheme3.labelMedium!.semiBold3.copyWith(
                      color: foreground,
                    ),
                  ),
                  if (count != null) ...<Widget>[
                    SizedBox(width: SdSpacingConstant.w6),
                    Text(
                      '$count',
                      style: context.textTheme3.labelMedium!.tabular3.copyWith(
                        color: foreground,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
