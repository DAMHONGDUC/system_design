import 'package:flutter/material.dart';

import '../../core/sd_spacing_constant.dart';
import '../sd_context_v2/sd_context_v2.dart';
import '../sd_icon_v2/sd_icon_v2.dart';
import '../sd_nav_destination_v2/sd_nav_destination_v2.dart';

/// One glyph cell of the app's navigation chrome.
///
/// Its own widget rather than a private part of the bar, because the app has
/// two chromes and only one cell: `SdBottomNavigationV2` lays these out in a
/// Row on a phone and `SdNavigationRailV2` in a Column on a tablet. Everything
/// about *being a destination* — the fill, the timing, the semantics, the size
/// of the tap target — is here once, so the two cannot come out as two
/// different controls.
///
/// **The tap target is the whole cell**, filled by whichever axis its parent
/// stretches — the selected thumb's inset is paint, never a gap in what can be
/// hit (WIDGET_RULES § 6).
class SdNavSegmentV2 extends StatelessWidget {
  const SdNavSegmentV2({
    required this.destination,
    required this.selected,
    required this.onTap,
    super.key,
  });

  /// Solid when selected, outline when not — colour is never the only signal
  /// (hard rule 3), and this is the second one.
  static const double _selectedFill = 1;
  static const double _unselectedFill = 0;

  /// Faster than the thumb's slide, so the glyph has settled by the time the
  /// thumb arrives under it rather than the other way round.
  static const Duration _fillDuration = Duration(milliseconds: 200);

  final SdNavDestinationV2 destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color colour = selected
        ? context.colorScheme.primary
        : context.colorScheme.onSurfaceVariant;
    final IconData glyph = selected
        ? (destination.selectedIcon ?? destination.icon)
        : destination.icon;

    return Semantics(
      button: true,
      selected: selected,
      label: destination.label,
      // The glyph carries no text; the label above is the whole announcement.
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Center(
          child: TweenAnimationBuilder<double>(
            duration: _fillDuration,
            curve: Curves.easeOutCubic,
            tween: Tween<double>(
              end: selected ? _selectedFill : _unselectedFill,
            ),
            builder: (BuildContext context, double fill, Widget? _) => SdIconV2(
              icon: glyph,
              size: SdSpacingConstant.r26,
              color: colour,
              fill: fill,
            ),
          ),
        ),
      ),
    );
  }
}
