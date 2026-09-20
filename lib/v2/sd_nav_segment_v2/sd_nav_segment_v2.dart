import 'package:flutter/material.dart';

import '../../core/sd_spacing_constant.dart';
import '../sd_content_padding_v2/sd_content_padding_v2.dart';
import '../sd_context_v2/sd_context_v2.dart';
import '../sd_fitted_text_v2/sd_fitted_text_v2.dart';
import '../sd_icon_v2/sd_icon_v2.dart';
import '../sd_nav_destination_v2/sd_nav_destination_v2.dart';
import '../sd_text_style_v2/sd_text_style_v2.dart';

/// What a destination looks like in the chrome that is drawing it.
///
/// **An enum, not a `showLabel` bool.** Two chromes today and a third is not
/// unthinkable; a boolean per difference is how one cell becomes four unrelated
/// looks nobody can name.
enum SdNavSegmentShapeV2 {
  /// `SdBottomNavigationV2`'s pill: a glyph alone in an equal segment. Five
  /// words do not fit across a phone, which is why that chrome is glyph-only.
  glyph,

  /// `SdNavPanelV2`'s panel: a glyph and its label, one row. A tablet has the
  /// width, and a glyph the user has to decode is one they decode every time.
  row,
}

/// One destination cell of the app's navigation chrome.
///
/// Its own widget rather than a private part of either chrome, because the app
/// has two chromes and one cell: `SdBottomNavigationV2` lays these out in a Row
/// on a phone and `SdNavPanelV2` in a Column on a tablet. Everything about
/// *being a destination* — the fill, the timing, the semantics, the size of the
/// tap target — is here once, so the two cannot come out as two different
/// controls.
///
/// **The tap target is the whole cell**, filled by whichever axis its parent
/// stretches — the selected capsule's inset is paint, never a gap in what can
/// be hit (WIDGET_RULES § 6).
class SdNavSegmentV2 extends StatelessWidget {
  const SdNavSegmentV2({
    required this.destination,
    required this.selected,
    required this.onTap,
    this.shape = SdNavSegmentShapeV2.glyph,
    this.labelPeers = const <String>[],
    super.key,
  });

  /// Solid when selected, outline when not — colour is never the only signal
  /// (hard rule 3), and this is the second one.
  static const double _selectedFill = 1;
  static const double _unselectedFill = 0;

  /// Faster than the capsule's slide, so the glyph has settled by the time the
  /// capsule arrives under it rather than the other way round.
  static const Duration _fillDuration = Duration(milliseconds: 200);

  final SdNavDestinationV2 destination;
  final bool selected;
  final VoidCallback onTap;
  final SdNavSegmentShapeV2 shape;

  /// The labels the other destinations draw, so every row of a
  /// [SdNavSegmentShapeV2.row] chrome comes out at one type size instead of
  /// five. Sized alone, "Medikamente" and "Home" pick different sizes and a
  /// column of five reads as five unrelated rows. Ignored by
  /// [SdNavSegmentShapeV2.glyph], which draws no label.
  final List<String> labelPeers;

  @override
  Widget build(BuildContext context) {
    final Color colour = selected
        ? context.colorScheme.primary
        : context.colorScheme.onSurfaceVariant;

    return Semantics(
      button: true,
      selected: selected,
      label: destination.label,
      // A node of its own, not an annotation merged into whatever is above:
      // five destinations are five things to swipe between, and a merged label
      // is one node reading the whole chrome out in one breath.
      container: true,
      // The row paints the label itself, so without this a screen reader says
      // the word twice and a test looking a destination up by name finds a node
      // that is no longer the cell.
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: switch (shape) {
          SdNavSegmentShapeV2.glyph => Center(child: _glyph(colour)),
          SdNavSegmentShapeV2.row => Padding(
            padding: SdContentPaddingV2.navPanelRow,
            child: Row(
              children: <Widget>[
                _glyph(colour),
                SizedBox(width: SdContentPaddingV2.navPanelLabelGap),
                Expanded(child: _label(context, colour)),
              ],
            ),
          ),
        },
      ),
    );
  }

  /// The glyph both shapes draw, animating between the two fills rather than
  /// swapping one icon for another.
  Widget _glyph(Color colour) => TweenAnimationBuilder<double>(
    duration: _fillDuration,
    curve: Curves.easeOutCubic,
    tween: Tween<double>(end: selected ? _selectedFill : _unselectedFill),
    builder: (BuildContext context, double fill, Widget? _) => SdIconV2(
      icon: selected
          ? (destination.selectedIcon ?? destination.icon)
          : destination.icon,
      size: SdSpacingConstant.r26,
      color: colour,
      fill: fill,
    ),
  );

  /// Weight is the second signal beside colour here, the way fill is on the
  /// glyph — selection is never colour alone (hard rule 3).
  Widget _label(BuildContext context, Color colour) {
    final TextStyle style = context.textTheme.bodyMedium!.copyWith(
      color: colour,
    );

    return SdFittedTextV2(
      destination.label,
      style: selected ? style.semiBold : style,
      textAlign: TextAlign.start,
      // Measured at this row's own weight, so in a locale long enough to
      // shrink the set the selected row can land half a step under its
      // neighbours — cheaper than measuring five labels at a weight four of
      // them are not drawn in.
      peers: labelPeers,
    );
  }
}
