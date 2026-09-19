import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

import '../sd_content_padding_v3/sd_content_padding_v3.dart';
import '../sd_context_v3/sd_context_v3.dart';
import '../sd_icon_v3/sd_icon_v3.dart';
import '../sd_motion_v3/sd_motion_v3.dart';
import '../sd_text_style_v3/sd_text_style_v3.dart';

part 'sd_nav_cell_v3_destination.dart';
part 'sd_nav_cell_v3_shape.dart';
part 'sd_nav_cell_v3_glass.dart';

/// One destination, drawn the same whichever edge the chrome is on.
///
/// **The cell is shared and the chrome is not.** The pill and the rail differ
/// in how they lay out and in nothing else, so everything about *being* a
/// destination — the glyph, the fill it animates to, the timing, the
/// semantics, the tap target — lives here once. Two copies is how a tab comes
/// to read as one control on a phone and a different one on a tablet.
///
/// It fills whatever box it is given: an equal segment of the pill, or a row
/// down the panel. It never sizes itself.
///
/// **[shape] is an enum, not a `showLabel` bool.** Two chromes today and a
/// third is not unthinkable; a boolean per difference is how one cell becomes
/// four unrelated looks nobody can name.
class SdNavCellV3 extends StatelessWidget {
  const SdNavCellV3({
    required this.destination,
    required this.selected,
    required this.onTap,
    this.shape = SdNavCellShapeV3.glyph,
    super.key,
  });

  final SdNavDestinationV3 destination;
  final bool selected;
  final VoidCallback onTap;
  final SdNavCellShapeV3 shape;

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
      onTap: onTap,
      selected: selected,
      container: true,
      label: destination.label,
      // One node per destination whatever the shape: the panel paints the
      // label, so without this a reader hears the word twice and a test
      // looking the destination up by name finds a node that is no longer
      // the cell.
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          SdContentPaddingV3.selectedTabRadius,
        ),
        child: switch (shape) {
          SdNavCellShapeV3.glyph => Center(child: _glyph(color)),
          SdNavCellShapeV3.row => Padding(
            padding: SdContentPaddingV3.row,
            child: Row(
              children: <Widget>[
                _glyph(color),
                SizedBox(width: SdContentPaddingV3.navCellLabelGap),
                Expanded(
                  child: Text(
                    destination.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: selected
                        ? context.textTheme3.bodyMedium!.semiBold3.copyWith(
                            color: color,
                          )
                        : context.textTheme3.bodyMedium!.copyWith(color: color),
                  ),
                ),
              ],
            ),
          ),
        },
      ),
    );
  }

  /// The glyph both shapes draw, animating between the two fills rather than
  /// swapping one icon for another.
  Widget _glyph(Color color) => TweenAnimationBuilder<double>(
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
  );
}
