import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

import '../sd_content_padding_v3/sd_content_padding_v3.dart';
import '../sd_context_v3/sd_context_v3.dart';
import '../sd_icon_v3/sd_icon_v3.dart';
import '../sd_motion_v3/sd_motion_v3.dart';

part 'sd_nav_cell_v3_destination.dart';
part 'sd_nav_cell_v3_glass.dart';

/// One destination, drawn the same whichever edge the chrome is on.
///
/// **The cell is shared and the chrome is not.** The pill and the rail differ
/// in how they lay out and in nothing else, so everything about *being* a
/// destination — the glyph, the fill it animates to, the timing, the
/// semantics, the tap target — lives here once. Two copies is how a tab comes
/// to read as one control on a phone and a different one on a tablet.
///
/// It fills whatever box it is given: an equal segment of the pill, or a cell
/// down the rail. It never sizes itself.
class SdNavCellV3 extends StatelessWidget {
  const SdNavCellV3({
    required this.destination,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final SdNavDestinationV3 destination;
  final bool selected;
  final VoidCallback onTap;

  /// Weight is the second signal alongside colour, which colour alone must
  /// never be.
  static double get selectedFill => 1;
  static double get unselectedFill => 0;

  @override
  Widget build(BuildContext context) {
    final Color color = selected
        ? context.colorScheme3.primary
        : context.sdTheme3.textSecondary;

    return Semantics(
      button: true,
      selected: selected,
      container: true,
      label: destination.label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          SdContentPaddingV3.selectedTabRadius,
        ),
        child: Center(
          child: TweenAnimationBuilder<double>(
            duration: SdMotionV3.fast,
            curve: SdMotionV3.standard,
            tween: Tween<double>(end: selected ? selectedFill : unselectedFill),
            builder: (BuildContext context, double fill, Widget? _) => SdIconV3(
              selected
                  ? (destination.selectedIcon ?? destination.icon)
                  : destination.icon,
              size: SdIconV3.defaultSize,
              color: color,
              fill: fill,
            ),
          ),
        ),
      ),
    );
  }
}
