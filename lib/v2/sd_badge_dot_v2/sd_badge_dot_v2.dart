import 'package:flutter/material.dart';

import '../../core/sd_spacing_constant.dart';
import '../sd_context_v2/sd_context_v2.dart';

/// A small dot marking "there is something new here", parked on the corner of
/// [child] — an app-bar icon, a tab, a row.
///
/// A dot rather than a count: the number on a notification badge is a demand,
/// and this system is built for people mid-migraine (WIDGET_RULES § 6, and
/// the app's own no-flashing rule). It answers "is there anything?", which is
/// the only question the icon has to carry.
///
/// The ring is what keeps it legible: dropped straight onto a frosted app bar
/// the accent alone can land on any colour behind it, so the dot carries a
/// ring of the surface it sits on and reads as separate at every background.
class SdBadgeDotV2 extends StatelessWidget {
  const SdBadgeDotV2({
    required this.child,
    required this.showing,
    this.color,
    super.key,
  });

  static const double ringWidth = 2;

  final Widget child;

  /// Nothing is drawn when false — the badge never occupies space it is not
  /// using, so the icon under it does not shift when the dot appears.
  final bool showing;

  /// Defaults to the theme's primary.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    if (!showing) return child;

    final double diameter = SdSpacingConstant.r8 + ringWidth * 2;

    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        child,
        PositionedDirectional(
          top: -ringWidth,
          end: -ringWidth,
          child: Container(
            width: diameter,
            height: diameter,
            decoration: BoxDecoration(
              color: color ?? context.colorScheme.primary,
              shape: BoxShape.circle,
              border: Border.all(
                color: context.sdTheme.background,
                width: ringWidth,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
