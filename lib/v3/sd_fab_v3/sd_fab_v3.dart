import 'package:flutter/material.dart';

import '../../core/sd_spacing_constant.dart';
import '../sd_context_v3/sd_context_v3.dart';
import '../sd_elevation_v3/sd_elevation_v3.dart';
import '../sd_icon_v3/sd_icon_v3.dart';
import '../sd_motion_v3/sd_motion_v3.dart';
import '../sd_radius_v3/sd_radius_v3.dart';
import '../sd_text_style_v3/sd_text_style_v3.dart';

/// The floating action button — Quick Add, and whatever each screen's one
/// primary create action turns out to be.
///
/// **It is a pill that collapses to its glyph while the list is moving.**
/// Material's extended FAB is 56 tall and keeps its label forever; over a
/// floating glass tab bar, on a phone, that is a slab covering two rows of
/// inventory at all times. Here the button is [size] tall, and [expanded]
/// drives whether the label rides along:
///
/// - **Reading** (the list scrolling up under the thumb) → a circle. The
///   action is still there, still in the same corner, still tappable.
/// - **Stopped, or scrolling back up** → the label returns, so nobody has to
///   remember what the glyph does.
///
/// It never disappears. A create action a seller has to scroll to find is one
/// they stop using, and Quick Add is the feature the whole product's speed
/// rests on.
///
/// The caller owns where it sits. Over a floating tab bar it must be lifted
/// by `SdContentPaddingV3.floatingBarInset`, or `extendBody` renders it
/// *behind* the glass.
class SdFabV3 extends StatelessWidget {
  const SdFabV3({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.expanded = true,
    super.key,
  });

  final IconData icon;

  /// Shown beside the glyph while [expanded], and the semantics label in both
  /// states — a collapsed button still has to announce what it does.
  final String label;

  final VoidCallback onPressed;
  final bool expanded;

  /// The pill's height, and its diameter once collapsed. Two steps under
  /// Material's 56: this button sits above a 64pt glass bar, and the two
  /// stacked are the whole bottom of the screen.
  static double get size => SdSpacingConstant.h48;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = context.colorScheme3;

    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: SdRadiusV3.fullAll,
          boxShadow: SdElevationV3.raised(context),
        ),
        child: Material(
          color: colors.primary,
          borderRadius: SdRadiusV3.fullAll,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPressed,
            child: SizedBox(
              height: size,
              child: AnimatedSize(
                duration: SdMotionV3.normal,
                curve: SdMotionV3.emphasized,
                // The screen pins the button's right edge, so the width has
                // to change on the left — anchoring the content right is what
                // keeps the glyph still while the label slides out from
                // under it.
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    SizedBox(
                      width: size,
                      height: size,
                      child: Center(
                        child: SdIconV3(icon, color: colors.onPrimary),
                      ),
                    ),
                    if (expanded) ...<Widget>[
                      Text(
                        label,
                        style: context.textTheme3.labelMedium!.semiBold3
                            .copyWith(color: colors.onPrimary),
                        maxLines: 1,
                        softWrap: false,
                      ),
                      SizedBox(width: SdSpacingConstant.w16),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
